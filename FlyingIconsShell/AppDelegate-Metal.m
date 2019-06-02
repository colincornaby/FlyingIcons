//
//  AppDelegate.m
//  FlyingIconsShell
//

#import "AppDelegate-Metal.h"
#import <Metal/Metal.h>

@interface AppDelegate ()
@property id<MTLDevice> device;
@property id<MTLCommandQueue> commandQueue;
@property id<MTLRenderPipelineState> pipelineState;

@end

@implementation AppDelegate

struct Uniforms
{
    matrix_float4x4 transform;
    float alpha;
};


- (void)applicationDidFinishLaunching:(NSNotification *)aNotification
{
    self.window.delegate = self;
    
    self.device = MTLCreateSystemDefaultDevice();
    self.metalView.device = self.device;
    self.metalView.delegate = self;
    self.commandQueue = self.device.newCommandQueue;
    
    
    self.driver = [[FlyingIconsDriver alloc] init];
    [self.driver start];
    self.driver.iconsContext->constructorDestructorCallback = (__bridge void *)self;
    self.driver.iconsContext->constructorCallback = &iconConstructor;
    self.driver.iconsContext->destructorCallback = &iconDestructor;
    CVDisplayLinkCreateWithActiveCGDisplays(&_displayLink);
    CVDisplayLinkSetOutputCallback(self.displayLink, &DisplayLinkCallback, (__bridge void * _Nullable)(self));
    CVDisplayLinkStart(self.displayLink);
}

void iconConstructor(struct flyingIcon *icon, struct flyingIconImage * images, unsigned int imageCount, void *context) {
    AppDelegate *appDelegate = (__bridge AppDelegate *)context;
    struct flyingIconImage image = images[0];
    MTLTextureDescriptor *textureDescriptor = [MTLTextureDescriptor texture2DDescriptorWithPixelFormat:MTLPixelFormatRGBA8Unorm width:image.width height:image.height mipmapped:NO];
    id<MTLTexture> texture = [appDelegate.device newTextureWithDescriptor:textureDescriptor];
    [texture replaceRegion:MTLRegionMake2D(0, 0, image.width, image.height) mipmapLevel:0 withBytes:image.imageBuffer bytesPerRow:image.width * 4];
    icon->userData = (void *) CFBridgingRetain(texture);
}


void iconDestructor(struct flyingIcon *icon, void *context) {
    CFRelease((__bridge CFTypeRef)((__bridge id<MTLTexture>)icon->userData));
    icon->userData = nil;
}

