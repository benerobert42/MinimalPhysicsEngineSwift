#pragma once

#include "RigidBody.h"

#include "Eigen/Dense"
#include <vector>

class PhysicsEngine {
private:
    std::vector<RigidBody*> _bodies;

    PhysicsEngine(std::vector<RigidBody*> bodies) {
        _bodies = bodies;
    }
    
public:
    
    struct ContactPoint {
        Eigen::Vector3f A;
        Eigen::Vector3f B;
        Eigen::Vector3f normal;
    };
    
    struct Transform {
        Eigen::Vector3f pos;
        Eigen::Vector3f scale;
        Eigen::Vector3f rotation;
    };
    
    static PhysicsEngine& GetInstance(std::vector<RigidBody*> bodies) {
        static PhysicsEngine instance(bodies);
        return instance;
    }
    
    bool SphereToSphereCollide(RigidBody* bodyA,
                               const Eigen::Affine3f& transformA,
                               RigidBody* bodyB,
                               const Eigen::Affine3f& transformB);
    
    bool AABBToSphereCollide(RigidBody* bodyA,
                             const Eigen::Affine3f& transformA,
                             RigidBody* bodyB,
                             const Eigen::Affine3f& transformB);
    
    bool AABBToAABBCollide(RigidBody* bodyA,
                           const Eigen::Affine3f& transformA,
                           RigidBody* bodyB,
                           const Eigen::Affine3f& transformB);
    
    void HandleSphereToSphereCollide(RigidBody* bodyA,
                                     const Eigen::Affine3f& transformA,
                                     RigidBody* bodyB,
                                     const Eigen::Affine3f& transformB);
    
    void HandleAABBToSphereCollide(RigidBody* bodyA,
                                   const Eigen::Affine3f& transformA,
                                   RigidBody* bodyB,
                                   const Eigen::Affine3f& transformB);
    
    void HandleAABBToAABBCollide(RigidBody* bodyA,
                                 const Eigen::Affine3f& transformA,
                                 RigidBody* bodyB,
                                 const Eigen::Affine3f& transformB);
    
    void HandleCollision(RigidBody* bodyA,
                         const Eigen::Affine3f& transformA,
                         RigidBody* bodyB,
                         const Eigen::Affine3f& transformB);
    
    void Setup();
    void AddBody(RigidBody* body);
    void RemoveBody(RigidBody* body);

    void Update(float dt);
};
