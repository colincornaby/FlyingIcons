//
//  AppDelegate.m
//  FlyingIconsShell
//

#import "AppDelegate-OpenGL.h"
#import <OpenGL/gl.h>

@implementation AppDelegate


- (void)applicationDidFinishLaunching:(NSNotification *)aNotification
{
    self.window.delegate = self;
    self.driver = [[FlyingIconsDriver alloc] init];
    
    
    CGLEnable(  self.glView.openGLContext.CGLContextObj, kCGLCEMPEngine);
    self.glView.openGLContext.view = self.glView;
    
    [self.driver start];
    CVDisplayLinkCreateWithActiveCGDisplays(&_displayLink);
    CVDisplayLinkSetOutputCallback(self.displayLink, &DisplayLinkCallback, (__bridge void * _Nullable)(self));
    CVDisplayLinkSetCurrentCGDisplayFromOpenGLContext(self.displayLink, self.glView.openGLContext.CGLContextObj, self.glView.pixelFormat.CGLPixelFormatObj);
    CVDisplayLinkStart(self.displayLink);
}

static CVReturn DisplayLinkCallback(CVDisplayLinkRef displayLink, const CVTimeStamp* now, const CVTimeStamp* outputTime, CVOptionFlags flagsIn, CVOptionFlags* flagsOut, void* displayLinkContext)
{
    AppDelegate *appDelegate = (__bridge AppDelegate *)displayLinkContext;
    NSOpenGLContext *glContext = appDelegate.glView.openGLContext;
    CGLLockContext(glContext.CGLContextObj);
    [glContext makeCurrentContext];
    GLint dims[4] = {0};
    glGetIntegerv(GL_VIEWPORT, dims);
    drawFlyingIcons(appDelegate.driver.iconsContext, dims[2], dims[3]);
    [glContext flushBuffer];
    CGLUnlockContext(glContext.CGLContextObj);
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
