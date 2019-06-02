//
//  FlyingIconsGL.c
//  FlyingIconsShell Metal
//
//  Created by Colin Cornaby on 10/19/18.
//  Copyright © 2018 Consonance Software. All rights reserved.
//

#include "FlyingIconsGL.h"
#include "FlyingIcons.h"
#include <memory.h>
#import <OpenGL/gl.h>

void iconConstructor(struct flyingIcon *icon, struct flyingIconImage * images, unsigned int imageCount, void *context);
void iconDestructor(struct flyingIcon *icon, void *context);

void drawFlyingIcons(flyingIconsContextPtr context, float hRes, float vRes) {
    context->constructorCallback = &iconConstructor;
    context->destructorCallback = &iconDestructor;
    
    glEnable(GL_TEXTURE_2D);
    
    context->xBias = hRes/vRes;
    
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
    
    struct timeval currTime;
    gettimeofday(&currTime, NULL);
    
    prepareContext(context, currTime);
    
    //glEnable(GL_POINT_SMOOTH);
    
    //glEnable(GL_LINE_SMOOTH);
    
    //glEnable(GL_POLYGON_SMOOTH);
    
    struct flyingIcon * icon = context->firstIcon;
    struct flyingIcon *lastIcon = NULL;
    
    while(icon!=NULL)
    {
        
        glPushMatrix();
        //we use the iconLifeTime to determine the z positioning
        long iconSpawnTime = ((icon->spawnTime.tv_sec) * 1000 + icon->spawnTime.tv_usec/1000.0) + 0.5;
        
        float xPos, yPos, scale, rotation, alpha;
        currentStateOfFlyingIcon(icon, &xPos, &yPos, &scale, &rotation, &alpha, context);
        
        if(alpha != 0) {
            glTranslatef(xPos, yPos, 0.0);
            
            if(rotation!=0)
            {
                glRotatef((GLfloat) rotation, 0.0, 0.0, 1.0);
            }
            glScalef(scale, scale, 0.0f);
            
            GLfloat vertices[] = {-0.1, 0.1, (GLfloat) -iconSpawnTime,  0.1,0.1, (GLfloat) -iconSpawnTime,  0.1, -0.1, (GLfloat) -iconSpawnTime,  -0.1, -0.1, (GLfloat) -iconSpawnTime};
            GLfloat texVertices[] = {0.0, 0.0,  1.0,0.0,  1.0, 1.0,  0.0, 1.0};
            
            GLfloat colors[] = {1.0, 1.0, 1.0, (GLfloat)alpha,
                1.0, 1.0, 1.0, (GLfloat)alpha,
                1.0, 1.0, 1.0, (GLfloat)alpha,
                1.0, 1.0, 1.0, (GLfloat)alpha};
            
            glVertexPointer(3, GL_FLOAT, 0, vertices);
            glColorPointer(4, GL_FLOAT, 0, colors);
            glTexCoordPointer(2, GL_FLOAT, 0, texVertices);
            
            glBindTexture(GL_TEXTURE_2D, (GLuint)icon->userData);
            
            glDrawArrays(GL_QUADS, 0, 4);
            
            glPopMatrix();
        }
        lastIcon = icon;
        icon = icon->nextIcon;
    }
    
    glDisableClientState(GL_VERTEX_ARRAY);
    glDisableClientState(GL_COLOR_ARRAY);
    glDisableClientState(GL_TEXTURE_COORD_ARRAY);
    
    glFlush();
}

void iconConstructor(struct flyingIcon *icon, struct flyingIconImage * images, unsigned int imageCount, void *context) {
    glGenTextures(1, (GLuint *)&(icon->userData));
    glBindTexture(GL_TEXTURE_2D, (GLuint)icon->userData);
    glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_WRAP_S, GL_REPEAT);
    glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_WRAP_T, GL_REPEAT);
    glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MAG_FILTER, GL_LINEAR_MIPMAP_LINEAR);
    glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MIN_FILTER, GL_LINEAR);
    int i = 0;
    for(i=0;i<imageCount;i++)
    {
        struct flyingIconImage iconEntry = images[i];
        glTexImage2D(GL_TEXTURE_2D, i, GL_RGBA8, iconEntry.width, iconEntry.height, 0, GL_RGBA, GL_UNSIGNED_BYTE, (const void *) iconEntry.imageBuffer);
        i++;
        //            if (iconEntry.imageBuffer != NULL) free(iconEntry.imageBuffer);
    }
}


void iconDestructor(struct flyingIcon *icon, void *context) {
    GLuint textureID = (GLuint) icon->userData;
    glDeleteTextures(1, &textureID);
}
