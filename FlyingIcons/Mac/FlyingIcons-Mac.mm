//
//  FlyingIcons-Mac.c
//  FlyingIcons
//
//  Created by Colin Cornaby on 12/29/19.
//  Copyright © 2019 Consonance Software. All rights reserved.
//

#include "FlyingIcons-Mac.hpp"

using namespace FlyingIcons;



MacContext::MacContext() {
    this->driver = [[FlyingIconsDriver alloc] init];
    [this->driver start];
}

Image * MacContext::nextIconImage() {
    NSImage *nextImage = [this->driver nextIconIfAvailable];
    if(nextImage != nil){
        return new MacImage(nextImage);
    }
    return nil;
}

MacContext::~MacContext() {
    //[this->driver stop];
}

MacImage::MacImage(NSImage *image) {
    this->imageRep = [image bestRepresentationForRect:NSMakeRect(0, 0, 256, 256) context:nil hints:nil];
    this->width = (int) this->imageRep.pixelsWide;
    this->height = (int) this->imageRep.pixelsHigh;
}

void MacImage::copyBitmapData(void * buffer) {
    CGContextRef cgContext = CGBitmapContextCreate(buffer, this->width, this->height, 8, 4 * this->width, CGColorSpaceCreateDeviceRGB(), kCGImageAlphaPremultipliedLast);
    NSGraphicsContext *context = [NSGraphicsContext graphicsContextWithCGContext:cgContext flipped:NO];
    [context saveGraphicsState];
    [NSGraphicsContext setCurrentContext:context];
    [this->imageRep drawInRect:NSMakeRect(0, 0, this->width, this->height)
                      fromRect:NSMakeRect(0,0, imageRep.size.width, imageRep.size.height)
                     operation:NSCompositeCopy
                      fraction:1.0
                respectFlipped:YES
                         hints:@{NSImageHintInterpolation: @(NSImageInterpolationNone)}];
    [context restoreGraphicsState];
    CGContextRelease(cgContext);
}

MacImage::~MacImage()
{
    this->imageRep = nil;
}
