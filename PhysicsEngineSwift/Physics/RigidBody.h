#pragma once

#include "Eigen/Dense"

class PhysicsEngine;
class Shape;
enum class ShapeType;

class RigidBody {
private:
    int _bodyCode;
    float _mass;
    Eigen::Vector3f _position;
    Eigen::Vector3f _velocity;
    
public:
    RigidBody(int bodyCode,
              float mass,
              Eigen::Vector3f velocity,
              Eigen::Vector3f position) :
    _bodyCode(bodyCode),
    _mass(mass),
    _position(position),
    _velocity(velocity) {};
    
    virtual ~RigidBody() {};

    virtual void Update(float dt);
    
    double GetMass() const;

    void SetPosition(Eigen::Vector3f position);
    Eigen::Vector3f& GetPosition();
    
    void SetVelocity(Eigen::Vector3f velocity);
    Eigen::Vector3f& GetVelocity();
    
    void SetBodyCode(int ID);
    int GetBodyCode();
};

class Sphere : public RigidBody {
private:
    float _radius;
public:
    Sphere(int bodyCode,
           float mass,
           Eigen::Vector3f position,
           Eigen::Vector3f velocity,
           float radius) : RigidBody(bodyCode, mass, position, velocity), _radius(radius) {};

    float GetRadius() const;
    
    float GetVolume() const;
};


class Cube : public RigidBody {
private:
    float _sideLength;
public:
    Cube(int bodyCode,
           float mass,
           Eigen::Vector3f position,
           Eigen::Vector3f velocity,
           float sideLength) :
    RigidBody(bodyCode, mass, position, velocity),
    _sideLength(sideLength) {};

    float GetSideLength();
    
    float GetVolume() const;
};
