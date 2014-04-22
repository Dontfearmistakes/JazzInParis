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
        
        
        
        NSDictionary *baiserSaleDict = [[NSDictionary alloc] initWithObjectsAndKeys:
                                        @(-1)                         ,  @"id",
                                        @"Baiser Salé"                ,  @"name",
                                        @"Paris"                      ,  @"city",
                                        @"58, rue des Lombards"       ,  @"street",
                                        @"+33 1 42 33 37 71"          ,  @"phone",
                                        @"http://www.lebaisersale.com",  @"websiteString",
                                        @"48.859722222222224"         ,  @"lat",
                                        @"2.348055555555556"          ,  @"long",
                                        nil];
        NSDictionary *newMorningDict = [[NSDictionary alloc] initWithObjectsAndKeys:
                                        @(-2)                           ,  @"id",
                                        @"New Morning"                  ,  @"name",
                                        @"Paris"                        ,  @"city",
                                        @"7 & 9 Rue des Petites Ecuries",  @"street",
                                        @"+33 (0)1 45 23 51 41"         ,  @"phone",
                                        @"http://www.newmorning.com"    ,  @"websiteString",
                                        @"48.87305555555555"            ,  @"lat",
                                        @"2.3525"                       ,  @"long",
                                        nil];
        
        
        
        NSArray *allJazzClubsInParis = [NSArray arrayWithObjects:baiserSaleDict, newMorningDict, nil];
        
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
