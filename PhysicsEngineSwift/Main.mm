#include "RigidBody.h"
#include "Engine.h"
#include <chrono>
#import "AppKit/AppKit.h"
#include "SwiftToCPPBridge.h"

int main(int argc, const char * argv[]) {
    std::vector<RigidBody*> bodies;
    Sphere sphere1(1, 1.0, {0, 0, 0}, {1, 0, 0}, 0.5);
    Sphere sphere2(1, 1.0, {10, 0, 0}, {-1, 0, 0}, 0.5);
    
    PhysicsEngine engine = PhysicsEngine::GetInstance(bodies);
    engine.AddBody(&sphere1);
    engine.AddBody(&sphere2);
    
    float startTime = 0.0;
    float dt = 0.01;
    float presentTime = startTime;
    
    while(presentTime < 20.0) {
        engine.Update(dt);
    }
}

