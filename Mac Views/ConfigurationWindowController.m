//
//  ConfigurationWindowController.m
//  FlyingIcons
//
//  Created by Colin Cornaby on 6/13/20.
//  Copyright © 2020 Consonance Software. All rights reserved.
//

#import "ConfigurationWindowController.h"

@interface ConfigurationWindowController ()

@end

@implementation ConfigurationWindowController

- (void)windowDidLoad {
    [super windowDidLoad];
    
    // Implement this method to handle any initialization after your window controller's window has been loaded from its nib file.
}

-(void)setRotationPercentage:(float)rotationPercentage
{
    //self.context->rotationPercentage = rotationPercentage;
}

-(float)rotationPercentage
{
    return 0;//self.context->rotationPercentage;
}

-(void)setNumberOfIcons:(unsigned int)numberOfIcons
{
    //self.context->numberOfIcons = numberOfIcons;
}

-(unsigned int)numberOfIcons
{
    return 0;//self.context->numberOfIcons;
}

@end
