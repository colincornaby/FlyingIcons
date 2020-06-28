//
//  AppDelegate.m
//  FlyingIconsShell
//

#import "AppDelegate-OpenGL.h"
#import <OpenGL/gl.h>
#import "FlyingIcons-Mac.hpp"

@implementation AppDelegate


- (void)applicationDidFinishLaunching:(NSNotification *)aNotification
{
    self.window.delegate = self;
    _glView.context = new FlyingIcons::MacFlyingIconsContext();
    CVDisplayLinkCreateWithActiveCGDisplays(&_displayLink);
    CVDisplayLinkSetOutputCallback(self.displayLink, &DisplayLinkCallback, (__bridge void * _Nullable)(self));
    CVDisplayLinkSetCurrentCGDisplayFromOpenGLContext(self.displayLink, self.glView.openGLContext.CGLContextObj, self.glView.pixelFormat.CGLPixelFormatObj);
    CVDisplayLinkStart(self.displayLink);
}

static CVReturn DisplayLinkCallback(CVDisplayLinkRef displayLink, const CVTimeStamp* now, const CVTimeStamp* outputTime, CVOptionFlags flagsIn, CVOptionFlags* flagsOut, void* displayLinkContext)
{
    AppDelegate *appDelegate = (__bridge AppDelegate *)displayLinkContext;
    [appDelegate.glView drawFlyingIconsContents];
    return kCVReturnSuccess;
}

-(void)windowDidResize:(NSNotification *)notification
{
    //self.displayLink
    //[self.driver draw];
}

@end


int main(int argc, char *argv[])
{
    return NSApplicationMain(argc, (const char **)argv);
}
