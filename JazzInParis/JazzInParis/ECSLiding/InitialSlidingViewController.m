//
//  InitialSlidingViewController.m
//  ECSlidingViewController
//
//  Created by Michael Enriquez on 1/25/12.
//  Copyright (c) 2012 EdgeCase. All rights reserved.
//

#import "InitialSlidingViewController.h"

@implementation InitialSlidingViewController

- (void)viewDidLoad {
  [super viewDidLoad];
  
    UIStoryboard *storyboard = nil;
    
    // The iOS device = iPhone or iPod Touch
    if ([UIDevice currentDevice].userInterfaceIdiom == UIUserInterfaceIdiomPhone)
    {
        CGSize iOSDeviceScreenSize = [[UIScreen mainScreen] bounds].size;
        if (iOSDeviceScreenSize.height == 480)
        {
            // iPhone 3GS, 4, and 4S and iPod Touch 3rd and 4th generation: 3.5 inch screen (diagonally measured)
            //NSLog(@"Loading iphone 4 storyboard");
            // Instantiate a new storyboard object using the storyboard file named MainStoryboard_iPhone
            storyboard = [UIStoryboard storyboardWithName:@"Iphone4" bundle:nil];
        }
        if (iOSDeviceScreenSize.height == 568)
        {
            // iPhone 5 and iPod Touch 5th generation: 4 inch screen (diagonally measured)
            // NSLog(@"Loading iphone 5 storyboard");
            // Instantiate a new storyboard object using the storyboard file named Storyboard_iPhone4
            storyboard = [UIStoryboard storyboardWithName:@"Iphone5" bundle:nil];
        }
    }
  
    self.topViewController = [storyboard instantiateViewControllerWithIdentifier:@"Search Artist"];
}




- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation
{
  return YES;
}

@end
