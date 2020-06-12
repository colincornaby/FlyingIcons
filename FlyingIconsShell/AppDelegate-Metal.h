//
//  AppDelegate.h
//  FlyingIconsShell
//
//  Created by Colin Cornaby on 12/3/11.

#import <Cocoa/Cocoa.h>
#import <MetalKit/MetalKit.h>
#import "FlyingIconsDriver.h"
#import "FlyingIconsMetalView.h"

@interface AppDelegate : NSObject <NSApplicationDelegate, NSWindowDelegate>

@property FlyingIconsDriver *driver;
@property (assign) IBOutlet NSWindow *window;
@property (assign) IBOutlet FlyingIconsMetalView *metalView;

@end
