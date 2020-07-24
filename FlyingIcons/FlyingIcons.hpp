//
//  FlyingIcons.hpp
//  FlyingIcons
//
//  Created by Colin Cornaby on 6/25/20.
//  Copyright © 2020 Consonance Software. All rights reserved.
//

#ifndef FlyingIcons_hpp
#define FlyingIcons_hpp

#include <stdio.h>
#import <vector>
#include <sys/time.h>
#import <simd/simd.h>

using namespace std;

namespace FlyingIcons {

class Image {
public:
    virtual void copyBitmapData(void * buffer) = 0;
    int width;
    int height;
    virtual ~Image();
};

class FlyingIcon {
public:
    virtual ~FlyingIcon();
    Image *image;
    struct timeval spawnTime;
    FlyingIcon(float xBias, bool twirls, Image *image);
    unsigned int identifier;
    float xVelocity;
    float yVelocity;
    bool twirl;
private:
};

class Context {
public:
    Context();
    float xBias;
    float rotationPercentage;
    unsigned int numberOfIcons;
    void currentStateOfFlyingIcon(FlyingIcon &icon, float *x, float *y, float *scale, float *rotation, float *alpha);
    void prepare(struct timeval currtime);
    vector<FlyingIcon *> icons;
protected:
    virtual Image * nextIconImage() = 0;
private:
    struct timeval currTime;
    unsigned int numberOfCreatedIcons;
    struct timeval lastIconSpawnTime;
};

}

void currentMatrixStateOfFlyingIcon(FlyingIcons::FlyingIcon &icon, simd_float4x4 *transform, float *alpha, FlyingIcons::Context &context);




#endif /* FlyingIcons_hpp */
