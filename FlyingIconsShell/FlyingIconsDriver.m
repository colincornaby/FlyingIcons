//
//  FlyingIconsDriver.m
//  FlyingIconsShell
//
//  Created by Colin Cornaby on 12/4/11.
//  Copyright (c) 2011 Consonance Software. All rights reserved.
//

#import "FlyingIconsDriver.h"

@implementation FlyingIconsDriver
@synthesize glContext = _glContext;
@synthesize iconsContext = _iconsContext;
@synthesize query = _query;
@synthesize nextIcon = _nextIcon;
@synthesize nextSmallIcon = _nextSmallIcon;
@synthesize nextSmallestIcon = _nextSmallestIcon;
@synthesize glView = _glView;

int iconCallback(void * callbackContext, struct flyingIconImage ** images );

-(void)start
{
    srand((unsigned)time(0));
    self.query = [[[NSMetadataQuery alloc] init] autorelease];
    self.query.predicate = [NSPredicate predicateWithFormat:@"kMDItemKind == 'Application'"];
    self.query.delegate = self;
    [self.query startQuery];
    self.glContext = [self.glView openGLContext];
    
    self.iconsContext = newFlyingIconsContext();
    setFlyingIconsContextCallback(self.iconsContext, iconCallback, (void *) self);
    [self performSelectorInBackground:@selector(getNextIcon) withObject:nil];
}

-(void)getNextIcon
{
    if(self.query.resultCount == 0)
    {
        [self performSelectorInBackground:@selector(getNextIcon) withObject:nil];
        return;
    }
    int r = ((float)rand()/(float)RAND_MAX) * (self.query.resultCount-1);
    
    NSMetadataItem *item = [self.query resultAtIndex:r];
    NSImage * iconImage = [[NSWorkspace sharedWorkspace] iconForFile:[item valueForAttribute:@"kMDItemPath"]];
    
    void * imageBuffer = malloc(4 * 128 * 128);
    NSBitmapImageRep *bitmap = [[NSBitmapImageRep alloc] initWithBitmapDataPlanes:(unsigned char **)&imageBuffer pixelsWide:128 pixelsHigh:128 bitsPerSample:8 samplesPerPixel:4 hasAlpha:YES isPlanar:NO colorSpaceName:NSCalibratedRGBColorSpace bytesPerRow:128*4 bitsPerPixel:32];
    NSGraphicsContext *gContext = [NSGraphicsContext graphicsContextWithBitmapImageRep:bitmap];
    [NSGraphicsContext setCurrentContext:gContext];
    [iconImage drawInRect:NSMakeRect(0.0, 0.0, 128.0, 128.0) fromRect:NSMakeRect(0.0, 0.0, [iconImage size].width, [iconImage size].height) operation:NSCompositeCopy fraction:1.0];
    [bitmap release];
    self.nextIcon = imageBuffer;
    
    void *smallImageBuffer = malloc(4 * 64 * 64);
    bitmap = [[NSBitmapImageRep alloc] initWithBitmapDataPlanes:(unsigned char **)&smallImageBuffer pixelsWide:64 pixelsHigh:64 bitsPerSample:8 samplesPerPixel:4 hasAlpha:YES isPlanar:NO colorSpaceName:NSCalibratedRGBColorSpace bytesPerRow:64*4 bitsPerPixel:32];
    gContext = [NSGraphicsContext graphicsContextWithBitmapImageRep:bitmap];
    [NSGraphicsContext setCurrentContext:gContext];
    [iconImage drawInRect:NSMakeRect(0.0, 0.0, 64, 64) fromRect:NSMakeRect(0.0, 0.0, [iconImage size].width, [iconImage size].height) operation:NSCompositeCopy fraction:1.0];
    [bitmap release];
    self.nextSmallIcon = smallImageBuffer;
    
    void *smallestImageBuffer = malloc(4 * 32 * 32);
    bitmap = [[NSBitmapImageRep alloc] initWithBitmapDataPlanes:(unsigned char **)&smallestImageBuffer pixelsWide:32 pixelsHigh:32 bitsPerSample:8 samplesPerPixel:4 hasAlpha:YES isPlanar:NO colorSpaceName:NSCalibratedRGBColorSpace bytesPerRow:32*4 bitsPerPixel:32];
    gContext = [NSGraphicsContext graphicsContextWithBitmapImageRep:bitmap];
    [NSGraphicsContext setCurrentContext:gContext];
    [iconImage drawInRect:NSMakeRect(0.0, 0.0, 32, 32) fromRect:NSMakeRect(0.0, 0.0, [iconImage size].width, [iconImage size].height) operation:NSCompositeCopy fraction:1.0];
    [bitmap release];
    
    self.nextSmallestIcon = smallestImageBuffer;
}

-(void)draw
{
    [self.glContext makeCurrentContext];
    NSRect frame = [self.glView frame];
    drawFlyingIcons(self.iconsContext, frame.size.width, frame.size.height);
    [self.glContext flushBuffer];
}

int iconCallback(void * callbackContext, struct flyingIconImage ** images )
{
    FlyingIconsDriver * self = (FlyingIconsDriver *)callbackContext;
    if(!self.nextIcon)
        return 0;
    struct flyingIconImage * imageArray = malloc(sizeof(struct flyingIconImage)*3);
    imageArray[0].width = 128;
    imageArray[0].height = 128;
    imageArray[0].imageBuffer=self.nextIcon;
    
    imageArray[1].width = 64;
    imageArray[1].height = 64;
    imageArray[1].imageBuffer=self.nextSmallIcon;
    
    imageArray[2].width = 32;
    imageArray[2].height = 32;
    imageArray[2].imageBuffer=self.nextSmallestIcon;
    
    *images = imageArray;
    
    [self performSelectorInBackground:@selector(getNextIcon) withObject:nil];
    return 3;
}

@end
