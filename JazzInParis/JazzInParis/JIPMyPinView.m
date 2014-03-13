//
//  JIPMyPinView.m
//  JazzInParis
//
//  Created by Max on 10/02/14.
//  Copyright (c) 2014 Max. All rights reserved.
//

#import "JIPMyPinView.h"

@implementation JIPMyPinView

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
        self.animatesDrop = YES;
        self.pinColor = MKPinAnnotationColorPurple;
    }
    return self;
}

/*
 // Only override drawRect: if you perform custom drawing.
 // An empty implementation adversely affects performance during animation.
 - (void)drawRect:(CGRect)rect
 {
 // Drawing code
 }
 */

@end