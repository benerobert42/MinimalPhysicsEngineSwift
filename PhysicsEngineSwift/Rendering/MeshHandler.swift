import MetalKit

import MetalKit

struct Submesh {
    let indexCount: Int
    let indexType: MTLIndexType
    let indexBuffer: MTLBuffer
    let indexBufferOffset: Int
    
    init(mdlSubmesh: MDLSubmesh, mtkSubmesh: MTKSubmesh) {
        indexCount = mtkSubmesh.indexCount
        indexType = mtkSubmesh.indexType
        indexBuffer = mtkSubmesh.indexBuffer.buffer
        indexBufferOffset = mtkSubmesh.indexBuffer.offset
    }
}


struct Mesh {
  let vertexBuffers: [MTLBuffer]
  let submeshes: [Submesh]
    
  init(mdlMesh: MDLMesh, mtkMesh: MTKMesh) {
    var vertexBuffers: [MTLBuffer] = []
    for mtkMeshBuffer in mtkMesh.vertexBuffers {
      vertexBuffers.append(mtkMeshBuffer.buffer)
    }
    self.vertexBuffers = vertexBuffers
    submeshes = zip(mdlMesh.submeshes!, mtkMesh.submeshes).map { mesh in
      Submesh(mdlSubmesh: mesh.0 as! MDLSubmesh, mtkSubmesh: mesh.1)
    }
  }
}
