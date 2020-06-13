//
//  FlyingIcons.h
//  FlyingIconsShell
//
//  Created by Colin Cornaby on 12/3/11.

#include <unistd.h>
#include <sys/time.h>

#ifndef FlyingIconsShell_FlyingIcons_h
#define FlyingIconsShell_FlyingIcons_h


#endif

#ifdef __cplusplus
extern "C" {
#endif

struct flyingIconImage
{
    void * imageBuffer;
    int width;
    int height;
};

struct flyingIcon
{
    int width;
    int height;
    float deltaX;
    float deltaY;
    struct timeval spawnTime;
    int twirl;
    struct flyingIcon *nextIcon;
    unsigned int identifier;
    void *bitmapData;
};

struct flyingIconsContext
{
    struct timeval lastIconSpawnTime;
    int currentIconNum;
    struct flyingIcon *firstIcon;
    float xBias;
    struct flyingIconImage * (*iconGetter)(void * context);
    void * callbackContext;
    void * constructorDestructorCallback;
    struct timeval currTime;
};
typedef struct flyingIconsContext * flyingIconsContextPtr;

void prepareContext(flyingIconsContextPtr context, struct timeval currTime);
void currentStateOfFlyingIcon(struct flyingIcon *icon, float *x, float *y, float *scale, float *rotation, float *alpha, flyingIconsContextPtr context);



flyingIconsContextPtr newFlyingIconsContext(void);
void setFlyingIconsContextCallback(flyingIconsContextPtr   context, struct flyingIconImage * (*callBack)(void * context), void * callbackContext);
void destroyFlyingIconsContext(flyingIconsContextPtr context);

#ifdef __cplusplus
}
#endif
