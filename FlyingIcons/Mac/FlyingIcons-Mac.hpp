//
//  FlyingIcons-Mac.h
//  FlyingIcons
//
//  Created by Colin Cornaby on 12/29/19.
//  Copyright © 2019 Consonance Software. All rights reserved.
//

#ifndef FlyingIcons_Mac_h
#define FlyingIcons_Mac_h

#include <stdio.h>
#include "FlyingIcons.hpp"
#import "FlyingIconsDriver.h"

using namespace FlyingIcons;

namespace FlyingIcons {
    class MacFlyingIconsContext: public FlyingIconsContext {
    public:
        MacFlyingIconsContext();
        ~MacFlyingIconsContext();
        virtual FlyingIconImage * nextIconImage();
    private:
        FlyingIconsDriver *driver;
    };

    class MacFlyingIconImage: public FlyingIconImage {
    public:
        virtual void * bitmapData();
        MacFlyingIconImage(NSImage *image);
        virtual ~MacFlyingIconImage();
    protected:
    private:
        NSBitmapImageRep *imageRep;
    };
}


#endif /* FlyingIcons_Mac_h */
