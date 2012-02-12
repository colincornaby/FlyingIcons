//
//  Flying_Icons_ScreensaverView.m
//  Flying Icons Screensaver
//
//  Created by Colin Cornaby on 12/4/11.
//  Copyright (c) 2011 Consonance Software. All rights reserved.
//

#import "Flying_Icons_ScreensaverView.h"

@implementation Flying_Icons_ScreensaverView

- (id)initWithFrame:(NSRect)frame isPreview:(BOOL)isPreview
{
    self = [super initWithFrame:frame isPreview:isPreview];
    if (self) {
        [self setAnimationTimeInterval:1/30.0];
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

@end
