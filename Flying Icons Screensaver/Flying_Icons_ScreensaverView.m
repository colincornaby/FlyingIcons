//
//  Flying_Icons_ScreensaverView.m
//  Flying Icons Screensaver
//
//  Created by Colin Cornaby on 12/4/11.
//  Copyright (c) 2011 Consonance Software. All rights reserved.
//

#import "Flying_Icons_ScreensaverView.h"
#import <OpenGL/OpenGL.h>
#import <Cocoa/Cocoa.h>

@implementation Flying_Icons_ScreensaverView

@synthesize  driver = _driver;

- (id)initWithFrame:(NSRect)frame isPreview:(BOOL)isPreview
{
    self = [super initWithFrame:frame isPreview:isPreview];
    if (self) {
        NSOpenGLPixelFormatAttribute attrs[] =
        {
            NSOpenGLPFADoubleBuffer,
            NSOpenGLPFADepthSize, 32,
            0
        };
        [self setAnimationTimeInterval:1/30.0];
        NSOpenGLView *glView =[[NSOpenGLView alloc] initWithFrame:self.bounds pixelFormat:[[[NSOpenGLPixelFormat alloc] initWithAttributes:attrs] autorelease]];
        [self addSubview:glView];
        [glView setAutoresizingMask:NSViewWidthSizable | NSViewHeightSizable];
        glView.alphaValue =0.0;
        self.driver = [[[FlyingIconsDriver alloc] init] autorelease];
        self.driver.glView = glView;
        self.driver.glContext = glView.openGLContext;
        [self.driver start];
        [self.driver draw];
        [glView release];
    }
    return self;
}

- (void)startAnimation
{
    [super startAnimation];
}

- (void)stopAnimation
{
    [super stopAnimation];
}

- (void)drawRect:(NSRect)rect
{
    [super drawRect:rect];
}

- (void)animateOneFrame
{
    [self.driver draw];
    self.driver.glView.alphaValue=1.0;
    return;
}

- (BOOL)hasConfigureSheet
{
    return NO;
}

- (NSWindow*)configureSheet
{
    return nil;
}

-(void)dealloc
{
    [super dealloc];
}

@end
