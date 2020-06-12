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
#import "FlyingIcons-Mac.h"

@interface FlyingIconsMetalRenderer ()
@property id<MTLDevice> device;
@property id<MTLRenderPipelineState> pipelineState;
@end

@implementation FlyingIconsMetalRenderer

struct Uniforms
{
    matrix_float4x4 transform;
    float alpha;
};

-(id)initWithDevice:(id<MTLDevice>)device {
    self = [super init];
    self.device = device;
    return self;
}

-(void)render:(MTLRenderPassDescriptor *)renderPassDescriptor commandBuffer:(id<MTLCommandBuffer>)commandBuffer
{
    self.driver.iconsContext->constructorDestructorCallback = (__bridge void *)self;
    self.driver.iconsContext->constructorCallback = &iconConstructorMTL;
    self.driver.iconsContext->destructorCallback = &iconDestructorMTL;
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
    prepareContext(self.driver.iconsContext, currTime);
    
    id<MTLRenderCommandEncoder> renderCommandEncoder = [commandBuffer renderCommandEncoderWithDescriptor:renderPassDescriptor];
    [renderCommandEncoder setRenderPipelineState:self.pipelineState];

    struct flyingIcon * icon = self.driver.iconsContext->firstIcon;
    while(icon!=NULL)
    {
        matrix_float4x4 transform;
        float alpha;
        currentMatrixStateOfFlyingIcon(icon, &transform, &alpha, self.driver.iconsContext);
        
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
            
            id<MTLBuffer> transformBuffer = [renderCommandEncoder.device newBufferWithBytes:&uniforms length:sizeof(uniforms) options:0];
            
            [renderCommandEncoder setVertexBytes:(void *)vertices length:sizeof(float) * 18 atIndex:0];
            [renderCommandEncoder setVertexBytes:(void *)texVertices length:sizeof(float) * 12 atIndex:1];
            [renderCommandEncoder setVertexBuffer:transformBuffer offset:0 atIndex:2];
            [renderCommandEncoder setFragmentTexture:(__bridge id<MTLTexture>)icon->userData atIndex:0];
            [renderCommandEncoder drawPrimitives:MTLPrimitiveTypeTriangleStrip vertexStart:0 vertexCount:6];
            
        }
        icon = icon->nextIcon;
    }
    [renderCommandEncoder endEncoding];
}



void iconConstructorMTL(struct flyingIcon *icon, struct flyingIconImage * images, unsigned int imageCount, void *context) {
    FlyingIconsMetalRenderer *self = (__bridge FlyingIconsMetalRenderer *)context;
    struct flyingIconImage image = images[0];
    MTLTextureDescriptor *textureDescriptor = [MTLTextureDescriptor texture2DDescriptorWithPixelFormat:MTLPixelFormatRGBA8Unorm width:image.width height:image.height mipmapped:NO];
    id<MTLTexture> texture = [self.device newTextureWithDescriptor:textureDescriptor];
    [texture replaceRegion:MTLRegionMake2D(0, 0, image.width, image.height) mipmapLevel:0 withBytes:image.imageBuffer bytesPerRow:image.width * 4];
    icon->userData = (void *) CFBridgingRetain(texture);
}


void iconDestructorMTL(struct flyingIcon *icon, void *context) {
    CFRelease((__bridge CFTypeRef)((__bridge id<MTLTexture>)icon->userData));
    icon->userData = nil;
}

@end
