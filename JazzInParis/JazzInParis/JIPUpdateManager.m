//
//  JIPUpdateManager.m
//  JazzInParis
//
//  Created by Max on 19/03/14.
//  Copyright (c) 2014 Max. All rights reserved.
//

#import "JIPUpdateManager.h"
#import "JIPManagedDocument.h"
#import <CoreData/CoreData.h>
#import "JIPArtist+Create.h"
#import "JIPEvent+Create.h"
#import "JIPVenue+Create.h"
#import "JIPEvent.h"
#import "NSDate+Formatting.h"



static JIPUpdateManager * _sharedUpdateManager;

static const int JIPUpdateManagerDeletionDelay = 10; //After how many days in the past should a JIPEvent be deleted from the batabase ?
static NSString const * JIPUpdateManagerSongkickAPIVersion = @"3.0";
static NSString const * JIPUpdateManagerSongkickAPIKey = @"vUGmX4egJWykM1TA";

@interface JIPUpdateManager ()

@property (strong, nonatomic) NSArray * favoriteArtists;
@property (strong, nonatomic) JIPVenue * venue;

@end

@implementation JIPUpdateManager

/////////////////////////////////////////////////////////////////////////////////////////////////
// First time it's called, create an instance of JIPUIUpdateManager and put it in the static ivar
// Then returns always this ivar
//////////////////////////////////////////////////////////////////////////////
+(JIPUpdateManager *)sharedUpdateManager
{
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _sharedUpdateManager = [[JIPUpdateManager alloc] init];
    });
    
    return _sharedUpdateManager;
}



/////////////////////////////////////////////////////////////
// 1) Download JSON (-updateUpcomingEvents)
// 2) Parse and Insert in context (- insertJIPEventsFromJSON)
/////////////////////////////////////////////////////////////
-(void)updateUpcomingEvents
{
    //1) Create http requests for all favorite artists
    NSURLSession * session  = [NSURLSession sharedSession];
    
    NSFetchRequest *request = [NSFetchRequest fetchRequestWithEntityName:@"JIPArtist"];
    request.predicate       = [NSPredicate predicateWithFormat:@"favorite == %@", @YES];
    NSError *error = nil;
    
    self.favoriteArtists = [[JIPManagedDocument sharedManagedDocument].managedObjectContext executeFetchRequest:request error:&error];
    
    for (JIPArtist * artist in self.favoriteArtists)
    {
        NSURL *url = [self songkickURLUpcomingEventsForArtist:artist];
        NSURLSessionDataTask *dataTask = [session dataTaskWithURL:url
                                                completionHandler:^(NSData *data, NSURLResponse *response, NSError *error) {
                                                    
                                                    [self insertJIPEventsFromJSON:data error:&error];
                                                }];
        [dataTask resume];
    }
}

-(void)updateUpcomingEventsForFavoriteArtist:(JIPArtist *)artist
{
    NSURLSession * session  = [NSURLSession sharedSession];
    NSURL *url = [self songkickURLUpcomingEventsForArtist:artist];
    NSURLSessionDataTask *dataTask = [session dataTaskWithURL:url
                                                completionHandler:^(NSData *data, NSURLResponse *response, NSError *error) {
                                                    
                                                    [self insertJIPEventsFromJSON:data error:&error];
                                                }];
    [dataTask resume];
}

/////////////////////////////////////////////////////////////////////
-(void)insertJIPEventsFromJSON:(NSData *)JsonData error:(NSError **)error
{
    NSError *localError = nil;
    NSDictionary *parsedObject = [NSJSONSerialization JSONObjectWithData:JsonData options:0 error:&localError];
    if (localError != nil) {
        *error = localError;
        NSLog(@"%@", error);
    }
    
    NSArray *dictionnariesOfEventsFromApi = parsedObject[@"resultsPage"][@"results"][@"event"];
    
    [[JIPManagedDocument sharedManagedDocument] performBlockWithDocument:^(JIPManagedDocument *managedDocument) {
        
        for (NSDictionary * dictionnaryFromApi in dictionnariesOfEventsFromApi)
        {
            NSMutableDictionary * eventDict = [[NSMutableDictionary alloc]init];
            
            //event details
            eventDict[@"id"]        = dictionnaryFromApi[@"id"];
            eventDict[@"name"]      = dictionnaryFromApi[@"displayName"];
            eventDict[@"lat"]       = [NSString stringWithFormat:@"%@", dictionnaryFromApi[@"location"][@"lat"]];
            eventDict[@"long"]      = [NSString stringWithFormat:@"%@", dictionnaryFromApi[@"location"][@"lng"]];
            eventDict[@"date"]      = [NSDate dateFromAPIString:dictionnaryFromApi[@"start"][@"date"]] ;
            eventDict[@"venue"]     = dictionnaryFromApi[@"venue"][@"displayName"];
            eventDict[@"artist"]    = dictionnaryFromApi[@"performance"][0][@"artist"][@"displayName"] ;
            eventDict[@"uriString"] = dictionnaryFromApi[@"uri"];
            
            //artist details
            eventDict[@"artistId"]  = dictionnaryFromApi[@"performance"][0][@"artist"][@"id"];
            eventDict[@"artistUri"] = dictionnaryFromApi[@"performance"][0][@"artist"][@"uri"];
            
            
            //venue details
            eventDict[@"venueId"]   = dictionnaryFromApi[@"venue"][@"id"];
            eventDict[@"venueUri"]  = dictionnaryFromApi[@"venue"][@"uri"];
            eventDict[@"venueName"] = dictionnaryFromApi[@"venue"][@"displayName"];
            eventDict[@"venueCity"] = dictionnaryFromApi[@"location"][@"city"];
            

            [JIPEvent eventWithSongkickInfo:eventDict
                     inManagedObjectContext:managedDocument.managedObjectContext];
        }
    }];
    
}


