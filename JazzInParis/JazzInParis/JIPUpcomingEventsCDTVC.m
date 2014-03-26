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
#import "JIPVenue+Create.h"
#import "JIPArtist+Create.h"
#import "JIPManagedDocument.h"
#import "JIPConcertDetailsViewController.h"

@interface JIPUpcomingEventsCDTVC ()

@property (strong, nonatomic) NSArray *upcomingEventsFromAPI;
@property (strong, nonatomic) NSArray *venuesFromAPI;
@property (strong, nonatomic) NSArray *artistsFromAPI;

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
                                    @{@"id"       :@3,
                                      @"name"     :@"Brad Mehldau",
                                      @"lat"      :@(28.41871),
                                      @"long"     :@(-81.58121),
                                      @"date"     :[NSDate dateFromString:@"Tue, 25 May 2013 12:53:58 +0000"],
                                      @"venue"    :@"Baiser Salé",
                                      @"artist"   :@"Brad Mehldau",
                                      @"type"     :@"concert",
                                      @"uriString":@"http://www.songkick.com/concerts/19267659-maxxximus-at-baiser-sale",
                                      @"ageRestriction" : @"14+"},
                                    
                                    @{@"id"       :@6,
                                      @"name"     :@"Oscar Peterson",
                                      @"lat"      :@(-0.1150322),
                                      @"long"     :@(51.4650846),
                                      @"date"     :[NSDate dateFromString:@"Tue, 27 June 2015 12:53:58 +0000"],
                                      @"venue"    :@"Duc des Lombards",
                                      @"artist"   :@"Oscar Peterson",
                                      @"type"     :@"concert",
                                      @"uriString":@"http://www.songkick.com/concerts/19267659-maxxximus-at-baiser-sale",
                                      @"ageRestriction" : @"14+"}
                                    ];
        
        self.venuesFromAPI = @[
                                       @{@"id"       :@1,
                                         @"desc"     :@"Cool Salted Kiss",
                                         @"name"     :@"Baiser Salé",
                                         @"city"     :@"Paris",
                                         @"street"   :@"3 rue des Lombards",
                                         @"phone"     :@"01 42 06 68 43",
                                         @"lat"      :@(28.41871),
                                         @"long"     :@(-81.58121),
                                         @"websiteString"     :@"http://lebaisersale.com",
                                         @"capacity"     :@200},
                                       
                                       @{@"id"       :@2,
                                         @"desc"     :@"At the Duke",
                                         @"name"     :@"Duc des Lombards",
                                         @"city"     :@"Paris",
                                         @"street"   :@"3 rue des Lombards",
                                         @"phone"     :@"01 42 06 68 43",
                                         @"lat"      :@(28.41871),
                                         @"long"     :@(-81.58121),
                                         @"websiteString"     :@"http://wwww.ducdeslombards.com",
                                         @"capacity"     :@200}
                                       ];
        
        self.artistsFromAPI = @[
                               @{@"id"          :@1,
                                 @"name"        :@"Brad Mehldau",
                                 @"songKickUri" :@"http://www.songkick.com/concerts/19267659-maxxximus-at-baiser-sale"},
                               
                               @{@"id"          :@2,
                                 @"name"        :@"Oscar Peterson",
                                 @"songKickUri" :@"http://www.songkick.com/concerts/19267659-maxxximus-at-baiser-sale"}
                               ];
        
        // 2) Put the venues in ManagedObjectContext
        for (NSDictionary *venue in self.venuesFromAPI) {
            [JIPVenue venueWithDict:venue
             inManagedObjectContext:managedDocument.managedObjectContext];
        }
        
        // 3) Put the artists in ManagedObjectContext
        for (NSDictionary *artist in self.artistsFromAPI) {
            [JIPArtist artistWithDict:artist
               inManagedObjectContext:managedDocument.managedObjectContext];
        }
        
        // 4) Put the events in ManagedObjectContext
        for (NSDictionary *upcomingEvent in self.upcomingEventsFromAPI)
        {
                [JIPEvent eventWithSongkickInfo:upcomingEvent
                         inManagedObjectContext:managedDocument.managedObjectContext];
        }
        
        
    }];
    
}


/////////////////////////////////////////////////////////////////////////
// 2) Fill fetchedResultController with all JIPEvents from ManagedContext
/////////////////////////////////////////////////////////////////////////
-(void)createFetchResultsController
{
    
    [[JIPManagedDocument sharedManagedDocument] performBlockWithDocument:^(JIPManagedDocument *managedDocument) {
        
        NSFetchRequest *request = [NSFetchRequest fetchRequestWithEntityName:@"JIPEvent"];
        request.sortDescriptors = @[[NSSortDescriptor sortDescriptorWithKey:@"date" ascending:YES]];
        request.predicate       = [NSPredicate predicateWithFormat:@"date >= %@", [NSDate date]]; //all JIPEvents starting today or later
        
        self.fetchedResultsController = [[NSFetchedResultsController alloc] initWithFetchRequest:request
                                                                            managedObjectContext:managedDocument.managedObjectContext
                                                                              sectionNameKeyPath:@"sectionIdentifier"
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
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"eventCell"];
    if (!cell)
    {
        cell = [[UITableViewCell alloc]initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:@"eventCell"];
    }

    JIPEvent *event = [self.fetchedResultsController objectAtIndexPath:indexPath];
    cell.textLabel.text = event.name;
    cell.detailTextLabel.text  = [NSString stringWithFormat:@"@ %@", event.venue.name];
    cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    
    return cell;
}


///////////////////////////////////////////////////////////////////////////////////////////
- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
	id <NSFetchedResultsSectionInfo> theSection = [[self.fetchedResultsController sections] objectAtIndex:section];
    
    /*
     Section information derives from an event's sectionIdentifier, which is a string representing the number (year * 1000) + month.
     To display the section title, convert the year and month components to a string representation.
     */
    static NSDateFormatter *formatter = nil;
    
    if (!formatter)
    {
        formatter = [[NSDateFormatter alloc] init];
        [formatter setCalendar:[NSCalendar currentCalendar]];
        
        NSString *formatTemplate = [NSDateFormatter dateFormatFromTemplate:@"d MMMM YYYY" options:0 locale:[NSLocale currentLocale]];
        [formatter setDateFormat:formatTemplate];
    }
    
    NSInteger numericSection = [[theSection name] integerValue];
    
	NSInteger year = numericSection / 10000;
    NSInteger month = (numericSection / 100) % 100;
    NSInteger day = numericSection % 100;
    
    NSDateComponents *dateComponents = [[NSDateComponents alloc] init];
    dateComponents.year = year;
    dateComponents.month = month;
    dateComponents.day = day;
    NSDate *date = [[NSCalendar currentCalendar] dateFromComponents:dateComponents];
    
	NSString *titleString = [formatter stringFromDate:date];
    
	return titleString;
}




////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
#pragma mark - Table View Delegate
////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    //CREATE VC////////////////////////
    JIPConcertDetailsViewController *concertDetailsVC = [[JIPConcertDetailsViewController alloc] init];
    
    //PASSING EVENT FROM VC TO VC///////////////////
    concertDetailsVC.event = [self.fetchedResultsController objectAtIndexPath:indexPath];
    
    //PUSH VC//////////////////////
    [self.navigationController pushViewController:concertDetailsVC animated:YES];
}

@end
