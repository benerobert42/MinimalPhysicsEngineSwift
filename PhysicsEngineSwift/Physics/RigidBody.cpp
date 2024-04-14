#include "RigidBody.h"

#include "Eigen/Dense"

#include <iostream>

// Base RigidBody class function implementations
void RigidBody::Update(float dt) {
    _position.x() += _velocity.x() * dt;
    _position.y() += _velocity.y() * dt;
    _position.z() += _velocity.z() * dt;
    
    std::cout << "Position: \n" << _position << "\nvelocity: \n" << _velocity << std::endl;
}

double RigidBody::GetMass() const {
    return _mass;
}

void RigidBody::SetPosition(Eigen::Vector3f position) {
    _position = position;
}

Eigen::Vector3f& RigidBody::GetPosition() {
    return _position;
}

void RigidBody::SetVelocity(Eigen::Vector3f velocity) {
    _velocity = velocity;
}

Eigen::Vector3f& RigidBody::GetVelocity() {
    return _velocity;
}

void RigidBody::SetBodyCode(int ID) {
    _bodyCode = ID;
}

int RigidBody::GetBodyCode() {
    return _bodyCode;
}

// Sphere function implementations
float Sphere::GetRadius() const {
    return _radius;
}

float Sphere::GetVolume() const {
    return 4.0f * pow(_radius, 3) * M_PI / 3.0f;
}


// Cube function implementations
float Cube::GetSideLength() {
    return _sideLength;
}

float Cube::GetVolume() const {
    return pow(_sideLength, 3);
}

