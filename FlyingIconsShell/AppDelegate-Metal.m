//
//  AppDelegate.m
//  FlyingIconsShell
//

#import "AppDelegate-Metal.h"
#import "FlyingIcons-Mac.h"
#import <Metal/Metal.h>
#import <MetalKit/MetalKit.h>

@interface AppDelegate ()
@property id<MTLDevice> device;

@end

@implementation AppDelegate


- (void)applicationDidFinishLaunching:(NSNotification *)aNotification
{
    self.window.delegate = self;
    
    NSNumber *screenID = self.window.screen.deviceDescription[@"NSScreenNumber"];
    self.device = CGDirectDisplayCopyCurrentMetalDevice([screenID intValue]);
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
