//
//  UIImage+Resize.m
//  JazzInParis
//
//  Created by Max on 21/04/14.
//  Copyright (c) 2014 Max. All rights reserved.
//

#import "UIImage+Resize.h"

@implementation UIImage (Resize)


+ (UIImage*)imageWithImage:(UIImage*)image
              scaledToSize:(CGSize)newSize
{
    UIGraphicsBeginImageContext( newSize );
    [image drawInRect:CGRectMake(0,0,newSize.width,newSize.height)];
    UIImage* newImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    return newImage;
}

@end
