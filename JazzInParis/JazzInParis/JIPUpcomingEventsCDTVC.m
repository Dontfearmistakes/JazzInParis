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
#import "JIPUpdateManager.h"
#import "JIPConcertDetailsViewController.h"
#import "ECSlidingViewController.h"
#import "JIPUpcomingEventCell.h"
#import "JIPEventDetailsTVC.h"


@implementation JIPUpcomingEventsCDTVC

@synthesize event                  = _event;
@synthesize addMoreArtistsButton   = _addMoreArtistsButton;
/////////////////////////////////////////////////////////////////////////////////////////////////////
/////////////////////////////////////////////////////////////////////////////////////////////////////
/////////////////////////////////////////////////////////////////////////////////////////////////////



//method for every rootVC / implements side menu
- (IBAction)revealMenu:(id)sender
{
    [self.slidingViewController anchorTopViewTo:ECRight];
}


-(void)viewDidLoad
{
    [super viewDidLoad];
    [JIPDesign applyBackgroundWallpaperInTableView:self.tableView];
}




-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    [self createFetchResultsController];
}




/////////////////////////////////////////////////////////////////////////
// 2) Fill fetchedResultController with all JIPEvents from ManagedContext
/////////////////////////////////////////////////////////////////////////
-(void)createFetchResultsController
{
        
        NSFetchRequest *request = [NSFetchRequest fetchRequestWithEntityName:@"JIPEvent"];
        request.sortDescriptors = @[[NSSortDescriptor sortDescriptorWithKey:@"date" ascending:YES]];
    
        NSPredicate * p1 = [NSPredicate predicateWithFormat:@"(date >= %@)", [NSDate date]];   //all JIPEvents starting today or later
        NSPredicate * p2 = [NSPredicate predicateWithFormat:@"(artist.favorite == %@)", @YES]; //and whose artist is a favorite
        NSPredicate * p3 = [NSPredicate predicateWithFormat:@"(venue.id != nil)"];             //and venue is not undefined
        NSPredicate * globalPredicate = [NSCompoundPredicate andPredicateWithSubpredicates:@[p1, p2, p3]];
        request.predicate= globalPredicate;
   
    
    [[JIPManagedDocument sharedManagedDocument] performBlockWithDocument:^(JIPManagedDocument *managedDocument)
    {
    
        self.fetchedResultsController = [[NSFetchedResultsController alloc] initWithFetchRequest:request
                                                                            managedObjectContext:managedDocument.managedObjectContext
                                                                              sectionNameKeyPath:@"sectionIdentifier"
                                                                                       cacheName:nil];
        
        if ([[self.fetchedResultsController fetchedObjects] count] == 0)
        {
            UILabel *label = [JIPDesign emptyTableViewLabelWithString:@"No upcoming concerts yet..."];
            [self.view addSubview:label];
            
            UIButton *button = [JIPDesign emptyTableViewButtonWithString:@"Add more artists"];;
            [button addTarget:self
                       action:@selector(segueToSearchArtists)
             forControlEvents:UIControlEventTouchUpInside];
            [self.view addSubview:button];
        }
    
    }
    ];
}

-(void)segueToSearchArtists
{
     [self performSegueWithIdentifier:@"searchArtists" sender:nil];
}

////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////
#pragma mark - UITableViewDataSource
////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////






-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{

    _event = [self.fetchedResultsController objectAtIndexPath:indexPath];

    JIPUpcomingEventCell *upcomingEventCell = [self.tableView dequeueReusableCellWithIdentifier:@"UpcomingEventCell"];
    upcomingEventCell.titleLabel   .text   = _event.name;
    upcomingEventCell.subtitleLabel.text = [NSString stringWithFormat:@"@ %@", _event.venue.name];
    
    return upcomingEventCell;
    
}





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




- (UIView *) tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    
    UIView * headerBackground = [[UIView alloc]initWithFrame:CGRectMake(0,0,tableView.bounds.size.width,25)];
             headerBackground.backgroundColor = Rgb2UIColor(66, 66, 66);
    
    UILabel *headerLabel = [[UILabel alloc] init];
    NSString *sectionTitle = [self tableView:tableView titleForHeaderInSection:section];
    headerLabel.text = sectionTitle;
    headerLabel.frame = CGRectMake(15, 5, tableView.bounds.size.width, 15);
    headerLabel.backgroundColor = Rgb2UIColor(66, 66, 66);
    headerLabel.textColor = [UIColor whiteColor];
    
    [headerBackground addSubview:headerLabel];
    
    
    return headerBackground;
    
}

-(CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    return 25;
}


- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 40;
}






////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
#pragma mark - Table View Delegate
////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{

    _selectedEvent = [self.fetchedResultsController objectAtIndexPath:indexPath];
    [self performSegueWithIdentifier:@"EventDetails" sender:nil];
    
}





-(void)prepareForSegue:(UIStoryboardSegue *)segue
                sender:(id)sender
{
    if ([segue.identifier isEqualToString:@"EventDetails"])
    {
        JIPEventDetailsTVC   *eventDetailsVC       = [segue destinationViewController];
                              eventDetailsVC.event = _selectedEvent;
    }
}




@end
