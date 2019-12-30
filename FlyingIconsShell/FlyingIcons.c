//
//  FlyingIcons.c
//  FlyingIconsShell
//
//  Created by Colin Cornaby on 12/3/11.

/* Copyright 2011 Colin Cornaby. All rights reserved.
 * All rights reserved.
 * 
 * Redistribution and use in source and binary forms, with or without
 * modification, are permitted provided that the following conditions
 * are met:
 * 
 * Redistributions of source code must retain the above copyright notice,
 * this list of conditions and the following disclaimer.
 * 
 * Redistributions in binary form must reproduce the above copyright
 * notice, this list of conditions and the following disclaimer in the
 * documentation and/or other materials provided with the distribution.
 * 
 * Neither the name of the project's author nor the names of its
 * contributors may be used to endorse or promote products derived from
 * this software without specific prior written permission.
 * 
 * THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS
 * "AS IS" AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT
 * LIMITED TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS
 * FOR A PARTICULAR PURPOSE ARE DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT
 * HOLDER OR CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL,
 * SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED
 * TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR
 * PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF
 * LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING
 * NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS
 * SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
 *
 */

#include "FlyingIcons.h"
#include <memory.h>
#include "stdlib.h"
#include "math.h"

#define timeUntilFadeIn 0.0f
#define fadeInTime 1500.0f
#define lifeTime 17000.0f
#define fadeOutTime 1500.0f
#define numIcons 22.0f

void addNewIcon(flyingIconsContextPtr context);
void destroyIcon(struct flyingIcon * icon, flyingIconsContextPtr context);

void prepareContext(flyingIconsContextPtr context, struct timeval currTime)
{
    context->currTime = currTime;
    
    //delete old icons
    struct flyingIcon * icon = context->firstIcon;
    struct flyingIcon *lastIcon = NULL;
    
    while(icon!=NULL)
    {
        long seconds  = context->currTime.tv_sec  - icon->spawnTime.tv_sec;
        long useconds = context->currTime.tv_usec - icon->spawnTime.tv_usec;
        long iconLifeTime = ((seconds) * 1000 + useconds/1000.0) + 0.5;
        if(iconLifeTime>lifeTime)
        {
            if(lastIcon)
                lastIcon->nextIcon=icon->nextIcon;
                
            struct flyingIcon * nextIcon = icon->nextIcon;
            destroyIcon(icon, context);
            icon = nextIcon;
        } else {
            lastIcon = icon;
            icon = icon->nextIcon;
        }
    }
    
    long seconds  = currTime.tv_sec  - context->lastIconSpawnTime.tv_sec;
    long useconds = currTime.tv_usec - context->lastIconSpawnTime.tv_usec;
    
    long lastIconSpawnTime = ((seconds) * 1000 + useconds/1000.0) + 0.5;
    
    if(lastIconSpawnTime > lifeTime / numIcons)
    {
        addNewIcon(context);
        gettimeofday(&(context->lastIconSpawnTime), NULL);
    }
}


flyingIconsContextPtr newFlyingIconsContext(void) {
    flyingIconsContextPtr context = (flyingIconsContextPtr)malloc(sizeof(struct flyingIconsContext));
    context->currentIconNum = 0;
    context->firstIcon = NULL;
    context->iconGetter = NULL;
    gettimeofday(&(context->lastIconSpawnTime), NULL);
    return context;
}

void setFlyingIconsContextCallback(flyingIconsContextPtr   context,
                                    int (*callBack)(void * context, struct flyingIconImage ** images),
                                                    void * callbackContext) {
    context->callbackContext = callbackContext;
    context->iconGetter = callBack;
}

void destroyIcon(struct flyingIcon * icon, flyingIconsContextPtr context)      {
    context->destructorCallback(icon, context->constructorDestructorCallback);
    free(icon);
}

struct flyingIcon * createFlyingIcon(float xBias);

void addNewIcon(flyingIconsContextPtr context)  {
    struct flyingIconImage * images;
    int iconCount = context->iconGetter(context->callbackContext, &images);
    if(iconCount)
    {
        struct flyingIcon * newIcon = createFlyingIcon(context->xBias);
        context->constructorCallback(newIcon, images, iconCount, context->constructorDestructorCallback);
        free(images);
        context->currentIconNum++;
        newIcon->nextIcon = NULL;
        struct timeval spawnTime;
        gettimeofday(&spawnTime, NULL);
        newIcon->spawnTime = spawnTime;
        if(context->firstIcon)
            newIcon->nextIcon = context->firstIcon;
        context->firstIcon = newIcon;
    }
}

struct flyingIcon * createFlyingIcon(float xBias) {
    struct flyingIcon *icon = malloc(sizeof(struct flyingIcon));
    struct timeval spawnTime;
    gettimeofday(&spawnTime, NULL);
    gettimeofday(&spawnTime, NULL);
    icon->spawnTime = spawnTime;
    float r = (float)rand()/(float)RAND_MAX;
    float iconAngle = r * 62.9f;
    r = (float)rand()/(float)RAND_MAX;
    float iconSpeed = (1.0f - (r * r)) * 0.05 + 0.0035;
    r = (float)rand()/(float)RAND_MAX;
    icon->twirl = (r * 25.0f) < 1.0f;
    icon->deltaX = iconSpeed * cos(iconAngle) * xBias;
    icon->deltaY = iconSpeed * sin(iconAngle);
    return icon;
}

void currentStateOfFlyingIcon(struct flyingIcon *icon, float *x, float *y, float *scale, float *rotation, float *alpha, flyingIconsContextPtr context) {
    long seconds  = context->currTime.tv_sec  - icon->spawnTime.tv_sec;
    long useconds = context->currTime.tv_usec - icon->spawnTime.tv_usec;
    long iconLifeTime = ((seconds) * 1000 + useconds/1000.0) + 0.5;
    *x = icon->deltaX * (iconLifeTime/1000.0f + 1.5f);
    *y = icon->deltaY * (iconLifeTime/1000.0f + 1.5f);
    float iconLifePercentage = iconLifeTime/lifeTime;
    *scale = 0.2f + 1.0 * (iconLifePercentage);
    if(icon->twirl) {
        *rotation = iconLifeTime*0.1;
    } else {
        *rotation = 0.0;
    }
    if(iconLifeTime<timeUntilFadeIn)
    {
        *alpha = 0.0;
    }else if(iconLifeTime<timeUntilFadeIn+fadeInTime)
    {
        float localAlpha = (iconLifeTime-timeUntilFadeIn)/fadeInTime;
        *alpha=localAlpha;
        
    }else if(iconLifeTime>lifeTime)
    {
        *alpha=0;
    }else if(iconLifeTime>lifeTime-fadeOutTime)
    {
        *alpha=(iconLifeTime-lifeTime)/-fadeOutTime;
    } else {
        *alpha = 1.0f;
    }
}
