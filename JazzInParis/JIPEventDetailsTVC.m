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

@synthesize artistImageView     = _artistImageView;
@synthesize concertDateLabel   = _concertDateLabel;
@synthesize event              = _event;
@synthesize venue              = _venue;



- (void)viewDidLoad
{
    [super viewDidLoad];
    
    //BackgroundImage
    [JIPDesign applyBackgroundWallpaperInTableView:self.tableView];
    
    //Remove space between navBar and 1st cell
    if ([[UIDevice currentDevice].systemVersion floatValue] >= 7){
        self.tableView.contentInset = UIEdgeInsetsMake(-35, 0, 0, 0);
    }

    //Labels
    self.title             = _event.name;
    _concertDateLabel.text = [NSString stringWithFormat:@"%@ @ %@", [NSDate stringFromDate:_event.date], _event.startTime];
    
    
    // Fetch venue details in prevision of next VC
    NSURLSession        * session  = [NSURLSession sharedSession];
    NSURL                     *url = [[JIPUpdateManager sharedUpdateManager] songkickURLUpcomingEventsForVenueWithId:[NSString stringWithFormat:@"%@", _event.venue.id]];
    NSURLSessionDataTask *dataTask = [session dataTaskWithURL:url
                                            completionHandler:^(NSData *data, NSURLResponse *response, NSError *error) {
                                                
                                                NSError      *localError = nil;
                                                NSDictionary *parsedObject = [NSJSONSerialization JSONObjectWithData:data options:0 error:&localError];
                                                NSDictionary *dictionnaryOfVenue = parsedObject[@"resultsPage"][@"results"][@"venue"];
                                                
                                               
                                                     _venue = [JIPVenue venueWithDict:@{    @"id"            : dictionnaryOfVenue[@"id"],
                                                                                            @"street"        : dictionnaryOfVenue[@"street"],
                                                                                            @"capacity"      : dictionnaryOfVenue[@"capacity"],
                                                                                            @"desc"          : dictionnaryOfVenue[@"description"],
                                                                                            @"phone"         : dictionnaryOfVenue[@"phone"],
                                                                                            @"websiteString" : dictionnaryOfVenue[@"website"],
                                                                                            @"city"          : dictionnaryOfVenue[@"city"][@"displayName"]
                                                                                        }
                                                               inManagedObjectContext:[JIPManagedDocument sharedManagedDocument].managedObjectContext];
                                                
                                                
                                                [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:NO];
                                                
                                            }];
    
    [dataTask resume];
    [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:YES];
}




-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    //fetching GoogleImage
    NSURLSession * session         = [NSURLSession sharedSession];
    NSString     * cleanArtistName = [_event.artist.name stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
    NSURL        *             url = [NSURL URLWithString:[NSString stringWithFormat:@"https://ajax.googleapis.com/ajax/services/search/images?v=1.0&q=%@", cleanArtistName]];
    
    NSURLSessionDataTask *dataTask = [session dataTaskWithURL:url
                                            completionHandler:^(NSData *data, NSURLResponse *response, NSError *error) {
                                                
                                                NSError      *localError   = nil;
                                                NSDictionary *parsedObject = [NSJSONSerialization JSONObjectWithData:data options:0 error:&localError];
                                                NSString     * imageId     = parsedObject[@"responseData"][@"results"][0][@"imageId"];
                                                
                                                NSURL *imageUrl = [NSURL URLWithString:[NSString stringWithFormat:@"http://t1.gstatic.com/images?q=tbn:%@",imageId]];
                                                NSData *myData  = [NSData dataWithContentsOfURL:imageUrl];
                                                UIImage *googleImage  = [[UIImage alloc] initWithData:myData];
                                                
                                                [_artistImageView setImage:googleImage];
                                                
                                                [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:NO];
                                            }];
    [dataTask resume];
    [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:YES];
}




-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    //VenueMap
    if (indexPath.section == 2)
    {
        [self performSegueWithIdentifier:@"VenueMapView" sender:nil];
    }
    //Songkick.com
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
