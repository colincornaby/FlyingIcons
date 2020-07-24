//
//  FlyingIconsRendering.h
//  FlyingIcons
//
//  Created by Colin Cornaby on 12/29/19.
//  Copyright © 2019 Consonance Software. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "FlyingIconsContext.h"

NS_ASSUME_NONNULL_BEGIN

@protocol FlyingIconsRendering <NSObject>

@property (retain) FlyingIconsContext *context;

-(void)drawFlyingIconsContents;

@end

NS_ASSUME_NONNULL_END
