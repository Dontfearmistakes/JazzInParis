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
@property (strong, nonatomic) NSArray *allNSDates;
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
        JIPEvent *event1 = [[JIPEvent alloc] initWithID:@1
                                                  name:@"Vampire WeekEnd"
                                              location:CLLocationCoordinate2DMake(-0.1150322,51.4650846)
                                                  date:[NSDate date]  ];
        event1.type = @"Concert";
        event1.uri = [NSURL URLWithString:@"www.dontfearmistakes.com"];
        event1.ageRestriction = @"14+";
        
        JIPEvent *event2 = [[JIPEvent alloc] initWithID:@2
                                                  name:@"Brad Mehldau"
                                              location:CLLocationCoordinate2DMake(-0.1150322,51.4650846)
                                                  date:[NSDate date]];
        event2.type = @"Concert";
        event2.uri = [NSURL URLWithString:@"www.dontfearmistakes.com"];
        event2.ageRestriction = @"14+";
        
        JIPEvent *event3 = [[JIPEvent alloc] initWithID:@3
                                                   name:@"Bad Plus"
                                               location:CLLocationCoordinate2DMake(-0.1150322,51.4650846)
                                                   date:tomorrow];
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
        

        //CREATES NSDICT :: DATE : EVENT
        _upcomingEvents = @{
                             [NSDate date] : @[event1, event2],
                             tomorrow : @[event3],
                             dayAfterTomorrow : @[event4]
                            };
    }
    
    return _upcomingEvents;
}


//////////////////////
-(NSArray *)allNSDates
{
    if (!_allNSDates)
    {
        //CREATE NSARRAY WITH ALL DATES TO ACCESS EACH EVENT THROUGH self.upcomingEvents[self.allDates[indexPath.row]]
        _allNSDates = [self.upcomingEvents allKeys];
    }
    return _allNSDates;
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


-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    self.concertsOnDay = self.upcomingEvents[self.allNSDates[section]];
    NSLog(@"number of rows in section %lu : %ld", (long)section, (unsigned long)self.concertsOnDay.count);
    return self.concertsOnDay.count;
}


////////////////////////////////////////////////////////////////
-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    //ONE SECTION FOR EACH DAY
    NSLog(@"number of sections : %lu", (unsigned long)self.allNSDates.count);
    return self.allNSDates.count;
}


///////////////////////////////////////////////////////////////////////////////////////////
-(NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
    return [self stringFromDate:self.allNSDates[section]];
}


/////////////////////////////////////////////////////////////////////////////////////////////////////
-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    
    UITableViewCell *cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:nil];
    JIPEvent *event = self.upcomingEvents[self.allNSDates[indexPath.section]][indexPath.row];
    
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
    JIPEvent *event = self.upcomingEvents[self.allNSDates[indexPath.row]];
    
    //PASSING DATA FROM MODEL TO VC///////////////////
    concertDetailsVC.name = event.name;
    concertDetailsVC.uri = event.uri;
    concertDetailsVC.location = event.location;
    concertDetailsVC.date = event.date;
    
    //PUSH VC//////////////////////
    [self.navigationController pushViewController:concertDetailsVC animated:YES];
}


@end
