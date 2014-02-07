//
//  JIPUpComingEventsViewController.m
//  JazzInParis
//
//  Created by Max on 02/02/14.
//  Copyright (c) 2014 Max. All rights reserved.
//

#import "JIPUpComingEventsViewController.h"
#import "JIPEvent.h"
#import "JIPConcertDetailsViewController.h"

@interface JIPUpComingEventsViewController ()
//ici les proprietés sont automatiquement privée

@property (strong, nonatomic) NSDictionary *upcomingEvents;
@property (strong, nonatomic) NSArray *concertsOnDay;

//@property = crée var d'instance + getter (return _ivar) + setter _ivar = smthg)

-(NSString *)stringFromDate:(NSDate *)date;

@end



@implementation JIPUpComingEventsViewController



/////////////////////////////////////////////////////////////////////////////////////////////////////
/////////////////////////////////////////////////////////////////////////////////////////////////////
/////////////////////////////////////////////////////////////////////////////////////////////////////

-(NSDictionary *)upcomingEvents
{
    NSDate *tomorrow = [NSDate dateWithTimeInterval:(24*60*60) sinceDate:[NSDate date]];
    NSDate *dayAfterTomorrow = [NSDate dateWithTimeInterval:(2*24*60*60) sinceDate:[NSDate date]];
    
    if (!_upcomingEvents)
    {
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
        
        //////////////////////////
        //GET PRECISE DATE////////
        //////////////////////////
        NSDateComponents *comps = [[NSDateComponents alloc] init];
        [comps setDay:6];
        [comps setMonth:5];
        [comps setYear:2004];
        NSCalendar *gregorian = [[NSCalendar alloc]
                                 initWithCalendarIdentifier:NSGregorianCalendar];
        //then use [gregorian dateFromComponents:comps]]
        
        //////////////////////////
        //GET SAME DATE///////////
        //////////////////////////
        //[today10am dateByAddingTimeInterval:0]
        
        JIPEvent *event1 = [[JIPEvent alloc] initWithID:@1
                                                  name:@"Vampire WeekEnd"
                                              location:CLLocationCoordinate2DMake(28.41871, -81.58121)
                                                   date:[today10am dateByAddingTimeInterval:0]];
        event1.type = @"Concert";
        event1.uri = [NSURL URLWithString:@"www.dontfearmistakes.com"];
        event1.ageRestriction = @"14+";
        
        JIPEvent *event2 = [[JIPEvent alloc] initWithID:@1
                                                   name:@"Brad Mehldau"
                                               location:CLLocationCoordinate2DMake(-0.1150322,51.4650846)
                                                   date:today10am];
        event2.type = @"Concert";
        event2.uri = [NSURL URLWithString:@"www.dontfearmistakes.com"];
        event2.ageRestriction = @"14+";
        
        JIPEvent *event3 = [[JIPEvent alloc] initWithID:@3
                                                   name:@"Bad Plus"
                                               location:CLLocationCoordinate2DMake(-0.1150322,51.4650846)
                                                   date:[today10am dateByAddingTimeInterval:0]];
        event3.type = @"Concert";
        event3.uri = [NSURL URLWithString:@"www.dontfearmistakes.com"];
        event3.ageRestriction = @"14+";
        
        JIPEvent *event4 = [[JIPEvent alloc] initWithID:@3
                                                   name:@"Paris Combo"
                                               location:CLLocationCoordinate2DMake(-0.1150322,51.4650846)
                                                   date:dayAfterTomorrow ];
        event4.type = @"Concert";
        event4.uri = [NSURL URLWithString:@"www.dontfearmistakes.com"];
        event4.ageRestriction = @"14+";
        
        
        //////////////////////////////////////////////////////////////////////////////////////////////
        //ARRAY OF JIPEVENTS
        NSArray *events = [NSArray arrayWithObjects:event4, event2, event3, event1, nil];
        NSLog(@"EventsArray == %@", events);
        
        
        /////////////////////////////////////////////////
        //SORTING ARRAY OF JIPEVENTS BY ASCENDING DATES//
        /////////////////////////////////////////////////
        NSSortDescriptor *dateSortDescriptor = [NSSortDescriptor sortDescriptorWithKey:@"date" ascending:YES];
        NSArray *sortedByDateEventArray = [events sortedArrayUsingDescriptors:[NSArray arrayWithObject:dateSortDescriptor]];
        //AND CHECK
        for (JIPEvent *event in sortedByDateEventArray)
        {
            NSLog(@"dateInSortedEventsArray == %@ - %@ - %@", event.date, event.name, event);
        }
        
        ////////////////////////////////////////////////////
        //CREATE ARRAY WITH ALL DATES AND NO DUPLICATE//
        ////////////////////////////////////////////////////
        NSArray *datesArray = [sortedByDateEventArray valueForKeyPath:@"@distinctUnionOfObjects.date"];
        NSLog(@"All DATES IN ORDER IN ONE ARRAY !! == %@", datesArray);
        
        ///////////////////////////////////////////////////////////////////////
        //CREATE (NSDict*)_upcomingEvents = @ {  (NSDate*) TODAY    : [(JIPEvent*) EVENT1, EVENT2,...],
        //                                       (NSDate*) TOMMOROW : [            EVENT3, EVENT4, ...],
        //                                                                 ... }
        
        NSMutableDictionary *tempUpcomingEvents = [[NSMutableDictionary alloc] init];
        
        for (NSDate *date in datesArray)
        {
            NSMutableArray *mutArray = [[NSMutableArray alloc] init];
            for (JIPEvent *event in sortedByDateEventArray)
            {
                if ([event.date isEqualToDate:date])
                {
                    [mutArray addObject:event];
                }
            }
            [tempUpcomingEvents setObject:mutArray forKey:date];
        }
        
        _upcomingEvents = tempUpcomingEvents;
        
    }
    
    return _upcomingEvents;
}



