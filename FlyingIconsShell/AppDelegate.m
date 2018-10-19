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
    
    CGLEnable( self.driver.glContext.CGLContextObj, kCGLCEMPEngine);
    
    [self.driver start];
    CVDisplayLinkCreateWithActiveCGDisplays(&_displayLink);
    CVDisplayLinkSetOutputCallback(self.displayLink, &DisplayLinkCallback, (__bridge void * _Nullable)(self.driver));
    CVDisplayLinkSetCurrentCGDisplayFromOpenGLContext(self.displayLink, self.glView.openGLContext.CGLContextObj, self.glView.pixelFormat.CGLPixelFormatObj);
    CVDisplayLinkStart(self.displayLink);
}

static CVReturn DisplayLinkCallback(CVDisplayLinkRef displayLink, const CVTimeStamp* now, const CVTimeStamp* outputTime, CVOptionFlags flagsIn, CVOptionFlags* flagsOut, void* displayLinkContext)
{
    FlyingIconsDriver *driver = (__bridge FlyingIconsDriver *)displayLinkContext;
    CGLLockContext(driver.glContext.CGLContextObj);
    [(__bridge FlyingIconsDriver *)displayLinkContext draw];
    CGLUnlockContext(driver.glContext.CGLContextObj);
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
