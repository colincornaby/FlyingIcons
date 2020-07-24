//
//  FlyingIconsMetalRenderer.m
//  FlyingIconsShell Metal
//
//  Created by Colin Cornaby on 12/30/19.
//  Copyright © 2019 Consonance Software. All rights reserved.
//

#import "FlyingIconsMetalRenderer.h"
#import <Metal/Metal.h>
#import <simd/simd.h>
#import "FlyingIcons-Mac.hpp"
#import "ResourceLoader.hpp"
#import <IOSurface/IOSurface.h>

@interface FlyingIconsMetalRenderer ()
@property id<MTLDevice> device;
@property id<MTLRenderPipelineState> pipelineState;
@property FlyingIcons::ResourceLoader resourceLoader;
@end

@implementation FlyingIconsMetalRenderer

struct Uniforms
{
    matrix_float4x4 transform;
    float alpha;
};

-(id)initWithDevice:(id<MTLDevice>)device {
    self = [super init];
    _resourceLoader.resourceAllocator = &MetalResourceAllocator;
    _resourceLoader.resourceDeallocator = &MetalResourceDeallocator;
    _resourceLoader.context = (__bridge void *) self;
    self.device = device;
    return self;
}

-(void)render:(MTLRenderPassDescriptor *)renderPassDescriptor commandBuffer:(id<MTLCommandBuffer>)commandBuffer
{
    float aspectRatio = ((float)renderPassDescriptor.colorAttachments[0].texture.width)/((float)renderPassDescriptor.colorAttachments[0].texture.height);
    _context->xBias = aspectRatio;
    if(!self.pipelineState) {
        id<MTLLibrary> library = [self.device newDefaultLibraryWithBundle:[NSBundle bundleForClass:self.class] error:nil];
        MTLRenderPipelineDescriptor *pipelineDescriptor = [[MTLRenderPipelineDescriptor alloc] init];
        pipelineDescriptor.vertexFunction = [library newFunctionWithName:@"vertexShader"];
        pipelineDescriptor.fragmentFunction = [library newFunctionWithName:@"fragmentShader"];
        pipelineDescriptor.colorAttachments[0].pixelFormat = renderPassDescriptor.colorAttachments[0].texture.pixelFormat;
        pipelineDescriptor.colorAttachments[0].blendingEnabled = YES;
        pipelineDescriptor.colorAttachments[0].rgbBlendOperation = MTLBlendOperationAdd;
        pipelineDescriptor.colorAttachments[0].alphaBlendOperation = MTLBlendOperationAdd;
        pipelineDescriptor.colorAttachments[0].sourceRGBBlendFactor = MTLBlendFactorSourceAlpha;;
        pipelineDescriptor.colorAttachments[0].sourceAlphaBlendFactor = MTLBlendFactorSourceAlpha;;
        pipelineDescriptor.colorAttachments[0].destinationRGBBlendFactor = MTLBlendFactorOneMinusSourceAlpha;
         pipelineDescriptor.colorAttachments[0].destinationAlphaBlendFactor = MTLBlendFactorOneMinusSourceAlpha;
        
        MTLVertexDescriptor *mtlVertexDescriptor = [[MTLVertexDescriptor alloc] init];
        
        mtlVertexDescriptor.attributes[0].format = MTLVertexFormatFloat3;
        mtlVertexDescriptor.attributes[0].offset = 0;
        mtlVertexDescriptor.attributes[0].bufferIndex = 0;
        
        mtlVertexDescriptor.attributes[1].format = MTLVertexFormatFloat2;
        mtlVertexDescriptor.attributes[1].offset = 0;
        mtlVertexDescriptor.attributes[1].bufferIndex = 1;
        
        mtlVertexDescriptor.layouts[0].stride = 12;
        mtlVertexDescriptor.layouts[0].stepRate = 1;
        mtlVertexDescriptor.layouts[0].stepFunction = MTLVertexStepFunctionPerVertex;
        
        mtlVertexDescriptor.layouts[1].stride = 8;
        mtlVertexDescriptor.layouts[1].stepRate = 1;
        mtlVertexDescriptor.layouts[1].stepFunction = MTLVertexStepFunctionPerVertex;
        
        pipelineDescriptor.vertexDescriptor = mtlVertexDescriptor;
        pipelineDescriptor.sampleCount = renderPassDescriptor.colorAttachments[0].texture.sampleCount;
        
        NSError *error;
        self.pipelineState = [self.device newRenderPipelineStateWithDescriptor:pipelineDescriptor error:&error];
    }

    
    struct timeval currTime;
    gettimeofday(&currTime, NULL);
    _context->prepare(currTime);
    
    id<MTLRenderCommandEncoder> renderCommandEncoder = [commandBuffer renderCommandEncoderWithDescriptor:renderPassDescriptor];
    [renderCommandEncoder setRenderPipelineState:self.pipelineState];
    
    _resourceLoader.updateForContext(*_context);
    for (std::vector<FlyingIcon * const>::iterator it = _context->icons.begin() ; it != _context->icons.end(); ++it)
    {
        FlyingIcon *icon = (*it);
        matrix_float4x4 transform;
        float alpha;
        currentMatrixStateOfFlyingIcon(*icon, &transform, &alpha, *_context);
        
        struct Uniforms uniforms;
        uniforms.transform = transform;
        uniforms.alpha = alpha;
        if(alpha != 0) {
            float vertices[] = {-0.1, 0.1, (float) 0.0,
                -0.1, -0.1, (float) 0.0,
                0.1, 0.1, (float) 0.0,
                
                0.1 , 0.1, (float) 0.0,
                -0.1, -0.1, (float) 0.0,
                0.1, -0.1, (float) 0.0};
            float texVertices[] = {
                0.0, 0.0,
                0.0, 1.0,
                1.0, 0.0,
                
                1.0, 0.0,
                0.0, 1.0,
                1.0, 1.0};
            
            [renderCommandEncoder setVertexBytes:(void *)vertices length:sizeof(float) * 18 atIndex:0];
            [renderCommandEncoder setVertexBytes:(void *)texVertices length:sizeof(float) * 12 atIndex:1];
            [renderCommandEncoder setVertexBytes:&uniforms length:sizeof(struct Uniforms) atIndex:2];
            id<MTLTexture> texture = (__bridge id<MTLTexture>) _resourceLoader[icon->identifier];
            [renderCommandEncoder setFragmentTexture:texture atIndex:0];
            [renderCommandEncoder drawPrimitives:MTLPrimitiveTypeTriangleStrip vertexStart:0 vertexCount:6];
            
        }
    }
    [renderCommandEncoder endEncoding];
}

