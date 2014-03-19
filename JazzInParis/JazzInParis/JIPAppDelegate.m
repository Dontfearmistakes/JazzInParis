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
#import "JIPUpdateManager.h"

@implementation JIPAppDelegate

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    
    [[JIPUpdateManager sharedUpdateManager] updateUpcomingEvents];
    
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
    JIPUpcomingEventsCDTVC *upcomingEventVC = [[JIPUpcomingEventsCDTVC alloc] init];
    
    UINavigationController *upcomingEventsNavVC = [[UINavigationController alloc] initWithRootViewController:upcomingEventVC];
    upcomingEventsNavVC.navigationBar.barTintColor = Rgb2UIColor(255, 177, 91);
    upcomingEventsNavVC.navigationBar.tintColor = Rgb2UIColor(41, 59, 255);
    
    [[UINavigationBar appearance] setTitleTextAttributes:
     @{NSForegroundColorAttributeName: Rgb2UIColor(41, 59, 255),
       NSFontAttributeName: [UIFont fontWithName:@"Noteworthy-Light" size:20.0]
       }];
    
//    [[UINavigationBar appearance] setTitleTextAttributes:
//     [NSDictionary dictionaryWithObjectsAndKeys:
//      [UIColor clearColor],
//      UITextAttributeTextColor,
//      
//      [UIColor whiteColor],
//      UITextAttributeTextShadowColor,
//      [NSValue valueWithUIOffset:UIOffsetMake(0, -1)],
//      UITextAttributeTextShadowOffset,
//      [UIFont fontWithName:@"QuicksandBold-Regular" size:24.0],
//      UITextAttributeFont,
//      nil]];
    
    ////////////////////////////////////////////
    //////////TAB BAR CONTROLLER GETS NAV VC////
    ///////////////////////////////////////////
    UITabBarController *tabBarController = [[UITabBarController alloc] init];
    tabBarController.viewControllers = @[upcomingEventsNavVC];
    tabBarController.tabBar.tintColor = Rgb2UIColor(41, 59, 255); //blue
    tabBarController.tabBar.barTintColor = Rgb2UIColor(255, 177, 91); //orange

    
    self.window.rootViewController = tabBarController;

    
    
    self.window.backgroundColor = [UIColor whiteColor];
    [self.window makeKeyAndVisible];
    return YES;
}



@end
