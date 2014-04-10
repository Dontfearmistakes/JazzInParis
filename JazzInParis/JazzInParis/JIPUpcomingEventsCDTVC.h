//
//  UpcomingEventsCDTVC.h
//  JazzInParis
//
//  Created by Max on 10/03/14.
//  Copyright (c) 2014 Max. All rights reserved.
//

#import "JIPCoreDataTableViewController.h"
#import "JIPEvent.h"

@interface JIPUpcomingEventsCDTVC : JIPCoreDataTableViewController <UISearchBarDelegate, UISearchDisplayDelegate>



@property (strong, nonatomic) IBOutlet UIBarButtonItem *searchBarButtonItem;
@property (strong, nonatomic) IBOutlet UISearchBar *searchBar;

@property (strong, nonatomic) NSArray              * filteredUpcomingEvents;
@property (nonatomic)         BOOL                   isFiltered;
@property (strong, nonatomic) JIPEvent             * event;
@property (strong, nonatomic) JIPEvent             * selectedEvent;


@end
