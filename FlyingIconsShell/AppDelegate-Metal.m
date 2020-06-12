//
//  AppDelegate.m
//  FlyingIconsShell
//

#import "AppDelegate-Metal.h"

@interface AppDelegate ()
@property id<MTLDevice> device;

@end

@implementation AppDelegate


- (void)applicationDidFinishLaunching:(NSNotification *)aNotification
{
    self.window.delegate = self;
    
    self.device = MTLCreateSystemDefaultDevice();
    self.metalView.device = self.device;
    self.metalView.sampleCount = 2;
    
    
    self.driver = [[FlyingIconsDriver alloc] init];
    self.metalView.driver = self.driver;
    [self.driver start];
}

@end


int main(int argc, char *argv[])
{
    return NSApplicationMain(argc, (const char **)argv);
}
