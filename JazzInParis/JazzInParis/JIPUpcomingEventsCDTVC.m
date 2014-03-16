//
//  UpcomingEventsCDTVC.m
//  JazzInParis
//
//  Created by Max on 10/03/14.
//  Copyright (c) 2014 Max. All rights reserved.
//

#import "JIPUpcomingEventsCDTVC.h"
#import "NSDate+Formatting.h"
#import "JIPEvent.h"
#import "JIPEvent+Create.h"
#import "JIPManagedDocument.h"

@interface JIPUpcomingEventsCDTVC ()

@property (strong, nonatomic) NSArray *upcomingEventsFromAPI;
@property (strong, nonatomic) NSArray *upcomingEventsFromFRC;
@property (strong, nonatomic) NSDictionary *groupedByDatesUpcomingEvents;
@property (strong, nonatomic) NSArray *orderedDates;

@end

@implementation JIPUpcomingEventsCDTVC

/////////////////////////////////////////////////////////////////////////////////////////////////////
/////////////////////////////////////////////////////////////////////////////////////////////////////
/////////////////////////////////////////////////////////////////////////////////////////////////////

-(id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        self.title = @"All Concerts";
        self.tabBarItem.image = [UIImage imageNamed:@"Venue"];
    }
    return self;
}

////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////

-(void)viewDidLoad
{
    [super viewDidLoad];
    [self createFakeEvents];
    [self createFetchResultsController];
}

////////////////////////////////////////////////////////////
// 1) Fetch upcomingEvents and put them in ManagedContext
////////////////////////////////////////////////////////////
-(void)createFakeEvents
{
    [[JIPManagedDocument sharedManagedDocument] performBlockWithDocument:^(JIPManagedDocument *managedDocument) {
        
        // 1) Fetch the events from Songkick
        self.upcomingEventsFromAPI = @[
                                    @{@"id"       :@1,
                                      @"name"     :@"Brad Mehldau",
                                      @"lat"      :@(-0.1150322),
                                      @"long"     :@51.4650846,
                                      @"date"     :[NSDate dateFromString:@"Tue, 25 May 2014 12:53:58 +0000"],
                                      @"venue"    :@"Baiser Salé",
                                      @"artist"   :@"Brad Mehldau",
                                      @"type"     :@"concert",
                                      @"uriString":@"http://www.songkick.com/concerts/19267659-maxxximus-at-baiser-sale",
                                      @"ageRestriction" : @"14+",
                                      @"venue"    : @"Baiser Salé"},
                                    @{@"id"       :@2,
                                      @"name"     :@"Oscar Peterson",
                                      @"lat"      :@(-0.1150322),
                                      @"long"     :@51.4650846,
                                      @"date"     :[NSDate dateFromString:@"Tue, 25 May 2014 12:53:58 +0000"],
                                      @"venue"    :@"Baiser Salé",
                                      @"artist"   :@"Oscar Peterson",
                                      @"type"     :@"concert",
                                      @"uriString":@"http://www.songkick.com/concerts/19267659-maxxximus-at-baiser-sale",
                                      @"ageRestriction" : @"14+",
                                      @"venue"    : @"Baiser Salé"}
                                    ];
        
        
        ///////////////////
        //GET TODAY 10AM///
        ///////////////////
        NSDate *now = [NSDate date];
        NSCalendar *calendar = [[NSCalendar alloc] initWithCalendarIdentifier:NSGregorianCalendar];
        NSDateComponents *components = [calendar components:NSYearCalendarUnit|NSMonthCalendarUnit|NSDayCalendarUnit fromDate:now];
        [components setHour:10];
        [components setMinute:10];
        [components setSecond:10];
        NSDate *today10am = [calendar dateFromComponents:components];
        
        
        // 2) Put the events in ManagedObjectContext
        for (NSDictionary *upcomingEvent in self.upcomingEventsFromAPI)
        {
            //FILTER PAST EVENTS//////
            if ([upcomingEvent[@"date"] timeIntervalSinceDate:today10am] >= 0)
            {
                [JIPEvent eventWithSongkickInfo:upcomingEvent
                         inManagedObjectContext:managedDocument.managedObjectContext];
            }
        }
        
    }];
    
}


/////////////////////////////////////////////////////////////////////////
// 2) Fill fetchedResultController with all JIPEvents from ManagedContext
/////////////////////////////////////////////////////////////////////////
-(void)createFetchResultsController
{
    NSLog(@"FIRING createFetchResultsController");
    
    [[JIPManagedDocument sharedManagedDocument] performBlockWithDocument:^(JIPManagedDocument *managedDocument) {
        
        NSFetchRequest *request = [NSFetchRequest fetchRequestWithEntityName:@"JIPEvent"];
        request.sortDescriptors = @[[NSSortDescriptor sortDescriptorWithKey:@"date" ascending:YES]];
        request.predicate = nil; //all JIPEvents
        
        self.fetchedResultsController = [[NSFetchedResultsController alloc] initWithFetchRequest:request
                                                                            managedObjectContext:managedDocument.managedObjectContext
                                                                              sectionNameKeyPath:nil
                                                                                    cacheName:nil];
    }];
    
}


////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////
#pragma mark - UITableViewDataSource
////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////
-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSLog(@"FIRING CellForRowAtIndexPath");
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"eventCell"];
    if (!cell)
    {
        cell = [[UITableViewCell alloc]initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:@"eventCell"];
    }

    JIPEvent *event = [self.fetchedResultsController objectAtIndexPath:indexPath];
    NSLog(@"EVENT  : %@", event);
    NSString * eventName = event.name;
    NSLog(@"EVENT NAME : %@", event.name);
    cell.textLabel.text = eventName;    
    cell.detailTextLabel.text  = [NSString stringWithFormat:@"@ %@", event.venue.name];
    cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    
    return cell;
}



////////////////////////////////////////////////////////////////////////////////
//MAKE SURE _orderedDates is filled when getter called and ivar is still empty
////////////////////////////////////////////////////////////////////////////////
-(NSArray *)orderedDates
{
    if (!_orderedDates)
    {
        /////////////////////////////////////////////////////////////////////////
        //SORTING ARRAY OF JIPEVENTS (self.upcomingEvents) BY ASCENDING DATES////
        /////////////////////////////////////////////////////////////////////////
        NSSortDescriptor *dateSortDescriptor = [NSSortDescriptor sortDescriptorWithKey:@"date" ascending:YES];
        NSArray *sortedByDateEventsArray = [self.upcomingEventsFromFRC sortedArrayUsingDescriptors:[NSArray arrayWithObject:dateSortDescriptor]];
        
        ////////////////////////////////////////////////////
        //CREATE ARRAY WITH ALL DATES AND NO DUPLICATE/////
        ////////////////////////////////////////////////////
        _orderedDates = [sortedByDateEventsArray valueForKeyPath:@"@distinctUnionOfObjects.date"];
    }
    return _orderedDates;
}

@end
