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
#import "JIPVenue+Create.h"

@implementation JIPAppDelegate

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleLightContent];
    
    //Configure PageController
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

        NSMutableArray *allJazzClubsInParis = [[NSMutableArray alloc]init];
        
        NSMutableDictionary *baiserSaleDict = [[NSMutableDictionary alloc] init];
        baiserSaleDict[@"id"]              = @(-1);
        baiserSaleDict[@"name"]            = @"Baiser Salé";
        baiserSaleDict[@"city"]            = @"Paris";
        baiserSaleDict[@"street"]          = @"58, rue des Lombards";
        baiserSaleDict[@"phone"]           = @"+33 1 42 33 37 71";
        baiserSaleDict[@"websiteString"]   = @"http://www.lebaisersale.com";
        baiserSaleDict[@"lat"]             = @"48.859722222222224";
        baiserSaleDict[@"long"]            = @"2.348055555555556";
        
        [allJazzClubsInParis addObject:baiserSaleDict];
        
        for (NSMutableDictionary * jazzClubDict in allJazzClubsInParis)
        {
            [JIPVenue venueWithDict:jazzClubDict inManagedObjectContext:managedDocument.managedObjectContext];
        }
        
        

    }];

    [[JIPUpdateManager sharedUpdateManager] clearOldEvents];
    [[JIPUpdateManager sharedUpdateManager] updateUpcomingEvents];

    
    return YES;
}



@end
