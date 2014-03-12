//
//  CoreDataTableViewController.h
//  Photomania
//
//  Created by Max on 07/03/14.
//  Copyright (c) 2014 Max. All rights reserved.
// see 19.11 of the video to implement

#import <UIKit/UIKit.h>
#import <CoreData/CoreData.h>

@interface JIPCoreDataTableViewController : UITableViewController <NSFetchedResultsControllerDelegate>

@property (strong, nonatomic) NSFetchedResultsController *fetchedResultsController;
-(void)performFetch;


@end
