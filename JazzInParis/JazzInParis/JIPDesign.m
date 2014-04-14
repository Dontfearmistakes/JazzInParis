//
//  JIPDesign.m
//  JazzInParis
//
//  Created by Max on 14/04/14.
//  Copyright (c) 2014 Max. All rights reserved.
//

#import "JIPDesign.h"

@implementation JIPDesign

//////////////////////////////////////////////////////////////////
+(void)applyBackgroundWallpaperInTableView:(UITableView*)tableView
{
    UIImageView *imageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"miles2.png"]];
    [tableView setBackgroundView:imageView];
}

@end
