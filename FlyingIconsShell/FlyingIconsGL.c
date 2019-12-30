//
//  FlyingIconsGL.c
//  FlyingIconsShell Metal
//
//  Created by Colin Cornaby on 10/19/18.
//  Copyright © 2018 Colin Cornaby. All rights reserved.
//

//This file was intentionally kept at OpenGL 1.X for compatibility. With tools moving on I'm considering moving this to 2.X. But portability to older Macs was important when this was written.

#include "FlyingIconsGL.h"
#include "FlyingIcons-Mac.h"
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
    glOrtho(-1.0, 1.0, -1.0, 1.0, 1.0, -1.0);
    
    glMatrixMode(GL_MODELVIEW);
    glLoadIdentity();
    
    glBlendFunc(GL_SRC_ALPHA, GL_ONE_MINUS_SRC_ALPHA);
    glEnable(GL_BLEND);
    
    glEnableClientState(GL_VERTEX_ARRAY);
    glEnableClientState(GL_COLOR_ARRAY);
    glEnableClientState(GL_TEXTURE_COORD_ARRAY);
    
    glBlendFunc(GL_SRC_ALPHA, GL_ONE_MINUS_SRC_ALPHA);
    
    glHint(GL_POINT_SMOOTH, GL_NICEST);
    
    glHint(GL_LINE_SMOOTH, GL_NICEST);
    
    glHint(GL_POLYGON_SMOOTH, GL_NICEST);
    
    struct timeval currTime;
    gettimeofday(&currTime, NULL);
    
    prepareContext(context, currTime);
    
    struct flyingIcon * icon = context->firstIcon;
    struct flyingIcon *lastIcon = NULL;
    
    while(icon!=NULL)
    {
        
        glPushMatrix();
        
        matrix_float4x4 transform;
        float alpha;
        currentMatrixStateOfFlyingIcon(icon, &transform, &alpha, context);
        //matrix_float4x4 is by column, OpenGL expects by row
        matrix_float4x4 transformByRow = matrix_transpose(transform);
        
        if(alpha != 0) {
            //manually setting the gl matrix
            //the Metal version uses a vertex shader to apply the matrix
            //we'll stick to old school GL here
            glMatrixMode(GL_MODELVIEW);
            glLoadIdentity();
            glMultMatrixf((float *) &transformByRow);
            
            GLfloat vertices[] = {-0.1, 0.1, 0.0,
                0.1,0.1, 0.0,
                0.1, -0.1, 0.0,
                -0.1, -0.1, 0.0};
            GLfloat texVertices[] = {0.0, 0.0,
                1.0,0.0,
                1.0, 1.0,
                0.0, 1.0};
            
            GLfloat colors[] = {1.0, 1.0, 1.0, (GLfloat)alpha,
                1.0, 1.0, 1.0, (GLfloat)alpha,
                1.0, 1.0, 1.0, (GLfloat)alpha,
                1.0, 1.0, 1.0, (GLfloat)alpha};
            
            glVertexPointer(3, GL_FLOAT, 0, vertices);
            glColorPointer(4, GL_FLOAT, 0, colors);
            glTexCoordPointer(2, GL_FLOAT, 0, texVertices);
            
            glBindTexture(GL_TEXTURE_2D, (GLuint)icon->userData);
            
            glDrawArrays(GL_QUADS, 0, 4);
            
            
        }
        lastIcon = icon;
        icon = icon->nextIcon;
        glPopMatrix();
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
