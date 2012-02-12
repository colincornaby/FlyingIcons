//
//  FlyingIconsDriver.h
//  FlyingIconsShell
//
//  Created by Colin Cornaby on 12/4/11.
//  Copyright (c) 2011 Consonance Software. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "FlyingIcons.h"

@interface FlyingIconsDriver : NSObject <NSMetadataQueryDelegate>
{
    NSOpenGLContext * _glContext;
    NSMetadataQuery *_query;
    NSOpenGLView *_glView;
    void *_nextIcon;
    void *_nextSmallIcon;
    void *_nextSmallestIcon;
    flyingIconsContextPtr _iconsContext;
}
@property (retain) NSOpenGLContext * glContext;
@property (retain) NSMetadataQuery *query;
@property (retain) IBOutlet NSOpenGLView *glView;
@property void *nextIcon;
@property void *nextSmallIcon;
@property void *nextSmallestIcon;
@property flyingIconsContextPtr iconsContext;

-(void)start;
-(void)draw;

@end
