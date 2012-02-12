//
//  FlyingIcons.h
//  FlyingIconsShell
//
//  Created by Colin Cornaby on 12/3/11.
//  Copyright (c) 2011 Consonance Software. All rights reserved.
//
#import <OpenGL/gl.h>
#include <unistd.h>
#include <sys/time.h>

#ifndef FlyingIconsShell_FlyingIcons_h
#define FlyingIconsShell_FlyingIcons_h


#endif

struct flyingIconImage
{
    void * imageBuffer;
    int width;
    int height;
};

struct flyingIcon
{
    GLuint textureID;
    int width;
    int height;
    float deltaX;
    float deltaY;
    struct timeval spawnTime;
    int twirl;
    struct flyingIcon *nextIcon;
};

struct flyingIconsContext
{
    struct timeval lastIconSpawnTime;
    int currentIconNum;
    struct flyingIcon *firstIcon;
    float xBias;
    int (*iconGetter)(void * context, struct flyingIconImage ** images);
    void * callbackContext;
};

typedef struct flyingIconsContext * flyingIconsContextPtr;


void drawFlyingIcons(flyingIconsContextPtr context, float hRes, float vRes);
flyingIconsContextPtr newFlyingIconsContext(void);
void setFlyingIconsContextCallback(flyingIconsContextPtr context, int (*callBack)(void * context, struct flyingIconImage ** images), void * callbackContext);
void destroyFlyingIconsContext(flyingIconsContextPtr context);