/////////////////////DATE FORMAT METHOD ////// DATE FORMAT US STYLE///////////////////////////////////////////
-(NSString *)stringFromDate:(NSDate *)date
{
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    dateFormatter.dateStyle = NSDateFormatterLongStyle;
    NSString *string = [dateFormatter stringFromDate:date];
    return string;
}



////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
#pragma mark - Table View Data Source
////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

////////////////////////////////////////////////////////////////
-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    //ONE SECTION FOR EACH DAY
    return [self.upcomingEvents.allKeys count];
}

///////////////////////////////////////////////////////////////////////////////////////
-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    
    NSArray *allKeysArray = self.upcomingEvents.allKeys;
    NSArray *numberOfConcertThisDay = self.upcomingEvents[allKeysArray[section]];
    return numberOfConcertThisDay.count;
}


///////////////////////////////////////////////////////////////////////////////////////////
-(NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
    return [self stringFromDate:self.upcomingEvents.allKeys[section]];
}


/////////////////////////////////////////////////////////////////////////////////////////////////////
-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    
    UITableViewCell *cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:nil];
    JIPEvent *event = self.upcomingEvents[self.upcomingEvents.allKeys[indexPath.section]][indexPath.row];
    
    //CELL GETS EVENT.NAME
    cell.textLabel.text = event.name;
    
    //////2) CELL GETS US FORMATED EVENT.DATE
    cell.detailTextLabel.text  = event.type;
    
    return cell;
}



////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
#pragma mark - Table View Delegate
////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    //CREATE VC////////////////////////
    JIPConcertDetailsViewController *concertDetailsVC = [[JIPConcertDetailsViewController alloc] init];
    
    //PASSING EVENT FROM VC TO VC///////////////////
    concertDetailsVC.event = self.upcomingEvents[self.upcomingEvents.allKeys[indexPath.section]][indexPath.row];
    
    //PUSH VC//////////////////////
    [self.navigationController pushViewController:concertDetailsVC animated:YES];
}


@end
