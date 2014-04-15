//
//  JIPPageContentVC.m
//  JazzInParis
//
//  Created by Max on 15/04/14.
//  Copyright (c) 2014 Max. All rights reserved.
//

#import "JIPPageContentVC.h"

@interface JIPPageContentVC ()

@end

@implementation JIPPageContentVC

@synthesize initialTextView = _initialTextView;
@synthesize contentText     = _contentText;


- (void)viewDidLoad
{
    [super viewDidLoad];

    [_initialTextView setText:_contentText];
}




@end
