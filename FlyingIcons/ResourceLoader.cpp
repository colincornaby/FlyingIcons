//
//  ResourceLoader.cpp
//  FlyingIconsShell Metal
//
//  Created by Colin Cornaby on 6/12/20.
//  Copyright © 2020 Consonance Software. All rights reserved.
//

#include "ResourceLoader.hpp"

using namespace FlyingIcons;

void ResourceLoader::updateForContext(const FlyingIconsContext &context)
{
    std::map <unsigned int, void *> leftoverResources = resources;
    for (std::vector<FlyingIcon * const>::iterator it = context.icons.begin() ; it != context.icons.end(); ++it)
    {
        FlyingIcon *icon = (*it);
        unsigned int identifier = icon->identifier;
        void * resource = resources[identifier];
        if(resource == NULL) {
            void * resource = resourceAllocator(this->context, *icon);
            resources[identifier] = resource;
        } else {
            leftoverResources.erase(identifier);
        }
    }
    
    std::map<unsigned int, void *>::iterator iterator;
    for (iterator = leftoverResources.begin(); iterator != leftoverResources.end(); ++iterator) {
        resourceDeallocator(this->context, iterator->second);
        resources.erase(iterator->first);
    }
}

void * ResourceLoader::operator[](unsigned int index)
{
    return resources[index];
}
