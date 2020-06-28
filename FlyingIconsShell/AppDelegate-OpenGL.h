//
//  AppDelegate.h
//  FlyingIconsShell
//
//  Created by Colin Cornaby on 12/3/11.

#import <Cocoa/Cocoa.h>
#import "FlyingIconsGLView.h"

@interface AppDelegate : NSObject <NSApplicationDelegate, NSWindowDelegate>

@property (assign) IBOutlet NSWindow *window;
@property (assign) IBOutlet FlyingIconsGLView *glView;
@property (assign) CVDisplayLinkRef displayLink;

@end
