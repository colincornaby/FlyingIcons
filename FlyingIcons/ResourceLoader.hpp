//
//  ResourceLoader.hpp
//  FlyingIconsShell Metal
//
//  Created by Colin Cornaby on 6/12/20.
//  Copyright © 2020 Consonance Software. All rights reserved.
//

#ifndef ResourceLoader_hpp
#define ResourceLoader_hpp

#include <stdio.h>
#include "FlyingIcons.h"
#import <map>

namespace FlyingIcons {
class ResourceLoader {
public:
    void updateForContext(struct flyingIconsContext *context);
    void * operator[](unsigned int index);
    void * (*resourceAllocator) (void * context, flyingIcon *icon);
    void (*resourceDeallocator) (void * context, void * resource);
    void * context;
private:
    std::map <unsigned int, void *> resources;
};
}

#endif /* ResourceLoader_hpp */
