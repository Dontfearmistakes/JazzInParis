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
//@property = crée var d'instance + getter (return _ivar) + setter _ivar = smthg)
@property (strong, nonatomic) NSDictionary *groupedUpcomingEvents;
@property (strong, nonatomic) NSArray *orderedDates;

-(NSString *)stringFromDate:(NSDate *)date;

@end


@implementation JIPUpComingEventsViewController

/////////////////////////////////////////////////////////////////////////////////////////////////////
/////////////////////////////////////////////////////////////////////////////////////////////////////
/////////////////////////////////////////////////////////////////////////////////////////////////////

-(void)createFakeUpcomingEvents //OBJECTIF : FEED the NSArray* upcomingEvents like the SONGKICK API WILL
{
    NSDate *tomorrow = [NSDate dateWithTimeInterval:(24*60*60) sinceDate:[NSDate date]];
    NSDate *dayAfterTomorrow = [NSDate dateWithTimeInterval:(2*24*60*60) sinceDate:[NSDate date]];

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
    
    self.upcomingEvents = @[event1, event2, event3, event4];
    
}

//////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
//WHEN upomingEvents is filled by the API, MAKE SURE the private internal variables _groupedUpcomingEvents and _orderedDates
//are set to nil so that the get refilled when called (see 2 getters below)
//////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

-(void)setUpcomingEvents:(NSArray *)upcomingEvents
{
    _groupedUpcomingEvents = nil;
    _orderedDates = nil;
    _upcomingEvents = upcomingEvents;
}

//////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
//MAKE SURE _orderedDates is filled when getter called and ivar is still empty
//////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
-(NSArray *)orderedDates
{
    if (!_orderedDates)
    {
        /////////////////////////////////////////////////////////////////////////
        //SORTING ARRAY OF JIPEVENTS (self.upcomingEvents) BY ASCENDING DATES////
        /////////////////////////////////////////////////////////////////////////
        NSSortDescriptor *dateSortDescriptor = [NSSortDescriptor sortDescriptorWithKey:@"date" ascending:YES];
        NSArray *sortedByDateEventsArray = [self.upcomingEvents sortedArrayUsingDescriptors:[NSArray arrayWithObject:dateSortDescriptor]];
        
        ////////////////////////////////////////////////////
        //CREATE ARRAY WITH ALL DATES AND NO DUPLICATE/////
        ////////////////////////////////////////////////////
        _orderedDates = [sortedByDateEventsArray valueForKeyPath:@"@distinctUnionOfObjects.date"];
    }
    return _orderedDates;
}

//////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
//MAKE SURE _groupedUpcomingEvents is filled when getter called and ivar is still empty
//////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
-(NSDictionary*)groupedUpcomingEvents
{
    if (!_groupedUpcomingEvents)
    {
        ///////////////////////////////////////////////////////////////////////
        //CREATE (NSDict*)_upcomingEvents = @ {  (NSDate*) TODAY    : [(JIPEvent*) EVENT1, EVENT2,...],
        //                                       (NSDate*) TOMMOROW : [            EVENT3, EVENT4, ...],
        //                                                                 ... }
        
        NSMutableDictionary *tempUpcomingEvents = [[NSMutableDictionary alloc] init];
        
        //Pour chaque date du tableau des orderedDates...
        for (NSDate *date in self.orderedDates)
        {
            NSMutableArray *mutArray = [[NSMutableArray alloc] init];
            //...check tous les events et...
            for (JIPEvent *event in self.upcomingEvents)
            {
                //si la @property "date" de cet event est égale à la date du tableau des orderedDates
                //ajoute cet objet à un MutArray qui contient donc tous les event à une date précise...
                if ([event.date isEqualToDate:date])
                {
                    [mutArray addObject:event];
                }
            }
            
            //Enfin, une fois tous les events d'une date choppés, on ajoute une entrée au NSDict*
            [tempUpcomingEvents setObject:mutArray forKey:date];
        }
        
        _groupedUpcomingEvents = tempUpcomingEvents;
    }
    
    return _groupedUpcomingEvents;
}


////////////////////////////////////////////
//////////// DATE FORMAT METHOD ////////////
///////////////////////////////////////////
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
    return [self.orderedDates count];
}

///////////////////////////////////////////////////////////////////////////////////////
-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    NSArray *concertsThisDay = self.groupedUpcomingEvents[self.orderedDates[section]];
    return concertsThisDay.count;
}

///////////////////////////////////////////////////////////////////////////////////////////
-(NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
    return [self stringFromDate:self.orderedDates[section]];
}

/////////////////////////////////////////////////////////////////////////////////////////////////////
-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"eventCell"];
    if (!cell)
    {
        cell = [[UITableViewCell alloc]initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:@"eventCell"];
    }
                             
    JIPEvent *event = self.groupedUpcomingEvents[self.orderedDates[indexPath.section]][indexPath.row];
    
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
    concertDetailsVC.event = self.groupedUpcomingEvents[self.orderedDates[indexPath.section]][indexPath.row];
    
    //PUSH VC//////////////////////
    [self.navigationController pushViewController:concertDetailsVC animated:YES];
}


@end
