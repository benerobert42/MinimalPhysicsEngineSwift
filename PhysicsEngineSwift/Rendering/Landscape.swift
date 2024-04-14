import MetalKit

struct Landscape {
    var spheres: [Sphere] = []
    let lighting = Lighting()
    var camera = FirstPersonCamera()
    
    mutating func update(size: CGSize) {
        camera.update(size: size)
    }
}

