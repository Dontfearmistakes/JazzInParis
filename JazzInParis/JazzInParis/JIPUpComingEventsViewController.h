//
//  JIPUpComingEventsViewController.h
//  JazzInParis
//
//  Created by Max on 02/02/14.
//  Copyright (c) 2014 Max. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface JIPUpComingEventsViewController : UITableViewController

@property (strong, nonatomic) NSArray *upcomingEvents;

-(void)createFakeUpcomingEvents;


@end
