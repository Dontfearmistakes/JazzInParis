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
    UIImageView *imageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"milesDavisBackground.png"]];
    [tableView setBackgroundView:imageView];
}




//////////////////////////////////////////////////////////////////
// To show in case no upcoming concerts or no favorite artist
//////////////////////////////////////////////////////////////////
+(UILabel*)emptyTableViewLabelWithString:(NSString*)string
{
    UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(20, 30, 280, 40)];
    label.text     = string;
    label.textColor= [UIColor whiteColor];
    label.textAlignment = NSTextAlignmentCenter;
    return label;
}


+(UIButton*)emptyTableViewButtonWithString:(NSString*)string
{
    UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
    [button setTitle:string forState:UIControlStateNormal];
    button.titleLabel.font = [UIFont boldSystemFontOfSize:20];
    button.frame = CGRectMake(20.0, 80.0, 280.0, 40.0);
    button.backgroundColor = Rgb2UIColorWithAlpha(49,49,49,0.7);
    button.layer.cornerRadius = 8;
    button.layer.borderWidth = 1;
    button.layer.borderColor = [UIColor grayColor].CGColor;
    button.clipsToBounds = YES;
    return button;
}



//////////////////////////////////////////////////////////////////

@end
