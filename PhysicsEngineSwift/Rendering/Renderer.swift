import MetalKit
import ModelIO
import simd

class Renderer: NSObject {
    static var device: MTLDevice!
    static var commandQueue: MTLCommandQueue!
    static var library: MTLLibrary!
    var pipelineState: MTLRenderPipelineState!
    let depthStencilState: MTLDepthStencilState?
    var landscape: Landscape = Landscape()
    var spheres: [Sphere] = []
    
    var lastTime: Double = CFAbsoluteTimeGetCurrent()
    var uniforms = Uniforms()
    var params = Params()
    
    init(metalView: MTKView) {
        guard let device = MTLCreateSystemDefaultDevice() else {
            fatalError("GPU not available")
        }
        Renderer.device = device
        Renderer.commandQueue = device.makeCommandQueue()
        metalView.device = device
        
        // create the shader function library
        Renderer.library = device.makeDefaultLibrary()
        let vertexFunction = Renderer.library?.makeFunction(name: "vertex_main")
        let fragmentFunction = Renderer.library?.makeFunction(name: "fragment_main")
        
        spheres.append(Sphere(name: "Sphere_1",
                              radius: 0.5,
                              centerPoint: simd_float3(0.0, 0.0, 0.0),
                              modelMatrix: float4x4(translation: float3(0,0,5))))
        
        landscape.spheres = spheres
        
        // create the pipeline state
        let pipelineDescriptor = MTLRenderPipelineDescriptor()
        pipelineDescriptor.vertexFunction = vertexFunction
        pipelineDescriptor.fragmentFunction = fragmentFunction
        pipelineDescriptor.colorAttachments[0].pixelFormat = metalView.colorPixelFormat
        pipelineDescriptor.depthAttachmentPixelFormat = .depth32Float
        pipelineDescriptor.vertexDescriptor = MTKMetalVertexDescriptorFromModelIO(spheres.first!._vertexDescriptor)
        do {
            pipelineState = try device.makeRenderPipelineState(
                descriptor: pipelineDescriptor)
        } catch let error {
            fatalError(error.localizedDescription)
        }
        
        depthStencilState = Renderer.buildDepthStencilState()
        super.init()
        
        metalView.clearColor = MTLClearColor(red: 1.0, green: 1.0, blue: 0.9, alpha: 1.0)
        metalView.depthStencilPixelFormat = .depth32Float
        metalView.delegate = self
    }
    
    static func buildDepthStencilState() -> MTLDepthStencilState? {
        let descriptor = MTLDepthStencilDescriptor()
        descriptor.depthCompareFunction = .less
        descriptor.isDepthWriteEnabled = true
        return Renderer.device.makeDepthStencilState(
            descriptor: descriptor)
    }
}

extension Renderer: MTKViewDelegate {
    func mtkView(_ view: MTKView, drawableSizeWillChange size: CGSize) {
        // Handle resizing
    }
    
    func updateUniforms(landscape: Landscape) {
        uniforms.viewMatrix = landscape.camera.viewMatrix
        uniforms.projectionMatrix = landscape.camera.projectionMatrix
        params.cameraPosition = landscape.camera.position
    }
    
    func draw(in view: MTKView) {
        guard let commandBuffer = Renderer.commandQueue.makeCommandBuffer(),
              let descriptor = view.currentRenderPassDescriptor,
              let renderEncoder = commandBuffer.makeRenderCommandEncoder(descriptor: descriptor) else {
            return
        }
        
        updateUniforms(landscape: landscape)
        
        renderEncoder.setVertexBytes(
            &uniforms,
            length: MemoryLayout<Uniforms>.stride,
            index: 11)
        
        var lights = landscape.lighting.lights
        
        renderEncoder.setFragmentBytes(
          &lights,
          length: MemoryLayout<Light>.stride * lights.count,
          index: 13)
        
        renderEncoder.setDepthStencilState(depthStencilState)
        renderEncoder.setRenderPipelineState(pipelineState)
        
        // update and render
        let currentTime = CFAbsoluteTimeGetCurrent()
        let deltaTime = Float(currentTime - lastTime)
        lastTime = currentTime
        for sphere in spheres {
            sphere.render(
                encoder: renderEncoder,
                renderAttributes: params)
        }
        
        
        renderEncoder.endEncoding()
        guard let drawable = view.currentDrawable else {
            return
        }
        commandBuffer.present(drawable)
        commandBuffer.commit()
    }
}
