//
//  FlyingIconsMetalRenderer.h
//  FlyingIconsShell Metal
//
//  Created by Colin Cornaby on 12/30/19.
//  Copyright © 2019 Consonance Software. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <Metal/Metal.h>
#import "FlyingIcons.hpp"

NS_ASSUME_NONNULL_BEGIN

@interface FlyingIconsMetalRenderer : NSObject

@property FlyingIcons::FlyingIconsContext *context;

-(id)init NS_UNAVAILABLE;
-(id)initWithDevice:(id<MTLDevice>)device;
-(void)render:(MTLRenderPassDescriptor *)renderPassDescriptor commandBuffer:(id<MTLCommandBuffer>)commandBuffer;

@end

NS_ASSUME_NONNULL_END
