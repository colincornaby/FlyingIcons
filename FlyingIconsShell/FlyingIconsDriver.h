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


@property          flyingIconsContextPtr   iconsContext;
@property                NSOpenGLContext * glContext;
@property                NSMetadataQuery * query;
@property                           void * nextIcon,
                                         * nextSmallIcon,
                                         * nextSmallestIcon;
@property (assign) IBOutlet NSOpenGLView * glView;

-(void) start;
-(void) draw;

@end
