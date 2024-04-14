import MetalKit
import simd

class Sphere {
    var _name: String
    var _radius: Float
    var _centerPoint: simd_float3
    var _mesh: Mesh
    var _vertexDescriptor: MDLVertexDescriptor
    var _modelTransforms: ModelTransform = ModelTransform()
    
    init(name: String,
         radius: Float,
         centerPoint: simd_float3,
         modelMatrix: float4x4) {
        _name = name
        _radius = radius
        _centerPoint = centerPoint
        _modelTransforms.modelMatrix = modelMatrix
        _modelTransforms.normalMatrix = modelMatrix.upperLeft
        
        let allocator = MTKMeshBufferAllocator(device: Renderer.device)
        let sphereMDLMesh = MDLMesh(sphereWithExtent: [radius, radius, radius],
                                    segments: [64, 64],
                                    inwardNormals: false,
                                    geometryType: .triangles,
                                    allocator: allocator)
        
        let sphereMTKMesh = try! MTKMesh(mesh: sphereMDLMesh, device: Renderer.device)
        _mesh = Mesh(mdlMesh: sphereMDLMesh, mtkMesh: sphereMTKMesh)
        
        _vertexDescriptor = sphereMDLMesh.vertexDescriptor
    }
    
    func render(encoder: MTLRenderCommandEncoder,
                renderAttributes: Params) {
        
        var renderAttributes = renderAttributes
        
        encoder.setVertexBytes(
            &_modelTransforms,
            length: MemoryLayout<ModelTransform>.stride,
            index: 10)
        
        encoder.setFragmentBytes(
            &renderAttributes,
            length: MemoryLayout<Params>.stride,
            index: 12)
        
        encoder.setVertexBuffer(_mesh.vertexBuffers.first,
                                offset: 0,
                                index: 0)
        
        
        for submesh in _mesh.submeshes {
            encoder.drawIndexedPrimitives(
                type: .triangle,
                indexCount: submesh.indexCount,
                indexType: submesh.indexType,
                indexBuffer: submesh.indexBuffer,
                indexBufferOffset: submesh.indexBufferOffset
            )
        }
    }
}