-(JIPVenue *)venueFromSongkickWithId:(NSString *)venueId
{
    //1) Create http request
    NSURLSession * session  = [NSURLSession sharedSession];
    NSURL *url = [self songkickURLUpcomingEventsForVenueWithId:venueId];

    NSURLSessionDataTask *dataTask = [session dataTaskWithURL:url
                                            completionHandler:^(NSData *data, NSURLResponse *response, NSError *error) {
                                                
                                                NSError *localError = nil;
                                                NSDictionary *parsedObject = [NSJSONSerialization JSONObjectWithData:data options:0 error:&localError];
                                                NSDictionary *dictionnaryOfVenue = parsedObject[@"resultsPage"][@"results"][@"venue"];

                                                [[JIPManagedDocument sharedManagedDocument] performBlockWithDocument:^(JIPManagedDocument *managedDocument) {
                                                    
                                                        self.venue = [JIPVenue venueWithDict:@{@"id"               : dictionnaryOfVenue[@"id"],
                                                                                               @"street"           : dictionnaryOfVenue[@"street"],
                                                                                               @"capacity"         : dictionnaryOfVenue[@"capacity"],
                                                                                               @"desc"             : dictionnaryOfVenue[@"description"],
                                                                                               @"phone"            : dictionnaryOfVenue[@"phone"],
                                                                                               @"websiteString"    : dictionnaryOfVenue[@"website"]
                                                                                               }
                                                                      inManagedObjectContext:managedDocument.managedObjectContext];
                                                    }
                                                ];
                                            }];
                                        
    [dataTask resume];

    return self.venue;
}



/////////////////////////////////////////////////////////////////////
/////////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////
-(NSURL *)songkickURLUpcomingEventsForArtist:(JIPArtist *)artist
{
    NSString * artistUrlPiece = [NSString stringWithFormat:@"artists/%@/calendar.json", artist.id];
    return [self songkickApiURLWithComponent:artistUrlPiece];
}

////////////////////////////////////////////////////////////////
-(NSURL *)songkickURLUpcomingEventsForVenueWithId:(NSString *)venueId
{
    //goal : http://api.songkick.com/api/3.0/venues/{venue_id}.json?apikey={your_api_key}
    NSString * venueUrlPiece = [NSString stringWithFormat:@"venues/%@.json", venueId];
    return [self songkickApiURLWithComponent:venueUrlPiece];
}

///////////////////////////////////////////////////////
-(NSURL *)songkickApiURLWithComponent:(NSString*)component
{
    if (!component)
    return nil;

    NSString * songkickAPIString = [NSString stringWithFormat:@"http://api.songkick.com/api/%@/%@?apikey=%@", JIPUpdateManagerSongkickAPIVersion,
                                                                                                              component,
                                                                                                              JIPUpdateManagerSongkickAPIKey];
    return [NSURL URLWithString:songkickAPIString];
}





/////////////////////
-(void)clearOldEvents
{
    
        NSFetchRequest *request     = [NSFetchRequest fetchRequestWithEntityName:@"JIPEvent"];
        NSDate         *tenDaysAgo  = [NSDate dateWithTimeIntervalSinceNow:( -JIPUpdateManagerDeletionDelay * 24 * 60 * 60 )];
        request.predicate           = [NSPredicate predicateWithFormat:@"date <= %@", tenDaysAgo]; //all JIPEvents older than XX days
        NSError *error = nil;
        NSArray *objectsToBeDeleted = [[JIPManagedDocument sharedManagedDocument].managedObjectContext executeFetchRequest:request
                                                                                   error:&error];
        
        if (objectsToBeDeleted != nil)
        for (NSManagedObject* objectToBeDeleted in objectsToBeDeleted)
        [[JIPManagedDocument sharedManagedDocument].managedObjectContext deleteObject:objectToBeDeleted];
    
    
}

/////////////////////
-(void)clearArtistEvents:(JIPArtist *)artist
{
    
    NSFetchRequest *request     = [NSFetchRequest fetchRequestWithEntityName:@"JIPEvent"];
    request.predicate           = [NSPredicate predicateWithFormat:@"id = %@", artist.id]; //all JIPEvents for this artist
    NSError *error = nil;
    NSArray *objectsToBeDeleted = [[JIPManagedDocument sharedManagedDocument].managedObjectContext executeFetchRequest:request
                                                                                                                 error:&error];
    
    if (objectsToBeDeleted != nil)
        for (NSManagedObject* objectToBeDeleted in objectsToBeDeleted)
            [[JIPManagedDocument sharedManagedDocument].managedObjectContext deleteObject:objectToBeDeleted];
    
    
}

@end
