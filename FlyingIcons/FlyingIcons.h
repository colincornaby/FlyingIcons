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
    void *userData;
};

typedef void(*iconConstructorCallbackRef)(struct flyingIcon *, struct flyingIconImage *, unsigned int, void *);
typedef void(*iconDestructorCallbackRef)(struct flyingIcon *, void *);

struct flyingIconsContext
{
    struct timeval lastIconSpawnTime;
    int currentIconNum;
    struct flyingIcon *firstIcon;
    float xBias;
    int (*iconGetter)(void * context, struct flyingIconImage ** images);
    void * callbackContext;
    void * constructorDestructorCallback;
    iconConstructorCallbackRef constructorCallback;
    iconDestructorCallbackRef destructorCallback;
    struct timeval currTime;
};
typedef struct flyingIconsContext * flyingIconsContextPtr;

void prepareContext(flyingIconsContextPtr context, struct timeval currTime);
void currentStateOfFlyingIcon(struct flyingIcon *icon, float *x, float *y, float *scale, float *rotation, float *alpha, flyingIconsContextPtr context);



flyingIconsContextPtr newFlyingIconsContext(void);
void setFlyingIconsContextCallback(flyingIconsContextPtr context, int (*callBack)(void * context, struct flyingIconImage ** images), void * callbackContext);
void destroyFlyingIconsContext(flyingIconsContextPtr context);
