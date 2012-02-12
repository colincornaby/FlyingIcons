//
//  Flying_Icons_ScreensaverView.h
//  Flying Icons Screensaver
//
//  Created by Colin Cornaby on 12/4/11.
//  Copyright (c) 2011 Consonance Software. All rights reserved.
//

#import <ScreenSaver/ScreenSaver.h>
#import "FlyingIconsDriver.h"

@interface Flying_Icons_ScreensaverView : ScreenSaverView
{
    FlyingIconsDriver * _driver;
}
@property (retain) FlyingIconsDriver * driver;
@end
