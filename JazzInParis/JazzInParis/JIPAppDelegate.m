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
#import "JIPSearchArtistsViewController.h"
#import "JIPUpdateManager.h"

@implementation JIPAppDelegate

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    
    //[[JIPUpdateManager sharedUpdateManager] updateUpcomingEvents];
    
    self.window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
    // Override point for customization after application launch.
    
    self.window.tintColor = [UIColor blueColor];
    
    ////////////////////////////////////
    //////////UPCOMING EVENTS VC////////
    ///////////////////////////////////
    
    //TEST
    //Soit 1
    //JIPUpComingEventsViewController *upcomingEventVC = [[JIPUpComingEventsViewController alloc] init];
    //[upcomingEventVC createFakeUpcomingEvents];
    //Soit 2
    JIPUpcomingEventsCDTVC         *upcomingEventCDTVC = [[JIPUpcomingEventsCDTVC alloc] init];

    JIPSearchArtistsViewController *searchArtistsVC    = [[JIPSearchArtistsViewController alloc] init];
    
    UINavigationController *upcomingEventsNC = [[UINavigationController alloc] initWithRootViewController:upcomingEventCDTVC];
    UINavigationController *searchArtistsNC  = [[UINavigationController alloc] initWithRootViewController:searchArtistsVC];
    

    
    
    //////////////////////////////////////////////////////
    //////////  TAB BAR CONTROLLER GETS NAV VC  //////////
    //////////////////////////////////////////////////////
    UITabBarController *tabBarController = [[UITabBarController alloc] init];
    tabBarController.viewControllers = @[searchArtistsNC, upcomingEventsNC];
    
    
    
    //////////////////////////////////////////////////////
    ///////////////////////  STYLING  ////////////////////
    //////////////////////////////////////////////////////
    upcomingEventsNC.navigationBar.barTintColor = Rgb2UIColor(255, 177, 91);
    upcomingEventsNC.navigationBar.tintColor = Rgb2UIColor(41, 59, 255);
    searchArtistsNC.navigationBar.barTintColor = Rgb2UIColor(255, 177, 91);
    searchArtistsNC.navigationBar.tintColor = Rgb2UIColor(41, 59, 255);
    
    [[UINavigationBar appearance] setTitleTextAttributes:
     @{NSForegroundColorAttributeName: Rgb2UIColor(41, 59, 255),
       NSFontAttributeName           : [UIFont fontWithName:@"Noteworthy-Light" size:20.0]
       }];
    tabBarController.tabBar.tintColor = Rgb2UIColor(41, 59, 255); //blue
    tabBarController.tabBar.barTintColor = Rgb2UIColor(255, 177, 91); //orange

    
    self.window.rootViewController = tabBarController;
    
    self.window.backgroundColor = [UIColor whiteColor];
    [self.window makeKeyAndVisible];
    return YES;
}



@end
