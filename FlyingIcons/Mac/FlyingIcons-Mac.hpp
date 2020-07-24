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
    class MacContext: public Context {
    public:
        MacContext();
        ~MacContext();
        virtual Image * nextIconImage();
    private:
        FlyingIconsDriver *driver;
    };

    class MacImage: public Image {
    public:
        virtual void copyBitmapData(void * buffer);
        MacImage(NSImage *image);
        virtual ~MacImage();
    protected:
    private:
        NSImageRep *imageRep;
    };
}


#endif /* FlyingIcons_Mac_h */
