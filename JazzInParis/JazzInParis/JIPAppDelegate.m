//
//  JIPAppDelegate.m
//  JazzInParis
//
//  Created by Max on 02/02/14.
//  Copyright (c) 2014 Max. All rights reserved.
//

#import "JIPAppDelegate.h"
#include "JIPJazzClubsViewController.h"

@implementation JIPAppDelegate

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    self.window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
    // Override point for customization after application launch.


    JIPJazzClubsViewController *allJazzClubsVC = [[JIPJazzClubsViewController alloc]init];
    UINavigationController     *allJazzClubsNC = [[UINavigationController alloc] initWithRootViewController:allJazzClubsVC];
    
    UITabBarController *tabBarController    = [[UITabBarController alloc] init];
    tabBarController.viewControllers        = @[allJazzClubsNC];
    tabBarController.selectedViewController = allJazzClubsNC;
    
    self.window.rootViewController = tabBarController;
    

    
    
    
    
    
    self.window.backgroundColor = [UIColor whiteColor];
    [self.window makeKeyAndVisible];
    return YES;
}



@end
