//
//  FlyingIconsContext.m
//  FlyingIcons
//
//  Created by Colin Cornaby on 6/29/20.
//  Copyright © 2020 Consonance Software. All rights reserved.
//

#import "FlyingIconsContext-Renderers.hh"

@implementation FlyingIconsContext


-(void)setRotationPercentage:(float)rotationPercentage
{
    self.renderingContext.rotationPercentage = rotationPercentage;
}

-(float)rotationPercentage
{
    return self.renderingContext.rotationPercentage;
}

-(void)setNumberOfIcons:(unsigned int)numberOfIcons
{
    self.renderingContext.numberOfIcons = numberOfIcons;
}

-(unsigned int)numberOfIcons
{
    return self.renderingContext.numberOfIcons;
}
@end
