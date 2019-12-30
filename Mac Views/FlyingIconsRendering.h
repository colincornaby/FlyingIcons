//
//  FlyingIconsRendering.h
//  FlyingIcons
//
//  Created by Colin Cornaby on 12/29/19.
//  Copyright © 2019 Consonance Software. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "FlyingIconsDriver.h"

NS_ASSUME_NONNULL_BEGIN

@protocol FlyingIconsRendering <NSObject>

@property FlyingIconsDriver *driver;

-(void)drawFlyingIconsContents;

@end

NS_ASSUME_NONNULL_END
