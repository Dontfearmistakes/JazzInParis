//
//  JIPAppDelegate.m
//  JazzInParis
//
//  Created by Max on 02/02/14.
//  Copyright (c) 2014 Max. All rights reserved.
//

#import "JIPAppDelegate.h"
#import "JIPUpComingEventsViewController.h"

@implementation JIPAppDelegate

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    self.window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
    // Override point for customization after application launch.
    
    ////////////////////////////////////
    //////////UPCOMING EVENTS VC////////
    ///////////////////////////////////
    NSLog(@"bug");
    
    JIPUpComingEventsViewController *upcomingEventVC = [[JIPUpComingEventsViewController alloc] init];
    
    [upcomingEventVC createFakeUpcomingEvents];
    UINavigationController *upcomingEventsNavVC = [[UINavigationController alloc] initWithRootViewController:upcomingEventVC];
    
    
    ////////////////////////////////////////////
    //////////TAB BAR CONTROLLER GETS NAV VC////
    ///////////////////////////////////////////
    UITabBarController *tabBarController = [[UITabBarController alloc] init];
    tabBarController.viewControllers = @[upcomingEventsNavVC];
    
    self.window.rootViewController = tabBarController;

    
    
    self.window.backgroundColor = [UIColor whiteColor];
    [self.window makeKeyAndVisible];
    return YES;
}



@end
