//
//  AppDelegate.h
//  FlyingIconsShell
//
//  Created by Colin Cornaby on 12/3/11.
//  Copyright (c) 2011 Consonance Software. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "FlyingIconsDriver.h"

@interface AppDelegate : NSObject <NSApplicationDelegate, NSWindowDelegate>

@property (retain) FlyingIconsDriver *driver;
@property (assign) IBOutlet NSWindow *window;
@property (assign) IBOutlet NSOpenGLView *glView;

@end
