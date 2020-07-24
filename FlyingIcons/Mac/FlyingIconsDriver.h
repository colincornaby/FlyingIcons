//
//  FlyingIconsDriver.h
//  FlyingIconsShell
//
//  Created by Colin Cornaby on 12/4/11.

/* Copyright 2011 Colin Cornaby. All rights reserved.
 */

#import <Foundation/Foundation.h>
#import "FlyingIcons.h"

@interface FlyingIconsDriver : NSObject <NSMetadataQueryDelegate>

@property                NSMetadataQuery * query;
@property                NSImage * nextIcon;

-(NSImage *)nextIconIfAvailable;
-(void) start;

@end
