//
//  ConfigurationWindowController.h
//  FlyingIcons
//
//  Created by Colin Cornaby on 6/13/20.
//  Copyright © 2020 Consonance Software. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "FlyingIconsContext.h"

NS_ASSUME_NONNULL_BEGIN

@interface ConfigurationWindowController : NSWindowController

@property (retain) FlyingIconsContext * context;

@end

NS_ASSUME_NONNULL_END
