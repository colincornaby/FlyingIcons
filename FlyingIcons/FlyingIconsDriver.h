//
//  FlyingIconsDriver.h
//  FlyingIconsShell
//
//  Created by Colin Cornaby on 12/4/11.

/* Copyright 2011 Colin Cornaby. All rights reserved.
 */

#import <Foundation/Foundation.h>
#import "FlyingIconsGL.h"

@interface FlyingIconsDriver : NSObject <NSMetadataQueryDelegate>


@property          flyingIconsContextPtr   iconsContext;
@property                NSMetadataQuery * query;
@property                           void //* nextJumboIcon,
                                         * nextIcon,
                                         * nextSmallIcon,
                                         * nextSmallestIcon;

-(void) start;

@end
