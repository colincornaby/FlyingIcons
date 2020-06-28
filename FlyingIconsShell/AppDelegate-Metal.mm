//
//  AppDelegate.m
//  FlyingIconsShell
//

#import "AppDelegate-Metal.h"
#import <Metal/Metal.h>
#import <MetalKit/MetalKit.h>
#import "ConfigurationWindowController.h"
#import "FlyingIcons-Mac.hpp"

@interface AppDelegate ()
@property id<MTLDevice> device;
@property ConfigurationWindowController *configurationWindowController;

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
    self.metalView.context = new FlyingIcons::MacFlyingIconsContext();
    
    self.configurationWindowController = [[ConfigurationWindowController alloc] initWithWindowNibName:@"ConfigurationWindowController"];
    [self.driver start];
    //self.configurationWindowController.context = self.driver.iconsContext;
    NSWindowStyleMask styleMask = self.configurationWindowController.window.styleMask;
    self.configurationWindowController.window.styleMask = styleMask | NSWindowStyleMaskHUDWindow | NSWindowStyleMaskUtilityWindow;
    
    [self.configurationWindowController showWindow:self];
}

@end


int main(int argc, char *argv[])
{
    return NSApplicationMain(argc, (const char **)argv);
}
