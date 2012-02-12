//
//  FlyingIcons.c
//  FlyingIconsShell
//
//  Created by Colin Cornaby on 12/3/11.
//  Copyright (c) 2011 Consonance Software. All rights reserved.
//

#include "FlyingIcons.h"
#include <memory.h>
#include "stdlib.h"
#include "math.h"

#define timeUntilFadeIn 0.0f
#define fadeInTime 1500.0f
#define lifeTime 16000.0f
#define fadeOutTime 1500.0f
#define numIcons 22.0f

void addNewIcon(flyingIconsContextPtr context);
void destroyIcon(struct flyingIcon * icon);

void addNewIcon(flyingIconsContextPtr context)
{
    struct flyingIconImage * images;
    int iconCount = context->iconGetter(context->callbackContext, &images);
    if(iconCount)
    {
        struct flyingIcon * newIcon = malloc(sizeof(struct flyingIcon));
        glGenTextures(1, &(newIcon->textureID));
        glBindTexture(GL_TEXTURE_2D, newIcon->textureID);
        glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_WRAP_S, GL_REPEAT);
        glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_WRAP_T, GL_REPEAT);
        glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MAG_FILTER, GL_LINEAR_MIPMAP_LINEAR);
        glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MIN_FILTER, GL_LINEAR);
        int i = 0;
        for(i=0;i<iconCount;i++)
        {
            struct flyingIconImage iconEntry = images[i];
            glTexImage2D(GL_TEXTURE_2D, i, GL_RGBA8, iconEntry.width, iconEntry.height, 0, GL_RGBA, GL_UNSIGNED_BYTE, (const void *) iconEntry.imageBuffer);
            i++;
            free(iconEntry.imageBuffer);
        }
        free(images);
        context->currentIconNum++;
        struct timeval spawnTime;
        gettimeofday(&spawnTime, NULL);
        gettimeofday(&spawnTime, NULL);
        newIcon->spawnTime = spawnTime;
        newIcon->nextIcon = NULL;
        float r = (float)rand()/(float)RAND_MAX;
        float iconAngle = r * 62.9f;
        r = (float)rand()/(float)RAND_MAX;
        float iconSpeed = (1.0f - (r * r)) * 0.035 + 0.0035;
        r = (float)rand()/(float)RAND_MAX;
        newIcon->twirl = floor(r*40) == 1 ? 1 : 0;
        newIcon->deltaX = iconSpeed * cos(iconAngle) * context->xBias;
        newIcon->deltaY = iconSpeed * sin(iconAngle);
        if(context->firstIcon)
            newIcon->nextIcon = context->firstIcon;
        context->firstIcon = newIcon;
    }
}

