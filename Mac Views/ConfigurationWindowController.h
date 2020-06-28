//
//  ConfigurationWindowController.h
//  FlyingIcons
//
//  Created by Colin Cornaby on 6/13/20.
//  Copyright © 2020 Consonance Software. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "FlyingIcons.h"

NS_ASSUME_NONNULL_BEGIN

@interface ConfigurationWindowController : NSWindowController

@property struct flyingIconsContext * context;

@property float rotationPercentage;
@property unsigned int numberOfIcons;

@end

NS_ASSUME_NONNULL_END
