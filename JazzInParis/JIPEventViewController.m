//
//  JIPEventViewController.m
//  JazzInParis
//
//  Created by Max on 09/04/14.
//  Copyright (c) 2014 Max. All rights reserved.
//

#import "JIPEventViewController.h"
#import "JIPVenueMapVC.h"
#import "NSDate+Formatting.h"
#import "JIPManagedDocument.h"
#import "JIPUpdateManager.h"
#import "JIPVenue+Create.h"

@interface JIPEventViewController ()

@end

@implementation JIPEventViewController

@synthesize concertDateLabel   = _concertDateLabel;
@synthesize concertNameLabel   = _concertNameLabel;

@synthesize checkMapButton     = _checkMapButton;
@synthesize event              = _event;
@synthesize venue              = _venue;


- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    _concertNameLabel  .text = _event.name;
    _concertDateLabel  .text = [NSDate stringFromDate:_event.date];
        
    
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



- (IBAction)checkMapClick:(id)sender
{
    [self performSegueWithIdentifier:@"VenueMapView" sender:nil];
}



- (IBAction)concertDetailsClick:(id)sender
{
    [[UIApplication sharedApplication] openURL:[NSURL URLWithString:self.event.uriString]];
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
