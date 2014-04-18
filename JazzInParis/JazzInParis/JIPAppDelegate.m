//
//  JIPAppDelegate.m
//  JazzInParis
//
//  Created by Max on 02/02/14.
//  Copyright (c) 2014 Max. All rights reserved.
//

#import "JIPAppDelegate.h"
#import "JIPUpComingEventsViewController.h"
#import "JIPUpcomingEventsCDTVC.h"
#import "JIPFavoriteArtistTableViewController.h"
#import "JIPSearchArtistsViewController.h"
#import "JIPUpdateManager.h"
#import "JIPManagedDocument.h"

@implementation JIPAppDelegate

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleLightContent];
    
    UIPageControl *pageControl = [UIPageControl appearance];
    pageControl.pageIndicatorTintColor = [UIColor whiteColor];
    pageControl.currentPageIndicatorTintColor = [UIColor orangeColor];
    pageControl.backgroundColor = [UIColor blackColor];
    
    
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    if (![userDefaults objectForKey:@"firstLaunch"])
    {
        [userDefaults setBool:YES forKey:@"firstLaunch"];
    }
    
    
    [[JIPManagedDocument sharedManagedDocument] performBlockWithDocument:^(JIPManagedDocument *managedDocument) {

        [[JIPUpdateManager sharedUpdateManager] clearOldEvents];
        [[JIPUpdateManager sharedUpdateManager] updateUpcomingEvents];

    }];


    
    return YES;
}



@end
