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
//proprietés privée
@property (strong, nonatomic) NSArray *upcomingEvents;
//@property = crée var d'instance + getter (return _ivar) + setter _ivar = smthg)

@end



@implementation JIPUpComingEventsViewController

-(NSArray *)upcomingEvents
{
    if (!_upcomingEvents)
    {
        JIPEvent *event = [[JIPEvent alloc] initWithID:@1
                                                  name:@"Vampire WeekEnd"
                                              location:CLLocationCoordinate2DMake(-0.1150322,51.4650846)
                                                  date:[NSDate date]];
        event.type = @"Concert";
        event.uri = [NSURL URLWithString:@"www.dontfearmistakes.com"];
        event.ageRestriction = @"14+";

        _upcomingEvents = @[event];
    }
    
    return _upcomingEvents;
}

//methods TABLE VIEW DATA SOURCE
// Using #pragma mark makes method list prettier
#pragma mark - Table View Data Source

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return self.upcomingEvents.count;
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:nil];
    JIPEvent *event = self.upcomingEvents[indexPath.row];
    
    //CELL GETS EVENT.NAME
    cell.textLabel.text = event.name;
    
    //CELL GETS EVENT.DATE
    //////1) DATE FORMAT US STYLE
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateStyle:NSDateFormatterLongStyle];
    NSLocale *usLocale = [[NSLocale alloc] initWithLocaleIdentifier:@"en_US"];
    [dateFormatter setLocale:usLocale];
    //////2) CELL GETS FORMATED DATE
    cell.detailTextLabel.text  = [dateFormatter stringFromDate:event.date];
    
    return cell;
}

////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    //CREATE VC////////////////////////
    JIPConcertDetailsViewController *concertDetailsVC = [[JIPConcertDetailsViewController alloc] init];
    JIPEvent *event = self.upcomingEvents[indexPath.row];
    
    //PASSING DATA FROM MODEL TO VC///////////////////
    concertDetailsVC.name = event.name;
    concertDetailsVC.uri = event.uri;
    concertDetailsVC.location = event.location;
    concertDetailsVC.date = event.date;
    
    //PUSH VC//////////////////////
    [self.navigationController pushViewController:concertDetailsVC animated:YES];
}


@end
