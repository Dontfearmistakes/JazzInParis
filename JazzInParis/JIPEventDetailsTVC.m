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
#import "AFNetworking/AFHTTPRequestOperation.h"

@interface JIPEventDetailsTVC ()

@end

@implementation JIPEventDetailsTVC

@synthesize artistImageView    = _artistImageView;
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
    
    /////////////////////////////////////
    // A) REQUEST POUR L'IMAGE ID
    /////////////////////////////////////
    NSString* nsutf8ArtistName = [[_event.artist.name stringByReplacingOccurrencesOfString:@" " withString:@"_"] lowercaseString];
    // convert to a data object, using a lossy conversion to ASCII
    NSData *asciiEncoded = [nsutf8ArtistName dataUsingEncoding:NSASCIIStringEncoding
                                          allowLossyConversion:YES];
    
    // take the data object and recreate a string using the lossy conversion
    NSString *cleanArtistName = [[NSString alloc] initWithData:asciiEncoded
                                                      encoding:NSASCIIStringEncoding];
    
    
    NSURLRequest            *requestImgId                        = [NSURLRequest requestWithURL:[NSURL URLWithString:[NSString stringWithFormat:@"https://www.googleapis.com/freebase/v1/topic/en/%@?filter=/common/topic/image&limit=1", cleanArtistName]]];
    AFHTTPRequestOperation *operationForImgId                    = [[AFHTTPRequestOperation alloc] initWithRequest:requestImgId];
    operationForImgId.responseSerializer = [AFJSONResponseSerializer serializer];
    
    [operationForImgId
     setCompletionBlockWithSuccess:^(AFHTTPRequestOperation *operation, id responseObject)
     {
         
         //S'il y a bien des résultats
         if ([[[responseObject objectForKey:@"property"] objectForKey:@"/common/topic/image" ] objectForKey:@"values"] > 0)
         {
             //On récupère l'id et la taille de la 1ère image
             NSString *imageId = [[NSString alloc]  initWithString:[[[[[responseObject objectForKey:@"property"] objectForKey:@"/common/topic/image" ] objectForKey:@"values"] objectAtIndex:0] objectForKey:@"id"]];
             
             
             /////////////////////////////////////
             // B) REQUEST POUR L'IMAGE ELLE MEME
             /////////////////////////////////////
             NSURLRequest            *requestImg                         = [NSURLRequest requestWithURL:[NSURL URLWithString:[NSString stringWithFormat:@"https://usercontent.googleapis.com/freebase/v1/image%@?maxwidth=2020&maxheight=2020&minwidth=1020&minheight=2020",imageId]]];
             AFHTTPRequestOperation *operationForImg                     = [[AFHTTPRequestOperation alloc] initWithRequest:requestImg];
             operationForImg.responseSerializer  = [AFImageResponseSerializer serializer];
             [operationForImg
              
              setCompletionBlockWithSuccess:^(AFHTTPRequestOperation *operation, id responseObject)
              {
                  UIImage * responseImg = responseObject;
                  _artistImageView.image = responseImg;
                  
                  [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:NO];
              }
              
              failure:^(AFHTTPRequestOperation *operation, NSError *error)
              {
                  NSLog(@"Image error: %@", error);
                  [_artistImageView setImage:[UIImage imageNamed:@"errorImage"]];
              }];
             [operationForImg start];
             
         }
         
         //S'il n'y a pas de résultats
         else
         {
             [_artistImageView setImage:[UIImage imageNamed:@"errorImage"]];
             [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:NO];
         }
     }
     
     failure:^(AFHTTPRequestOperation *operation, NSError *error)
     {
         NSLog(@"Error: %@", error);
         [_artistImageView setImage:[UIImage imageNamed:@"errorImage"]];
         [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:NO];
         
     }];
    
    [operationForImgId start];
    [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:YES];
    [self performSelector:@selector(noImgAvailable) withObject:nil afterDelay:1.5];
}

-(void)noImgAvailable
{
    if (!_artistImageView.image)
        [_artistImageView setImage:[UIImage imageNamed:@"errorImage"]];
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
