//
//  FlyingIconsMetalView.h
//  FlyingIcons
//
//  Created by Colin Cornaby on 12/30/19.
//  Copyright © 2019 Consonance Software. All rights reserved.
//

#import <MetalKit/MetalKit.h>
#import "FlyingIconsRendering.h"

NS_ASSUME_NONNULL_BEGIN

@interface FlyingIconsMetalView : MTKView <FlyingIconsRendering>

@end

NS_ASSUME_NONNULL_END
