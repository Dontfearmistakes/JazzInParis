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

-(NSDateFormatter *)dateFormatter;

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
        event3.type = @"Concert";
        event3.uri = [NSURL URLWithString:@"www.dontfearmistakes.com"];
        event3.ageRestriction = @"14+";

        //CREATES NSDICT :: DATE : EVENT
        _upcomingEvents = @{
                             [NSDate date] : @[event1, event2],
                             tomorrow : @[event3],
                             dayAfterTomorrow : @[event4]
                            };

        //CREATE NSARRAY WITH ALL DATES TO ACCESS EACH EVENT THROUGH self.upcomingEvents[self.allDates[indexPath.row]]
        self.allNSDates = [self.upcomingEvents allKeys];

    }
    
    return _upcomingEvents;
}

/////////////////////DATE FORMAT METHOD ////// DATE FORMAT US STYLE///////////////////////////////////////////
-(NSDateFormatter *)dateFormatter
{
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateStyle:NSDateFormatterLongStyle];
    NSLocale *usLocale = [[NSLocale alloc] initWithLocaleIdentifier:@"en_US"];
    [dateFormatter setLocale:usLocale];
    return dateFormatter;
}

////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
#pragma mark - Table View Data Source
////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////


-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    switch (section) {
        case 0:
            
            self.concertsOnDay = self.upcomingEvents[self.allNSDates[0]];
            NSLog(@"number of rows in section %lu : %ld", (long)section, (unsigned long)self.concertsOnDay.count);
        
            return self.concertsOnDay.count;
            break;
            
        case 1:
            self.concertsOnDay = self.upcomingEvents[self.allNSDates[1]];
            NSLog(@"number of rows in section %lu : %ld", (long)section, (unsigned long)self.concertsOnDay.count);

            return self.concertsOnDay.count;
            break;
            
        default:
            self.concertsOnDay = self.upcomingEvents[self.allNSDates[1]];
            return self.concertsOnDay.count;
            break;
    }

}


-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    //ONE SECTION FOR EACH DAY
    NSLog(@"number of sections : %lu", (unsigned long)self.upcomingEvents.count);
    return self.upcomingEvents.count;
    
}


-(NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
    return [NSString stringWithFormat:@"%@", [self.dateFormatter stringFromDate:self.allNSDates[section]] ];
}

////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
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
