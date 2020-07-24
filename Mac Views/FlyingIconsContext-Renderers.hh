//
//  FlyingIconsContext-Renderers.h
//  FlyingIcons
//
//  Created by Colin Cornaby on 6/29/20.
//  Copyright © 2020 Consonance Software. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "FlyingIconsContext.h"
#import "FlyingIcons-Mac.hpp"

NS_ASSUME_NONNULL_BEGIN

@interface FlyingIconsContext ()

@property (readonly) FlyingIcons::MacContext &renderingContext;

@end

NS_ASSUME_NONNULL_END
