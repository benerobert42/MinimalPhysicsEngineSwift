#import "Lighting.h"

#import <metal_stdlib>

using namespace metal;

float3 phongLighting(
  float3 normal,
  float3 position,
  constant Params &params,
  constant Light *lights,
  float3 baseColor) {
    float3 diffuseColor = 0;
    float3 ambientColor = 0;
    float3 specularColor = 0;

    float materialShininess = 32;
    float3 materialSpecularColor = float3(1, 1, 1);

    for (uint i = 0; i < params.lightCount; i++) {
      Light light = lights[i];
      switch (light.type) {
        case Sun: {
          // 1
          float3 lightDirection = normalize(-light.position);
          // 2
          float diffuseIntensity =
            saturate(-dot(lightDirection, normal));
          // 3
          diffuseColor += light.color * baseColor * diffuseIntensity;
          if (diffuseIntensity > 0) {
            // 1 (R)
            float3 reflection =
                reflect(lightDirection, normal);
            // 2 (V)
            float3 viewDirection =
                normalize(params.cameraPosition);
            // 3
            float specularIntensity =
                pow(saturate(dot(reflection, viewDirection)),
                    materialShininess);
            specularColor +=
                light.specularColor * materialSpecularColor
                  * specularIntensity;
          }
          break;
        }
        case Point: {
          // 1
          float d = distance(light.position, position);
          // 2
          float3 lightDirection = normalize(light.position - position);
          // 3
          float attenuation = 1.0 / (light.attenuation.x +
              light.attenuation.y * d + light.attenuation.z * d * d);

          float diffuseIntensity =
              saturate(dot(lightDirection, normal));
          float3 color = light.color * baseColor * diffuseIntensity;
          // 4
          color *= attenuation;
          diffuseColor += color;
          break;
        }
        case Spot: {
          // 1
          float d = distance(light.position, position);
          float3 lightDirection = normalize(light.position - position);
          // 2
          float3 coneDirection = normalize(light.coneDirection);
          float spotResult = dot(lightDirection, -coneDirection);
          // 3
          if (spotResult > cos(light.coneAngle)) {
            float attenuation = 1.0 / (light.attenuation.x +
                light.attenuation.y * d + light.attenuation.z * d * d);
            // 4
            attenuation *= pow(spotResult, light.coneAttenuation);
            float diffuseIntensity =
                     saturate(dot(lightDirection, normal));
            float3 color = light.color * baseColor * diffuseIntensity;
            color *= attenuation;
            diffuseColor += color;
          }
          break;
        }
        case Ambient: {
          ambientColor += light.color;
          break;
        }
        case unused: {
          break;
        }
      }
    }
    return diffuseColor + specularColor + ambientColor;
}
