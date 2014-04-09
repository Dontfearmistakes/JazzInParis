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


@implementation JIPUpcomingEventsCDTVC

/////////////////////////////////////////////////////////////////////////////////////////////////////
/////////////////////////////////////////////////////////////////////////////////////////////////////
/////////////////////////////////////////////////////////////////////////////////////////////////////

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
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
}

@end
