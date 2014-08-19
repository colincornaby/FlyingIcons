//
//  AppDelegate.m
//  FlyingIconsShell
//

#import "AppDelegate.h"

@implementation AppDelegate


- (void)applicationDidFinishLaunching:(NSNotification *)aNotification
{
    self.window.delegate = self;
    self.driver = [[FlyingIconsDriver alloc] init];
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
