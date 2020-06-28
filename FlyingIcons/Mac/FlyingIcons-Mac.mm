//
//  FlyingIcons-Mac.c
//  FlyingIcons
//
//  Created by Colin Cornaby on 12/29/19.
//  Copyright © 2019 Consonance Software. All rights reserved.
//

#include "FlyingIcons-Mac.hpp"

using namespace FlyingIcons;



MacFlyingIconsContext::MacFlyingIconsContext() {
    this->driver = [[FlyingIconsDriver alloc] init];
    [this->driver start];
}

FlyingIconImage * MacFlyingIconsContext::nextIconImage() {
    NSImage *nextImage = [this->driver nextIconIfAvailable];
    if(nextImage != nil){
        return new MacFlyingIconImage(nextImage);
    }
    return nil;
}

MacFlyingIconsContext::~MacFlyingIconsContext() {
    //[this->driver stop];
}

MacFlyingIconImage::MacFlyingIconImage(NSImage *image) {
    NSBitmapImageRep *rep = ((NSBitmapImageRep *)[image bestRepresentationForRect:NSMakeRect(0, 0, 512, 512) context:nil hints:nil]);
    this->width = rep.pixelsWide;
    this->height = rep.pixelsHigh;
    this->imageRep = rep;
}

void * MacFlyingIconImage::bitmapData() {
    void * bitmapData = this->imageRep.bitmapData;
    return bitmapData;
}

MacFlyingIconImage::~MacFlyingIconImage()
{
    this->imageRep = nil;
}
