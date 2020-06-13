//
//  ResourceLoader.cpp
//  FlyingIconsShell Metal
//
//  Created by Colin Cornaby on 6/12/20.
//  Copyright © 2020 Consonance Software. All rights reserved.
//

#include "ResourceLoader.hpp"

using namespace FlyingIcons;

void ResourceLoader::updateForContext(struct flyingIconsContext *iconsContext)
{
    std::map <unsigned int, void *> leftoverResources = resources;
    flyingIcon *icon = iconsContext->firstIcon;
    while(icon != NULL) {
        unsigned int identifier = icon->identifier;
        void * resource = resources[identifier];
        if(resource == NULL) {
            void * resource = resourceAllocator(context, icon);
            resources[identifier] = resource;
        } else {
            leftoverResources.erase(identifier);
        }
        
        icon = icon->nextIcon;
    }
    
    std::map<unsigned int, void *>::iterator iterator;
    for (iterator = leftoverResources.begin(); iterator != leftoverResources.end(); ++iterator) {
        resourceDeallocator(context, iterator->second);
        resources.erase(iterator->first);
    }
}

void * ResourceLoader::operator[](unsigned int index)
{
    return resources[index];
}