- (void)drawInMTKView:(MTKView *)view {
    MTLRenderPassDescriptor *renderPassDescriptor = self.metalView.currentRenderPassDescriptor;
    if(!self.pipelineState) {
        id<MTLLibrary> library = [self.device newDefaultLibrary];
        MTLRenderPipelineDescriptor *pipelineDescriptor = [[MTLRenderPipelineDescriptor alloc] init];
        pipelineDescriptor.vertexFunction = [library newFunctionWithName:@"vertexShader"];
        pipelineDescriptor.fragmentFunction = [library newFunctionWithName:@"fragmentShader"];
        pipelineDescriptor.colorAttachments[0].pixelFormat = self.metalView.colorPixelFormat;
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
        
        NSError *error;
        self.pipelineState = [self.device newRenderPipelineStateWithDescriptor:pipelineDescriptor error:&error];
        //NSLog([error description]);
    }
    renderPassDescriptor.colorAttachments[0].clearColor = MTLClearColorMake(0.0, 0.0, 0.0, 1.0);
    if(renderPassDescriptor != nil) {
        id<MTLCommandBuffer> commandBuffer = [self.commandQueue commandBuffer];
        
        
        
        struct flyingIcon * icon = self.driver.iconsContext->firstIcon;
        struct flyingIcon *lastIcon = NULL;
        
        
        id<MTLRenderCommandEncoder> renderCommandEncoder = [commandBuffer renderCommandEncoderWithDescriptor:renderPassDescriptor];
        [renderCommandEncoder setRenderPipelineState:self.pipelineState];
        
        float aspectRatio = ((float)renderPassDescriptor.colorAttachments[0].texture.width)/((float)renderPassDescriptor.colorAttachments[0].texture.height);
        self.driver.iconsContext->xBias = aspectRatio;
        
        while(icon!=NULL)
        {
            float xPos, yPos, scale, rotation, alpha;
            currentStateOfFlyingIcon(icon, &xPos, &yPos, &scale, &rotation, &alpha, self.driver.iconsContext);
            long iconSpawnTime = ((icon->spawnTime.tv_sec) * 1000 + icon->spawnTime.tv_usec/1000.0) + 0.5;
            
            struct Uniforms uniforms;
            uniforms.transform = matrix_identity_float4x4;
            uniforms.transform.columns[0][0] = 1.0/aspectRatio;
            uniforms.transform.columns[1][1] = 1.0;
            uniforms.transform.columns[2][2] = 1.0;
            if(rotation != 0){
                matrix_float4x4 inverseTranslateMatrix = matrix_identity_float4x4;
                inverseTranslateMatrix.columns[3][0] = -xPos;
                inverseTranslateMatrix.columns[3][1] = -yPos;
                inverseTranslateMatrix.columns[3][2] = 1;
                matrix_float4x4 rotationMatrix = matrix_identity_float4x4;
                rotationMatrix.columns[0][0] = cosf(rotation);
                rotationMatrix.columns[0][1] = sinf(rotation);
                rotationMatrix.columns[1][0] = -sinf(rotation);
                rotationMatrix.columns[1][1] = cosf(rotation);
                matrix_float4x4 translateMatrix = matrix_identity_float4x4;
                translateMatrix.columns[3][0] = xPos;
                translateMatrix.columns[3][1] = yPos;
                //uniforms.transform = matrix_multiply(uniforms.transform, inverseTranslateMatrix);
                NSLog(@"Rotate");
                /*uniforms.transform = matrix_multiply(uniforms.transform,
                                                     matrix_multiply(translateMatrix,
                                                                     matrix_multiply(rotationMatrix, inverseTranslateMatrix)));*/
            
                
                uniforms.alpha = alpha;
            } else {
            
                uniforms.alpha = alpha;
            }
            if(alpha != 0) {
                //glTranslatef(xPos, yPos, 0.0);
                
                //if(rotation!=0)
                //{
                //    glRotatef((GLfloat) rotation, 0.0, 0.0, 1.0);
                //}
                //glScalef(scale, scale, 0.0f);
                iconSpawnTime = -1.0;
                float vertices[] = {-0.1 * scale + xPos, 0.1 * scale + yPos, (float) -iconSpawnTime,
                    -0.1 * scale + xPos, -0.1 * scale + yPos, (float) -iconSpawnTime,
                    0.1 * scale + xPos, 0.1 * scale + yPos, (float) -iconSpawnTime,
                    
                    0.1 * scale + xPos, 0.1 * scale + yPos, (float) -iconSpawnTime,
                    -0.1 * scale + xPos, -0.1 * scale + yPos, (float) -iconSpawnTime,
                    0.1 * scale + xPos, -0.1 * scale + yPos, (float) -iconSpawnTime};
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
            lastIcon = icon;
            icon = icon->nextIcon;
        }
        [renderCommandEncoder endEncoding];
        
        
        struct timeval currTime;
        gettimeofday(&currTime, NULL);
        prepareContext(self.driver.iconsContext, currTime);
        [commandBuffer presentDrawable:self.metalView.currentDrawable];
        [commandBuffer commit];
    }
}

- (void)mtkView:(MTKView *)view drawableSizeWillChange:(CGSize)size {
    
}

static CVReturn DisplayLinkCallback(CVDisplayLinkRef displayLink, const CVTimeStamp* now, const CVTimeStamp* outputTime, CVOptionFlags flagsIn, CVOptionFlags* flagsOut, void* displayLinkContext)
{
    AppDelegate *appDelegate = (__bridge AppDelegate *)displayLinkContext;
    
    return kCVReturnSuccess;
}

@end


int main(int argc, char *argv[])
{
    return NSApplicationMain(argc, (const char **)argv);
}
