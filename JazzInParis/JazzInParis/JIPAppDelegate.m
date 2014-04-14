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
    
    [[JIPManagedDocument sharedManagedDocument] performBlockWithDocument:^(JIPManagedDocument *managedDocument) {

        [[JIPUpdateManager sharedUpdateManager] clearOldEvents];
        [[JIPUpdateManager sharedUpdateManager] updateUpcomingEvents];

    }];
    
    return YES;
}



@end
