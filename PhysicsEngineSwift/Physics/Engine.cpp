#include "Engine.h"

#include "RigidBody.h"

#include <numeric>
#include <iostream>

#include "Eigen/Dense"

// MARK: Collision detection
bool PhysicsEngine::SphereToSphereCollide(RigidBody* bodyA,
                                          const Eigen::Affine3f& transformA,
                                          RigidBody* bodyB,
                                          const Eigen::Affine3f& transformB) {
    Sphere* sphereA = dynamic_cast<Sphere*>(bodyA);
    Sphere* sphereB = dynamic_cast<Sphere*>(bodyB);
    
    float radiusA = sphereA->GetRadius();
    float radiusB = sphereB->GetRadius();

    if (!radiusA || !radiusB) {
        return false;
    }
    
    // Transformed positions set
    sphereA->SetPosition(transformA * sphereA->GetPosition());
    sphereB->SetPosition(transformB * sphereB->GetPosition());
    
    Eigen::Vector3f centerToCenter = sphereA->GetPosition() - sphereB->GetPosition();
    float distancesq = centerToCenter.squaredNorm();
    
    return distancesq <= radiusA * radiusA + radiusB * radiusB;
}

bool PhysicsEngine::AABBToSphereCollide(RigidBody* bodyA,
                                        const Eigen::Affine3f& transformA,
                                        RigidBody* bodyB,
                                        const Eigen::Affine3f& transformB) {
    Sphere* sphere;
    Cube* cube;
    
    float radius, sideLength;
    
    float distsqX = pow(bodyA->GetPosition().x() - bodyB->GetPosition().x(), 2);
    float distsqY = pow(bodyA->GetPosition().y() - bodyB->GetPosition().y(), 2);
    float distsqZ = pow(bodyA->GetPosition().z() - bodyB->GetPosition().z(), 2);
    
    if ((cube = dynamic_cast<Cube*>(bodyA))) {
        float radius = dynamic_cast<Sphere*>(bodyB)->GetRadius();
        float sideLength = dynamic_cast<Cube*>(bodyA)->GetSideLength();
    } else {
        float radius = dynamic_cast<Sphere*>(bodyA)->GetRadius();
        float sideLength = dynamic_cast<Cube*>(bodyB)->GetSideLength();
    }
    
    std::vector<float> distances({distsqX, distsqY, distsqZ});
    auto minDist = std::min_element(distances.begin(), distances.end());
    
    return *minDist <= sideLength + radius;
}


bool PhysicsEngine::AABBToAABBCollide(RigidBody* bodyA,
                                      const Eigen::Affine3f& transformA,
                                      RigidBody* bodyB,
                                      const Eigen::Affine3f& transformB) {
    Cube* cubeA = dynamic_cast<Cube*>(bodyA);
    Cube* cubeB = dynamic_cast<Cube*>(bodyB);
    
    float sideLengthA = cubeA->GetSideLength();
    float sideLengthB = cubeB->GetSideLength();
    
    if (!sideLengthA && !sideLengthB) {
        return false;
    }
    
    float distsqX = pow(cubeA->GetPosition().x() - cubeB->GetPosition().x(), 2);
    float distsqY = pow(cubeA->GetPosition().y() - cubeB->GetPosition().y(), 2);
    float distsqZ = pow(cubeA->GetPosition().z() - cubeB->GetPosition().z(), 2);
    
    std::vector<float> distances({distsqX, distsqY, distsqZ});
    auto minDist = std::min_element(distances.begin(), distances.end());
    
    return *minDist <= sideLengthA + sideLengthB;
}

// MARK: Collision resolution

Eigen::Vector3f CalculateCollisionNormal(RigidBody* bodyA,
                                         const Eigen::Affine3f& transformA,
                                         RigidBody* bodyB,
                                         const Eigen::Affine3f& transformB) {
    Eigen::Vector3f collisionNormal;
    if (dynamic_cast<Sphere*>(bodyA) && dynamic_cast<Sphere*>(bodyB)){
        collisionNormal = bodyA->GetPosition() - bodyB->GetPosition();
    } else {
        Eigen::Vector3f distVec = bodyA->GetPosition() - bodyB->GetPosition();
        auto minIt = std::min_element(distVec.begin(), distVec.end());
        long index = std::distance(distVec.begin(), minIt);
        switch (index) {
            case 0:
                collisionNormal = Eigen::Vector3f::UnitX();
                break;
            case 1:
                collisionNormal = Eigen::Vector3f::UnitY();
                break;
            case 2:
                collisionNormal = Eigen::Vector3f::UnitZ();
                break;
        }
    }
    collisionNormal.normalize();
    return collisionNormal;
}

void PhysicsEngine::HandleCollision(RigidBody* bodyA,
                                    const Eigen::Affine3f& transformA,
                                    RigidBody* bodyB,
                                    const Eigen::Affine3f& transformB) {
    
        Eigen::Vector3f& velocityA = bodyA->GetVelocity();
        Eigen::Vector3f& velocityB = bodyB->GetVelocity();
        
        Eigen::Vector3f collisionNormal = CalculateCollisionNormal(bodyA, transformA, bodyB, transformB);
        Eigen::Vector3f relativeVelocity = velocityA - velocityB;
        float velAlongNormal = relativeVelocity.dot(collisionNormal);
        
        float e = 1.0f;
        float j = -(1 + e) * velAlongNormal;
        j /= (1 / bodyA->GetMass()) + (1 / bodyB->GetMass());
        
        Eigen::Vector3f impulse = j * collisionNormal;
        
        velocityA += 1 / bodyA->GetMass() * impulse;
        velocityB -= 1 / bodyB->GetMass() * impulse;
}


void PhysicsEngine::AddBody(RigidBody* body) {
    _bodies.push_back(body);
}

void PhysicsEngine::Update(float dt) {
    for (RigidBody* body : _bodies) {
        body->Update(dt);
    }
    
    for (size_t i = 0; i < _bodies.size(); ++i) {
        for (size_t j = i + 1; j < _bodies.size(); ++j) {
            RigidBody* bodyA = _bodies[i];
            RigidBody* bodyB = _bodies[j];
            
            /*Eigen::Affine3f transformA = _bodiesAndTransforms.GetTransformForBody(bodyA->GetBodyCode());
            Eigen::Affine3f transformB = _bodiesAndTransforms.GetTransformForBody(bodyB->GetBodyCode());*/
            
            Eigen::Affine3f transformA = Eigen::Affine3f::Identity();
            Eigen::Affine3f transformB = Eigen::Affine3f::Identity();
            bool collision;
            
            if (dynamic_cast<Sphere*>(bodyA) && dynamic_cast<Sphere*>(bodyB)) {
                collision = SphereToSphereCollide(bodyA, transformA, bodyB, transformB);
            }
            else if (dynamic_cast<Cube*>(bodyA) && dynamic_cast<Cube*>(bodyB)) {
                collision = AABBToAABBCollide(bodyA, transformA, bodyB, transformB);
            }
            else {
                collision = AABBToSphereCollide(bodyA, transformA, bodyB, transformB);
            }
            
            if (collision){
                HandleCollision(bodyA, transformA, bodyB, transformB);
            }
            
            std::cout << "Update happened, collision happened: " << collision << "!!" << std::endl;
        }
    }
}
