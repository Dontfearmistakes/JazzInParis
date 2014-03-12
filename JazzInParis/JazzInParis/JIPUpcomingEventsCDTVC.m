//
//  UpcomingEventsCDTVC.m
//  JazzInParis
//
//  Created by Max on 10/03/14.
//  Copyright (c) 2014 Max. All rights reserved.
//

#import "JIPUpcomingEventsCDTVC.h"
#import "JIPEvent.h"
#import "JIPEvent+Create.h"

@interface JIPUpcomingEventsCDTVC ()

@end

@implementation JIPUpcomingEventsCDTVC

-(IBAction)refresh
{
    [self.refreshControl beginRefreshing];
    dispatch_queue_t fetchQ = dispatch_queue_create("Upcoming Events Fetch", NULL);
    dispatch_async(fetchQ,
                   ^{
                       //fetch the events from Songkick
                       NSArray *upcomingEvents = @[
                                                   @{@"id"       :@1,
                                                     @"name"     :@"Brad Mehldau",
                                                     @"lat"      :@(-0.1150322),
                                                     @"long"     :@51.4650846,
                                                     @"date"     :@"22/12/2014",
                                                     @"venue"    :@"Baiser Salé",
                                                     @"artist"   :@"Brad Mehldau",
                                                     @"type"     :@"concert",
                                                     @"uriString":@"http://www.songkick.com/concerts/19267659-maxxximus-at-baiser-sale",
                                                     @"ageRestriction" : @"14+",
                                                     @"artist"   : @"Brad Mehldau",
                                                     @"venue"    : @"Baiser Salé"}
                                                   ];
                       //put the photos in Core Data
                       //Database need to be accessed on the managedObjectContext Thread
                       [self.managedObjectContext performBlock:
                        ^{
                            for (NSDictionary *upcomingEvent in upcomingEvents)
                            {
                                [JIPEvent eventWithSongkickInfo:upcomingEvent
                                         inManagedObjectContext:self.managedObjectContext];
                            }
                            
                            //warn main queue that data's been refreshed
                            dispatch_async(dispatch_get_main_queue(),
                                           ^{
                                               [self.refreshControl endRefreshing];
                                           });
                        }];
                   });
}

////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////
-(void)viewDidLoad
{
    [super viewDidLoad];
    [self.refreshControl addTarget:self
                            action:@selector(refresh)
                  forControlEvents:UIControlEventValueChanged];
}

////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////
-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    if (!self.managedObjectContext)
    {
        [self useDemoDocument];
    }
}

////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////
-(void)useDemoDocument
{
    NSURL *url = [[[NSFileManager defaultManager] URLsForDirectory:NSDocumentationDirectory inDomains:NSUserDomainMask] lastObject];
    url = [url URLByAppendingPathComponent:@"DemoDocument"];
    UIManagedDocument *document = [[UIManagedDocument alloc] initWithFileURL:url];

    
    //if UIDocument doesnt exist yet, create the document
    if ( ! [[NSFileManager defaultManager] fileExistsAtPath:[url path]] )
    {
        [document    saveToURL:url
              forSaveOperation:UIDocumentSaveForCreating
             completionHandler:^(BOOL success)
         {
             if (success)
             {
                 self.managedObjectContext = document.managedObjectContext;
                 [self refresh];
                 NSLog(@"DOCUMENT SAVED !");
             }
             else
             {
                 NSLog(@"COULDNT SAVE DOCUMENT");
             }
         }];
    }
    
    //if the document already exists but is closed, open it
    else if (document.documentState == UIDocumentStateClosed)
    {
        [document openWithCompletionHandler:^(BOOL success)
         {
             if (success)
             {
                 self.managedObjectContext = document.managedObjectContext;
             }
         }];
    }
    
    //otherwise, try to use it
    else
    {
        NSLog(@"ALREADY CREATED DOCUMENT");
        self.managedObjectContext = document.managedObjectContext;
        
    }
}

////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////
-(void)setManagedObjectContext:(NSManagedObjectContext *)managedObjectContext
{
    _managedObjectContext = managedObjectContext;
    if (managedObjectContext)
    {
        NSFetchRequest *request = [NSFetchRequest fetchRequestWithEntityName:@"JIPEvent"];
        request.sortDescriptors = @[[NSSortDescriptor sortDescriptorWithKey:@"date" ascending:YES]];
        request.predicate = nil; //all JIPEvents
        self.fetchedResultsController = [[NSFetchedResultsController alloc] initWithFetchRequest:request
                                                                            managedObjectContext:managedObjectContext
                                                                              sectionNameKeyPath:nil
                                                                                       cacheName:nil];
    }
    else
    {
        self.fetchedResultsController = nil;
    }
}

////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////
-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"JIPEvent"];
    JIPEvent *event = [self.fetchedResultsController objectAtIndexPath:indexPath];
    cell.textLabel.text = event.name;
    return cell;
}


@end
