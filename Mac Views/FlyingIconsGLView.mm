//
//  FlyingIconsGLView.m
//  FlyingIcons
//
//  Created by Colin Cornaby on 12/29/19.
//  Copyright © 2019 Consonance Software. All rights reserved.
//

#import "FlyingIconsGLView.h"
#import <OpenGL/gl.h>
#import "ResourceLoader.hpp"
#import "FlyingIconsGL.hpp"

@interface FlyingIconsGLView ()

@property FlyingIcons::ResourceLoader resourceLoader;

@end

@implementation FlyingIconsGLView

@synthesize driver;

- (instancetype)initWithCoder:(NSCoder *)coder
{
    self = [super initWithCoder:coder];
    if (self) {
        [self setWantsBestResolutionOpenGLSurface:YES];
        
        //Workaround for OpenGL oddities on some platforms
        CGLEnable(  self.openGLContext.CGLContextObj, kCGLCEMPEngine);
        self.openGLContext.view = self;
    }
    return self;
}

- (instancetype)initWithFrame:(NSRect)frame
{
    NSOpenGLPixelFormatAttribute attrs[] =
    {
        NSOpenGLPFADoubleBuffer,
        NSOpenGLPFADepthSize, 32,
        NSOpenGLPFAMultisample,
        NSOpenGLPFASampleBuffers, (NSOpenGLPixelFormatAttribute)1,
        NSOpenGLPFASamples, (NSOpenGLPixelFormatAttribute)4,
        0
    };
    self = [super initWithFrame:frame pixelFormat:[[NSOpenGLPixelFormat alloc] initWithAttributes:attrs]];
    if (self) {
        [self setWantsBestResolutionOpenGLSurface:YES];
        
        //Workaround for OpenGL oddities on some platforms
        CGLEnable(  self.openGLContext.CGLContextObj, kCGLCEMPEngine);
        self.openGLContext.view = self;
    }
    return self;
}

- (void)drawRect:(NSRect)dirtyRect {
    [super drawRect:dirtyRect];
}

-(void)drawFlyingIconsContents {
    if(self.driver) {
        
        NSOpenGLContext *glContext = self.openGLContext;
        CGLLockContext(glContext.CGLContextObj);
        [glContext makeCurrentContext];
        GLint dims[4] = {0};
        glGetIntegerv(GL_VIEWPORT, dims);
        drawFlyingIcons(self.driver.iconsContext, _resourceLoader, dims[2], dims[3]);
        [glContext flushBuffer];
        CGLUnlockContext(glContext.CGLContextObj);
    }
}

@end