void * MetalResourceAllocator(void * context, FlyingIcon &icon)
{
    FlyingIconsMetalRenderer *self = (__bridge FlyingIconsMetalRenderer *)context;
    MTLTextureDescriptor *textureDescriptor = [MTLTextureDescriptor texture2DDescriptorWithPixelFormat:MTLPixelFormatRGBA8Unorm width:icon.image->width height:icon.image->height mipmapped:NO];
    IOSurfaceRef surface = IOSurfaceCreate((CFDictionaryRef)@{
        (NSString *)kIOSurfaceWidth:            [NSNumber numberWithInt:icon.image->width],
        (NSString *)kIOSurfaceHeight:           [NSNumber numberWithInt:icon.image->height],
        (NSString *)kIOSurfaceBytesPerElement:  @4,
        (NSString *)kIOSurfaceBytesPerRow:      @(icon.image->width * 4),
        (NSString *)kIOSurfacePixelFormat:      @"RGBA"
                    });
    textureDescriptor.storageMode = MTLStorageModeManaged;
    IOSurfaceLock(surface, 0, nil);
    icon.image->copyBitmapData(IOSurfaceGetBaseAddress(surface));
    IOSurfaceUnlock(surface, 0, 0);
    id<MTLTexture> texture = [self.device newTextureWithDescriptor:textureDescriptor iosurface:surface plane:0];
    //[texture.buffer didModifyRange:NSMakeRange(0, texture.buffer.length)];
    CFRelease(surface);
    return (void *) CFBridgingRetain(texture);
}

void MetalResourceDeallocator(void * context, void * resource)
{
    id<MTLTexture> texture = (__bridge id<MTLTexture>)resource;
    CFRelease((void *)texture);
}

@end
