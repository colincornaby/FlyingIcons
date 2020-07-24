//
//  FlyingIcons.cpp
//  FlyingIcons
//
//  Created by Colin Cornaby on 6/25/20.
//  Copyright © 2020 Consonance Software. All rights reserved.
//

#include "FlyingIcons.hpp"
#define timeUntilFadeIn 0.0f
#define fadeInTime 1500.0f
#define lifeTime 17000.0f
#define fadeOutTime 1500.0f

using namespace FlyingIcons;

FlyingIcon::FlyingIcon(float xBias, bool twirls, Image *image) {
    struct timeval spawnTime;
    gettimeofday(&spawnTime, NULL);
    gettimeofday(&spawnTime, NULL);
    this->spawnTime = spawnTime;
    float r = (float)rand()/(float)RAND_MAX;
    float iconAngle = r * 62.9f;
    r = (float)rand()/(float)RAND_MAX;
    float iconSpeed = (1.0f - (r * r)) * 0.05 + 0.0035;
    r = (float)rand()/(float)RAND_MAX;
    this->twirl = twirls;
    this->xVelocity = iconSpeed * cos(iconAngle) * xBias;
    this->yVelocity = iconSpeed * sin(iconAngle);
    this->image = image;
}

FlyingIcon::~FlyingIcon() {
    delete this->image;
}

void Context::prepare(struct timeval newTime) {
    this->currTime = newTime;
    std::vector<FlyingIcon *>::iterator it = this->icons.begin();
    while (it != this->icons.end())
    {
        FlyingIcon *icon = (*it);
        long seconds  = this->currTime.tv_sec  - icon->spawnTime.tv_sec;
        long useconds = this->currTime.tv_usec - icon->spawnTime.tv_usec;
        long iconLifeTime = ((seconds) * 1000 + useconds/1000.0) + 0.5;
        if(iconLifeTime>lifeTime)
        {
            it = this->icons.erase(it);
            delete icon;
        } else {
            ++it;
        }
    }
    
    long seconds  = currTime.tv_sec  - this->lastIconSpawnTime.tv_sec;
    long useconds = currTime.tv_usec - this->lastIconSpawnTime.tv_usec;
    
    long lastIconSpawnTime = ((seconds) * 1000 + useconds/1000.0) + 0.5;
    
    if(lastIconSpawnTime > lifeTime / this->numberOfIcons)
    {
        Image *iconImage = this->nextIconImage();
        if(iconImage != NULL) {
            float r = (float)rand()/(float)RAND_MAX;
            bool twirls = (r * (1.0f/this->rotationPercentage)) < 1.0f;
            FlyingIcon *newIcon = new FlyingIcon(this->xBias, twirls, iconImage);
            gettimeofday(&(this->lastIconSpawnTime), NULL);
            
            newIcon->identifier = numberOfCreatedIcons;
            this->numberOfCreatedIcons++;
            
            icons.insert(icons.begin(), newIcon);
        }
    }
}

Image::~Image(){
    
}

Context::Context() {
    this->rotationPercentage = 0.05;
    this->numberOfIcons = 22;
    this->numberOfCreatedIcons = 0;
    this->lastIconSpawnTime.tv_sec = 0;
    this->lastIconSpawnTime.tv_usec = 0;
}

void Context::currentStateOfFlyingIcon(FlyingIcon &icon, float *x, float *y, float *scale, float *rotation, float *alpha) {
    long seconds  = this->currTime.tv_sec  - icon.spawnTime.tv_sec;
    long useconds = this->currTime.tv_usec - icon.spawnTime.tv_usec;
    long iconLifeTime = ((seconds) * 1000 + useconds/1000.0) + 0.5;
    *x = icon.xVelocity * (iconLifeTime/1000.0f + 1.5f);
    *y = icon.yVelocity * (iconLifeTime/1000.0f + 1.5f);
    float iconLifePercentage = iconLifeTime/lifeTime;
    *scale = 0.2f + 1.0 * (iconLifePercentage);
    if(icon.twirl) {
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

void currentMatrixStateOfFlyingIcon(FlyingIcon &icon, simd_float4x4 *transform, float *alpha, FlyingIcons::Context &context) {

    float xPos, yPos, scale, rotation;
    context.currentStateOfFlyingIcon(icon, &xPos, &yPos, &scale, &rotation, alpha);
    rotation = (rotation/180.0f) * M_PI;
    
    *transform = matrix_identity_float4x4;
    
    matrix_float4x4 scaleMatrix = matrix_identity_float4x4;
    scaleMatrix.columns[0][0] = scale;
    scaleMatrix.columns[1][1] = scale;
    *transform = matrix_multiply(*transform, scaleMatrix);
    
    if(rotation != 0){
        matrix_float4x4 inverseTranslateMatrix = matrix_identity_float4x4;
        inverseTranslateMatrix.columns[3][2] = 1;
        matrix_float4x4 rotationMatrix = matrix_identity_float4x4;
        rotationMatrix.columns[0][0] = cosf(rotation);
        rotationMatrix.columns[0][1] = sinf(rotation);
        rotationMatrix.columns[1][0] = -sinf(rotation);
        rotationMatrix.columns[1][1] = cosf(rotation);
        *transform = matrix_multiply(*transform, rotationMatrix);
    }
    matrix_float4x4 translationMatrix = matrix_identity_float4x4;
    translationMatrix.columns[0][3] = xPos;
    translationMatrix.columns[1][3] = yPos;
    translationMatrix.columns[0][0] = 1.0/context.xBias;
    translationMatrix.columns[1][1] = 1.0;
    translationMatrix.columns[2][2] = 1.0;
    *transform = matrix_multiply(*transform, translationMatrix);
}
