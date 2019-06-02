//
//  AppDelegate.h
//  FlyingIconsShell
//
//  Created by Colin Cornaby on 12/3/11.

#import <Cocoa/Cocoa.h>
#import <MetalKit/MetalKit.h>
#import "FlyingIconsDriver.h"

@interface AppDelegate : NSObject <NSApplicationDelegate, NSWindowDelegate, MTKViewDelegate>

@property FlyingIconsDriver *driver;
@property (assign) IBOutlet NSWindow *window;
@property (assign) CVDisplayLinkRef displayLink;
@property (assign) IBOutlet MTKView *metalView;

@end
