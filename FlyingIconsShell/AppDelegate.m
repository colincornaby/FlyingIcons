//
//  AppDelegate.m
//  FlyingIconsShell
//
//  Created by Colin Cornaby on 12/3/11.
//  Copyright (c) 2011 Consonance Software. All rights reserved.
//

#import "AppDelegate.h"

@implementation AppDelegate

@synthesize window = _window;
@synthesize glView = _glView;
@synthesize driver = _driver;


- (void)dealloc
{
    [super dealloc];
}

- (void)applicationDidFinishLaunching:(NSNotification *)aNotification
{
    self.window.delegate = self;
    self.driver = [[[FlyingIconsDriver alloc] init] autorelease];
    self.driver.glView = self.glView;
    self.driver.glContext = self.glView.openGLContext;
    [self.driver start];
    
    NSTimer *timer = [NSTimer scheduledTimerWithTimeInterval:1.0/30.0 target:self.driver selector:@selector(draw) userInfo:nil repeats:YES];
    
    [timer fire];
}

-(void)windowDidResize:(NSNotification *)notification
{
    [self.driver draw];
}

@end
