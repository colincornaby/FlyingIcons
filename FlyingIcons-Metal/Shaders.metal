//
//  Shaders.metal
//  FlyingIconsShell Metal
//
//  Created by Colin Cornaby on 10/19/18.
//  Copyright © 2018 Consonance Software. All rights reserved.
//

#include <metal_stdlib>
using namespace metal;

typedef struct
{
    float3 position [[attribute(0)]];
    float2 texCoord [[attribute(1)]];
} Vertex;


struct Uniforms
{
    float4x4 transform;
    float alpha;
};

typedef struct
{
    float4 position [[position]];
    float2 texCoord;
    float alpha;
} ColorInOut;

vertex ColorInOut vertexShader(Vertex in [[stage_in]],
                               const device Uniforms&  uniforms    [[ buffer(2) ]])
{
    ColorInOut out;
    
    out.position = float4(in.position, 1) * uniforms.transform;
    out.texCoord = in.texCoord;
    out.alpha = uniforms.alpha;
    
    return out;
}

fragment float4 fragmentShader(ColorInOut in [[stage_in]],
                               texture2d<half> colorMap     [[ texture(0) ]])
{
    constexpr sampler colorSampler(mip_filter::linear,
                                   mag_filter::linear,
                                   min_filter::linear);
    
    half4 colorSample   = colorMap.sample(colorSampler, in.texCoord.xy);
    colorSample[3] = colorSample[3] * in.alpha;
    
    return float4(colorSample);
    ///return float4(1.0, 0.0, 0.0, 0.0);
}
