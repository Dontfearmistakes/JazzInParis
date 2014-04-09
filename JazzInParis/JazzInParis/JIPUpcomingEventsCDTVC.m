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


@implementation JIPUpcomingEventsCDTVC

@synthesize filteredUpcomingEvents = _filteredUpcomingEvents;
@synthesize event                  = _event;

/////////////////////////////////////////////////////////////////////////////////////////////////////
/////////////////////////////////////////////////////////////////////////////////////////////////////
/////////////////////////////////////////////////////////////////////////////////////////////////////


////////////////////////////////////////////////
//method for every rootVC / implements side menu
////////////////////////////////////////////////

- (IBAction)revealMenu:(id)sender {
    [self.slidingViewController anchorTopViewTo:ECRight];
}


////////////////////////////////////////////////////////////
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
        NSPredicate * globalPredicate = [NSCompoundPredicate andPredicateWithSubpredicates:@[p1, p2]];
        request.predicate= globalPredicate;
    
        self.fetchedResultsController = [[NSFetchedResultsController alloc] initWithFetchRequest:request
                                                                            managedObjectContext:[JIPManagedDocument sharedManagedDocument].managedObjectContext
                                                                              sectionNameKeyPath:@"sectionIdentifier"
                                                                                       cacheName:nil];
}

////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////
#pragma mark - UITableViewDataSource
////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////


- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    //Here, the table view passed as an argument can be either the regular tableView (appearing the 1st time the view loads)
    //                                                  or the self.searchDisplayController.searchResultsTableView (if the searchBar is used)
    if (tableView == self.searchDisplayController.searchResultsTableView)
    {
        return [_filteredUpcomingEvents count];
    }
    else
    {
        return [super tableView:tableView numberOfRowsInSection:section];
    }
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    //ICI self.tableView est TOUJOURS UITableView et non pas UISearchResultsTableView (c'est pour ça qu'on l'utilise pour chopper là cellule)
    //Alors que le tableView passé en argument est l'un ou l'autre (selon que les résultats affichés sont filtrés oun non)
    JIPUpcomingEventCell *upcomingEventCell = [self.tableView dequeueReusableCellWithIdentifier:@"UpcomingEventCell"];
    
    if (tableView == self.searchDisplayController.searchResultsTableView)
    {
        _event = _filteredUpcomingEvents[indexPath.row];
    }
    else
    {
        _event = [self.fetchedResultsController objectAtIndexPath:indexPath];
    }

    upcomingEventCell.titleLabel.text    = _event.name;
    upcomingEventCell.subtitleLabel.text = [NSString stringWithFormat:@"@ %@", _event.venue.name];
    
    return upcomingEventCell;
    
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


///////////////////////////////////////////////////////////////////////////////////////////////
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 60;
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
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
}



////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
#pragma mark - UISearchBarDelegate
////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////


///////////////////////////////////////////////////////////////////////////
// Click on top left bar button (loupe) --> searBar becomes first responder
- (IBAction)searchBarButtonItemClick:(id)sender
{
    [self.tableView scrollRectToVisible:CGRectMake(0, 0, 1, 1) animated:NO];
    [self.searchBar becomeFirstResponder];
}


////////////////////////////////////////////////////////////
- (void)searchBarSearchButtonClicked:(UISearchBar *)searchBar
{
#warning : this method is never called ...
    [self.searchDisplayController setActive:NO animated:YES];
}


- (BOOL)searchDisplayController:(UISearchDisplayController *)controller shouldReloadTableForSearchString:(NSString *)searchString
{
#warning : à quoi sert scope ?? il est nil...
    [self filterContentForSearchText:searchString
                               scope:[[self.searchDisplayController.searchBar scopeButtonTitles] objectAtIndex:[self.searchDisplayController.searchBar selectedScopeButtonIndex]]];
    return YES;
}


////////////////////////////////////////////////////////
- (void)filterContentForSearchText:(NSString*)searchText
                             scope:(NSString*)scope
{
#warning : what is diacritic ?
    NSPredicate *resultPredicate = [NSPredicate predicateWithFormat:@"name contains[cd] %@", searchText];
    
   _filteredUpcomingEvents = [self.fetchedResultsController.fetchedObjects filteredArrayUsingPredicate:resultPredicate];
}

@end
