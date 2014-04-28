//
//  JIPDesign.h
//  JazzInParis
//
//  Created by Max on 14/04/14.
//  Copyright (c) 2014 Max. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface JIPDesign : NSObject

+ (void)      applyBackgroundWallpaperInTableView     :(UITableView*)tableView;
+ (UILabel *) emptyTableViewLabelWithString           :(NSString*)string;
+ (UILabel*)  emptyTableViewFilledLabelLabelWithString:(NSString*)string;
+ (UIButton*) emptyTableViewButtonWithString          :(NSString*)string;

@end
