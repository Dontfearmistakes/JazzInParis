//
//  JIPUpComingEventsViewController.m
//  JazzInParis
//
//  Created by Max on 02/02/14.
//  Copyright (c) 2014 Max. All rights reserved.
//

#import "JIPUpComingEventsViewController.h"
#import "JIPEvent.h"

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
        JIPEvent *event = [[JIPEvent alloc] init];
        event.id = @1;
        event.type = @"Concert";
        event.date = [NSDate date];
        event.name = @"Vampire WeekEnd";
        event.uri = [NSURL URLWithString:@"www.dontfearmistakes.com"];
        event.ageRestriction = @"14+";
        event.location = CLLocationCoordinate2DMake(-0.1150322,51.4650846);
        
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
    cell.textLabel.text = event.name;
    cell.detailTextLabel.text = [NSString stringWithFormat:@"%@", event.date];
    
    return cell;
}


@end