void drawFlyingIcons(flyingIconsContextPtr context, float hRes, float vRes)
{
    
    glEnable(GL_TEXTURE_2D);
    
    context->xBias = hRes/vRes;
    
    struct timeval currTime;
    gettimeofday(&currTime, NULL);
    long seconds  = currTime.tv_sec  - context->lastIconSpawnTime.tv_sec;
    long useconds = currTime.tv_usec - context->lastIconSpawnTime.tv_usec;
    
    long lastIconSpawnTime = ((seconds) * 1000 + useconds/1000.0) + 0.5;
    
    if(lastIconSpawnTime > lifeTime / numIcons)
    {
        addNewIcon(context);
        gettimeofday(&(context->lastIconSpawnTime), NULL);
    }
    
    glClearColor(0.0, 0.0, 0.0, 1.0);
    
    glClear(GL_COLOR_BUFFER_BIT);
    
    glMatrixMode(GL_PROJECTION);
    glLoadIdentity();
    glViewport(0.0, 0.0, hRes, vRes);
    glOrtho(-1.0, 1.0, -1.0/(hRes/vRes), 1.0/(hRes/vRes), 1.0, -1.0);
    
    glMatrixMode(GL_MODELVIEW);
    glLoadIdentity();
    
    glBlendFunc(GL_SRC_ALPHA, GL_ONE_MINUS_SRC_ALPHA);
    glEnable(GL_BLEND);
    
    glEnableClientState(GL_VERTEX_ARRAY);
	glEnableClientState(GL_COLOR_ARRAY);
	glEnableClientState(GL_TEXTURE_COORD_ARRAY);
    
    glEnable(GL_BLEND);
    
    glBlendFunc(GL_SRC_ALPHA, GL_ONE_MINUS_SRC_ALPHA);
    
    
    
    glHint(GL_POINT_SMOOTH, GL_NICEST);
    
    glHint(GL_LINE_SMOOTH, GL_NICEST);
    
    glHint(GL_POLYGON_SMOOTH, GL_NICEST);
    
    
    
    glEnable(GL_POINT_SMOOTH);
    
    glEnable(GL_LINE_SMOOTH);
    
    glEnable(GL_POLYGON_SMOOTH);
    
    struct flyingIcon * icon = context->firstIcon;
    struct flyingIcon *lastIcon = NULL;
    
    while(icon!=NULL)
    {
        
        glPushMatrix();
        seconds  = currTime.tv_sec  - icon->spawnTime.tv_sec;
        useconds = currTime.tv_usec - icon->spawnTime.tv_usec;
        
        long iconLifeTime = ((seconds) * 1000 + useconds/1000.0) + 0.5;
        
        GLfloat opacity = 1.0;
        
        if(iconLifeTime<timeUntilFadeIn)
        {
            opacity = 0.0;
        }else if(iconLifeTime<timeUntilFadeIn+fadeInTime)
        {
            opacity=(iconLifeTime-timeUntilFadeIn)/fadeInTime;
            
        }else if(iconLifeTime>lifeTime)
        {
            context->currentIconNum=0;
            opacity=0;
        }else if(iconLifeTime>lifeTime-fadeOutTime)
        {
            opacity=(iconLifeTime-lifeTime)/-fadeOutTime;
        }
        
        float iconLifePercentage = iconLifeTime/lifeTime;
        
        float xPos = icon->deltaX * (iconLifeTime/1000.0f + 1.5f);
        float yPos = icon->deltaY * (iconLifeTime/1000.0f + 1.5f);
        float scale = 0.2f + 1.0 * (iconLifePercentage);
        
        glTranslatef(xPos, yPos, 0.0);
        
        if(icon->twirl)
        {
            glRotatef(iconLifeTime*0.1, 0.0, 0.0, 1.0);
        }
        glScalef(scale, scale, 0.0f);
        GLfloat vertices[] = {-0.1, 0.1, iconLifePercentage,  0.1,0.1, iconLifePercentage,  0.1, -0.1, iconLifePercentage,  -0.1, -0.1, iconLifePercentage};
        GLfloat texVertices[] = {0.0, 0.0,  1.0,0.0,  1.0, 1.0,  0.0, 1.0};
        
        GLfloat colors[] = {1.0, 1.0, 1.0, opacity,
        1.0, 1.0, 1.0, opacity,
        1.0, 1.0, 1.0, opacity,
        1.0, 1.0, 1.0, opacity};
        
        glVertexPointer(3, GL_FLOAT, 0, vertices);
        glColorPointer(4, GL_FLOAT, 0, colors);
        glTexCoordPointer(2, GL_FLOAT, 0, texVertices);
        
        glBindTexture(GL_TEXTURE_2D, icon->textureID);
        
        glDrawArrays(GL_QUADS, 0, 4);
    
        glPopMatrix();
        
        if(iconLifeTime>lifeTime)
        {
            if(lastIcon)
                lastIcon->nextIcon=NULL;
            destroyIcon(icon);
            icon=NULL;
        }else{
            lastIcon = icon;
            icon = icon->nextIcon;
        }
    }
    
    glDisableClientState(GL_VERTEX_ARRAY);
    glDisableClientState(GL_COLOR_ARRAY);
    glDisableClientState(GL_TEXTURE_COORD_ARRAY);
    
    glFlush();
}

flyingIconsContextPtr newFlyingIconsContext(void)
{
    flyingIconsContextPtr context = (flyingIconsContextPtr)malloc(sizeof(struct flyingIconsContext));
    context->currentIconNum = 0;
    context->firstIcon = NULL;
    context->iconGetter = NULL;
    gettimeofday(&(context->lastIconSpawnTime), NULL);
    return context;
}

void setFlyingIconsContextCallback(flyingIconsContextPtr context, int (*callBack)(void * context, struct flyingIconImage ** images), void * callbackContext)
{
    context->callbackContext = callbackContext;
    context->iconGetter = callBack;
}

void destroyIcon(struct flyingIcon * icon)
{
    glDeleteTextures(1, &(icon->textureID));
    free(icon);
}