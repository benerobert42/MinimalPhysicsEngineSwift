import CoreGraphics

struct FirstPersonCamera {
    var aspect: Float = 1.0
    var fov = Float(70).degreesToRadians
    var near: Float = 0.1
    var far: Float = 100
    var position: float3 = float3(0.0, 0.0, 0.0)
    var rotation: float3 = float3(0.0, 0.0, 0.0)
    
    var projectionMatrix: float4x4 {
        float4x4(
            projectionFov: fov,
            near: near,
            far: far,
            aspect: aspect)
    }
    
    var viewMatrix: float4x4 {
        (float4x4(translation: position) *
         float4x4(rotation: rotation)).inverse
    }
    
    mutating func update(size: CGSize) {
        aspect = Float(size.width / size.height)
    }
}

struct ArcballCamera {
    var aspect: Float = 1.0
    var fov = Float(70).degreesToRadians
    var near: Float = 0.1
    var far: Float = 100
    
    let minDistance: Float = 0.0
    let maxDistance: Float = 20
    var target: float3 = [0, 0, 0]
    var distance: Float = 2.5
    
    var position: float3 = float3(0.0, 0.0, 0.0)
    var rotation: float3 = float3(0.0, 0.0, 0.0)
    
    var projectionMatrix: float4x4 {
        float4x4(
            projectionFov: fov,
            near: near,
            far: far,
            aspect: aspect)
    }
    
    var viewMatrix: float4x4 {
        let matrix: float4x4
        if target == position {
            matrix = (float4x4(translation: target) * float4x4(rotationYXZ: rotation)).inverse
        } else {
            matrix = float4x4(eye: position, center: target, up: [0, 1, 0])
        }
        return matrix
    }
    
    mutating func update(size: CGSize) {
        aspect = Float(size.width / size.height)
    }
}

