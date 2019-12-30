//
//  FlyingIcons-Mac.c
//  FlyingIcons
//
//  Created by Colin Cornaby on 12/29/19.
//  Copyright © 2019 Consonance Software. All rights reserved.
//

#include "FlyingIcons-Mac.h"

//Putting anything that depends on simd out in this file. This project isn't being built for any other system,
//but could find a platform neutral vector library.

void currentMatrixStateOfFlyingIcon(struct flyingIcon *icon, matrix_float4x4 *transform, float *alpha, flyingIconsContextPtr context) {

    float xPos, yPos, scale, rotation;
    currentStateOfFlyingIcon(icon, &xPos, &yPos, &scale, &rotation, alpha, context);
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
    translationMatrix.columns[0][0] = 1.0/context->xBias;
    translationMatrix.columns[1][1] = 1.0;
    translationMatrix.columns[2][2] = 1.0;
    *transform = matrix_multiply(*transform, translationMatrix);
}

