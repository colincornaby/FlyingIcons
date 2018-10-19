//
//  AppDelegate.h
//  FlyingIconsShell
//
//  Created by Colin Cornaby on 12/3/11.

#import <Cocoa/Cocoa.h>
#import "FlyingIconsDriver.h"

@interface AppDelegate : NSObject <NSApplicationDelegate, NSWindowDelegate>

@property FlyingIconsDriver *driver;
@property (assign) IBOutlet NSWindow *window;
@property (assign) IBOutlet NSOpenGLView *glView;

@end
