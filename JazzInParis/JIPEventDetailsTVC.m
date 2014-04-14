//
//  JIPEventDetailsTVC.m
//  JazzInParis
//
//  Created by Max on 14/04/14.
//  Copyright (c) 2014 Max. All rights reserved.
//

#import "JIPEventDetailsTVC.h"
#import "JIPVenueMapVC.h"
#import "NSDate+Formatting.h"
#import "JIPManagedDocument.h"
#import "JIPUpdateManager.h"
#import "JIPVenue+Create.h"

@interface JIPEventDetailsTVC ()

@end

@implementation JIPEventDetailsTVC

@synthesize eventImageView     = _eventImageView;
@synthesize concertDateLabel   = _concertDateLabel;
@synthesize event              = _event;
@synthesize venue              = _venue;

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.title = _event.name;
    [JIPDesign applyBackgroundWallpaperInTableView:self.tableView];
    _eventImageView.image = [UIImage imageNamed:@"mathieuchedid"];
    _concertDateLabel  .text = [NSString stringWithFormat:@"%@ @ %@", [NSDate stringFromDate:_event.date], _event.startTime];
    
    //FIXME: mettre une condition if(toutes les infos sur ce venue pas déjà dans core data) pour pas refaire le download à chaque fois
    // Create http request to fetch venue details
    NSURLSession * session  = [NSURLSession sharedSession];
    NSURL *url = [[JIPUpdateManager sharedUpdateManager] songkickURLUpcomingEventsForVenueWithId:[NSString stringWithFormat:@"%@", _event.venue.id]];
    NSURLSessionDataTask *dataTask = [session dataTaskWithURL:url
                                            completionHandler:^(NSData *data, NSURLResponse *response, NSError *error) {
                                                
                                                NSError *localError = nil;
                                                NSDictionary *parsedObject = [NSJSONSerialization JSONObjectWithData:data options:0 error:&localError];
                                                NSDictionary *dictionnaryOfVenue = parsedObject[@"resultsPage"][@"results"][@"venue"];
                                                
                                                [[JIPManagedDocument sharedManagedDocument] performBlockWithDocument:^(JIPManagedDocument *managedDocument)
                                                 {
                                                     _venue = [JIPVenue venueWithDict:@{    @"id"            : dictionnaryOfVenue[@"id"],
                                                                                            @"street"        : dictionnaryOfVenue[@"street"],
                                                                                            @"capacity"      : dictionnaryOfVenue[@"capacity"],
                                                                                            @"desc"          : dictionnaryOfVenue[@"description"],
                                                                                            @"phone"         : dictionnaryOfVenue[@"phone"],
                                                                                            @"websiteString" : dictionnaryOfVenue[@"website"],
                                                                                            @"city"          : dictionnaryOfVenue[@"city"][@"displayName"]
                                                                                            }
                                                               inManagedObjectContext:managedDocument.managedObjectContext];
                                                 }
                                                 ];
                                                
                                            }];
    
    [dataTask resume];
}





-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.section == 2)
    {
        [self performSegueWithIdentifier:@"VenueMapView" sender:nil];
    }
    
    if (indexPath.section == 3)
    {
        [[UIApplication sharedApplication] openURL:[NSURL URLWithString:self.event.uriString]];
    }
    
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
}





-(void)prepareForSegue:(UIStoryboardSegue *)segue
                sender:(id)sender
{
    if ([segue.identifier isEqualToString:@"VenueMapView"])
    {
        JIPVenueMapVC *venueMapVC        = [segue destinationViewController];
        venueMapVC.event  = _event;
        venueMapVC.venue  = _venue;
    }
}

@end
