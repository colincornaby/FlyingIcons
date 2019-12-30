//
//  FlyingIcons-Mac.h
//  FlyingIcons
//
//  Created by Colin Cornaby on 12/29/19.
//  Copyright © 2019 Consonance Software. All rights reserved.
//

#ifndef FlyingIcons_Mac_h
#define FlyingIcons_Mac_h

#include <stdio.h>
#include "FlyingIcons.h"
#import <simd/simd.h>

void currentMatrixStateOfFlyingIcon(struct flyingIcon *icon, matrix_float4x4 *transform, float *alpha, flyingIconsContextPtr context);

#endif /* FlyingIcons_Mac_h */
