//
//  JIPPageContentVC.m
//  JazzInParis
//
//  Created by Max on 15/04/14.
//  Copyright (c) 2014 Max. All rights reserved.
//

#define padding 20
#import "JIPPageContentVC.h"


@interface JIPPageContentVC ()

@end

@implementation JIPPageContentVC

@synthesize initialTextView = _initialTextView;
@synthesize contentText     = _contentText;
@synthesize finishWelcomePageControllerButton = _finishWelcomePageControllerButton;


- (void)viewDidLoad
{
    [super viewDidLoad];

    
    

    _initialTextView.layer.cornerRadius = 10.0f;

    [_initialTextView setText:_contentText];
    

    
    if (self.pageIndex == 3)
    {
        _finishWelcomePageControllerButton.layer.cornerRadius = 10.0f;
        [_finishWelcomePageControllerButton setHidden:NO];
    }
}




- (IBAction)finishWelcomePageControllerClick:(id)sender {
    
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    [userDefaults setBool:NO forKey:@"firstLaunch"];
    
    [self dismissViewControllerAnimated:NO completion:nil];
}

@end
