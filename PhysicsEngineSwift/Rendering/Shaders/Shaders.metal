#include "Lighting.h"

#include <metal_stdlib>

using namespace metal;

struct VertexIn {
    float4 position [[attribute(0)]];
    float3 normal [[attribute(1)]];
    float4 color [[attribute(2)]];
};

struct VertexOut {
    float4 position [[position]];
    float3 normal;
    float4 color;
};

vertex VertexOut vertex_main(const VertexIn in [[stage_in]],
                             constant ModelTransform &modelTransform[[buffer(10)]],
                             constant Uniforms &uniforms [[buffer(11)]])
{
    float4 position = uniforms.projectionMatrix * uniforms.viewMatrix * modelTransform.modelMatrix * in.position;
    float3 normal = modelTransform.normalMatrix * in.normal;
    VertexOut out {
        .position = position,
        .normal = normal,
        .color = in.color
    };
    return out;
}

//fragment float4 fragment_main(VertexOut in [[stage_in]],
//                              constant Params &params [[buffer(ParamsBuffer)]],
//                              constant Light *lights [[buffer(13)]])
//{
//    float3 baseColor = in.color;
//    float3 normalDirection = normalize(in.normal);
//    float3 color = phongLighting(normalDirection,
//                                  in.position.xyz,
//                                  params,
//                                  lights,
//                                  baseColor);
//    return float4(color, 1);
//}

fragment float4 fragment_main(VertexOut in [[stage_in]],
                              constant Light *lights [[buffer(13)]])
{
    float3 normal = normalize(in.normal);
    float3 lightDirection = normalize(-lights->position);
    float diffuseFactor = max(dot(normal, lightDirection), 0.0);
    
    float specularPower = 15.0;
    float specularIntensity = 1.0;
    
    float3 reflectionDirection = reflect(-lightDirection, normal);
    float3 viewDirection = normalize(-in.position.xyz);
    
    float specularFactor = pow(max(dot(reflectionDirection, viewDirection), 0.0), specularPower);
    
    float3 diffuseColor = in.color.xyz * lights->color * diffuseFactor;
    float3 specularColor = specularIntensity * specularFactor * lights->color;
    float3 finalColor = diffuseColor + specularColor;
    
    return float4(finalColor, 1.0);
}
