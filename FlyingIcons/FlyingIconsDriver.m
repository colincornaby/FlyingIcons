//
//  FlyingIconsDriver.m
//  FlyingIconsShell
//
//  Created by Colin Cornaby on 12/4/11.

/* Copyright 2011 Colin Cornaby. All rights reserved.
 * All rights reserved.
 * 
 * Redistribution and use in source and binary forms, with or without
 * modification, are permitted provided that the following conditions
 * are met:
 * 
 * Redistributions of source code must retain the above copyright notice,
 * this list of conditions and the following disclaimer.
 * 
 * Redistributions in binary form must reproduce the above copyright
 * notice, this list of conditions and the following disclaimer in the
 * documentation and/or other materials provided with the distribution.
 * 
 * Neither the name of the project's author nor the names of its
 * contributors may be used to endorse or promote products derived from
 * this software without specific prior written permission.
 * 
 * THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS
 * "AS IS" AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT
 * LIMITED TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS
 * FOR A PARTICULAR PURPOSE ARE DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT
 * HOLDER OR CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL,
 * SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED
 * TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR
 * PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF
 * LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING
 * NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS
 * SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
 *
 */

#import "FlyingIconsDriver.h"

@implementation FlyingIconsDriver

struct flyingIconImage * iconCallback(void * callbackContext);

-(void) start {

    srand((unsigned)time(0));
    self.query = NSMetadataQuery.new;
    _query.predicate = [NSPredicate predicateWithFormat:@"kMDItemKind == 'Application'"];
    _query.delegate = self;
    [_query startQuery];
    self.iconsContext = newFlyingIconsContext();
    setFlyingIconsContextCallback(self.iconsContext, iconCallback, (__bridge void *) self);
    [self performSelectorInBackground:@selector(getNextIcon) withObject:nil];
}

-(void)getNextIcon
{
    if(self.query.resultCount == 0)
    {
        [self performSelectorInBackground:@selector(getNextIcon) withObject:nil];
        return;
    }
    
    NSString *iconFilePath  = nil;
    
    while(!iconFilePath)
    {
        int r = ((float)rand()/(float)RAND_MAX) * (self.query.resultCount-1);
        NSMetadataItem *item = [self.query resultAtIndex:r];
        NSBundle *appBundle = [NSBundle bundleWithPath:[item valueForAttribute:@"kMDItemPath"]];
        NSDictionary *appInfo = [appBundle infoDictionary];
        NSString *iconFileName = [appInfo objectForKey:@"CFBundleIconFile"];
        if(iconFileName)
            iconFilePath = [appBundle pathForImageResource:iconFileName];
    }
    NSImage * iconImage = [[NSImage alloc] initWithContentsOfFile:iconFilePath];
    NSAssert(iconImage, @"");
    
    /*void * jumboImageBuffer = malloc(4 * 512 * 512);
    NSBitmapImageRep *bitmap = [[NSBitmapImageRep alloc] initWithBitmapDataPlanes:(unsigned char **)&jumboImageBuffer pixelsWide:512 pixelsHigh:512 bitsPerSample:8 samplesPerPixel:4 hasAlpha:YES isPlanar:NO colorSpaceName:NSCalibratedRGBColorSpace bytesPerRow:512*4 bitsPerPixel:32];
    NSGraphicsContext *gContext = [NSGraphicsContext graphicsContextWithBitmapImageRep:bitmap];
    [NSGraphicsContext setCurrentContext:gContext];
    [iconImage drawInRect:NSMakeRect(0.0, 0.0, 512.0, 512.0) fromRect:NSMakeRect(0.0, 0.0, [iconImage size].width, [iconImage size].height) operation:NSCompositeCopy fraction:1.0];
    self.nextJumboIcon = jumboImageBuffer;*/
    
    void * imageBuffer = malloc(4 * 128 * 128);
    NSBitmapImageRep *bitmap = [[NSBitmapImageRep alloc] initWithBitmapDataPlanes:(unsigned char **)&imageBuffer pixelsWide:128 pixelsHigh:128 bitsPerSample:8 samplesPerPixel:4 hasAlpha:YES isPlanar:NO colorSpaceName:NSCalibratedRGBColorSpace bytesPerRow:128*4 bitsPerPixel:32];
    NSGraphicsContext *gContext = [NSGraphicsContext graphicsContextWithBitmapImageRep:bitmap];
    [NSGraphicsContext setCurrentContext:gContext];
    [iconImage drawInRect:NSMakeRect(0.0, 0.0, 128.0, 128.0) fromRect:NSMakeRect(0.0, 0.0, [iconImage size].width, [iconImage size].height) operation:NSCompositeCopy fraction:1.0];
    self.nextIcon = imageBuffer;
}

struct flyingIconImage * iconCallback(void * callbackContext)
{
    FlyingIconsDriver * self = (__bridge FlyingIconsDriver *)callbackContext;
    if(!self.nextIcon)
        return 0;
    
    struct flyingIconImage * image = malloc(sizeof(struct flyingIconImage));
    
    image->width = 128;
    image->height = 128;
    image->imageBuffer=self.nextIcon;
    
    self.nextIcon = nil;
    self.nextSmallIcon = nil;
    self.nextSmallestIcon = nil;
    
    [self performSelectorInBackground:@selector(getNextIcon) withObject:nil];
    
    return image;
}

@end
