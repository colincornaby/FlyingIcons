//
//  FlyingIconsMetalView.m
//  FlyingIcons
//
//  Created by Colin Cornaby on 12/30/19.
//  Copyright © 2019 Consonance Software. All rights reserved.
//

#import "FlyingIconsMetalView.h"
#import "FlyingIconsMetalRenderer.h"
#import "FlyingIconsContext-Renderers.hh"
#import <Metal/Metal.h>


@interface FlyingIconsMetalView ()
@property id<MTLCommandQueue> commandQueue;
@property FlyingIconsMetalRenderer *renderer;
@end

@implementation FlyingIconsMetalView

@synthesize context;

-(id)initWithFrame:(CGRect)frameRect device:(id<MTLDevice>)device {
    self = [super initWithFrame:frameRect device:device];
    return self;
}

- (void)drawRect:(NSRect)dirtyRect {
    [super drawRect:dirtyRect];
    if(!self.renderer) {
        self.renderer = [[FlyingIconsMetalRenderer alloc] initWithDevice:self.device];
    }
    if(!self.commandQueue) {
        self.commandQueue = self.device.newCommandQueue;
    }
    self.renderer.context = &(self.context.renderingContext);
    
    MTLRenderPassDescriptor *renderPassDescriptor = self.currentRenderPassDescriptor;
    
    renderPassDescriptor.colorAttachments[0].clearColor = MTLClearColorMake(0.0, 0.0, 0.0, 1.0);
    if(renderPassDescriptor != nil) {
        id<MTLCommandBuffer> commandBuffer = [self.commandQueue commandBuffer];
        
        
        [self.renderer render:renderPassDescriptor commandBuffer:commandBuffer];
        [commandBuffer presentDrawable:self.currentDrawable];
        [commandBuffer commit];
    }
}

- (void)drawFlyingIconsContents {
    [self display];
}

@end
