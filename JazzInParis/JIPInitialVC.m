//
//  JIPInitialVC.m
//  JazzInParis
//
//  Created by Max on 15/04/14.
//  Copyright (c) 2014 Max. All rights reserved.
//

#import "JIPInitialVC.h"

@interface JIPInitialVC ()

@end

@implementation JIPInitialVC



-(void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    

    if ([userDefaults boolForKey:@"firstLaunch"] == YES)
    {
        [self performSegueWithIdentifier:@"initialLaunchSegue" sender:nil];
    }
    else
    {
      [self performSegueWithIdentifier:@"regularLaunchSegue" sender:nil];
    }
}




@end
