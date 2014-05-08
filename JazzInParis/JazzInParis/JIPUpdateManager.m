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

@property (strong, nonatomic) NSArray    * favoriteArtists;
@property (nonatomic)         NSUInteger   i;
-(BOOL)eventLocationIsNotTooFarFromParisCenter:(CLLocation*)eventLocation;

@end

@implementation JIPUpdateManager

@synthesize i = _i;

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
    NSMutableArray * dictsOfAllFavoriteConcerts   = [[NSMutableArray alloc]init];
    _i = 0;
    
    //1) Create http requests for all favorite artists
    NSURLSession   * session               = [NSURLSession sharedSession];
    NSFetchRequest * request               = [NSFetchRequest fetchRequestWithEntityName:@"JIPArtist"];
                     request.predicate     = [NSPredicate predicateWithFormat:@"favorite == %@", @YES];

    [[JIPManagedDocument sharedManagedDocument] performBlockWithDocument:^(JIPManagedDocument *managedDocument) {
    
        NSError        * error = nil;
        self.favoriteArtists  = [managedDocument.managedObjectContext executeFetchRequest:request error:&error];
        
        for (JIPArtist * artist in self.favoriteArtists)
        {
            NSURL *url = [self songkickURLUpcomingEventsForArtist:artist];
            
            NSURLSessionDataTask *dataTask = [session dataTaskWithURL:url
                                                    completionHandler:^(NSData *data, NSURLResponse *response, NSError *error) {
                                                        
                                                    #warning TODO
                                                    // 1) Désérialiser la liste des concerts
                                                    NSError *localError = nil;
                                                    NSDictionary *parsedObject = [NSJSONSerialization JSONObjectWithData:data
                                                                                                                 options:0
                                                                                                                   error:&localError];
                                                    if (localError != nil)
                                                        NSLog(@"%@", localError);
                                                    
                                                    // 2) l'ajouter à un NSMutableDictionary (toujours le même)
                                                    NSArray * dictsOfSongkickEventsForArtist = parsedObject[@"resultsPage"][@"results"][@"event"];
                                                             [dictsOfAllFavoriteConcerts addObjectsFromArray:dictsOfSongkickEventsForArtist];
                                                    
                                                    _i++;
                                                        
                                                    // 3) self insertJIPEventsFromJSon et passer ce NSMutableDict en argument
                                                    if (_i == [self.favoriteArtists count])
                                                    {
                                                        [self insertJIPEventsFromJSON:dictsOfAllFavoriteConcerts
                                                                                error:&error];
                                                    }
                                                        
                                                    
                                                    [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:NO];
                                                }];
            [dataTask resume];
            [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:YES];
        }

    }];
    
    
}


////////////////////////////////////////////////////////////////
-(void)updateUpcomingEventsForFavoriteArtist:(JIPArtist *)artist
{
    NSURLSession         * session  = [NSURLSession sharedSession];
    NSURL                * url      = [self songkickURLUpcomingEventsForArtist:artist];
    NSURLSessionDataTask * dataTask = [session dataTaskWithURL:url
                                                completionHandler:^(NSData *data, NSURLResponse *response, NSError *error) {

                                                    //1 Désérialiser
                                                    NSError *localError = nil;
                                                    NSDictionary *parsedObject = [NSJSONSerialization JSONObjectWithData:data
                                                                                                                 options:0
                                                                                                                   error:&localError];
                                                    
                                                    if (localError != nil)
                                                        NSLog(@"%@", localError);
                                                    
                                                    NSArray *dictionnariesOfSongkickEventsForAnArtist = parsedObject[@"resultsPage"][@"results"][@"event"];
                                                    
                                                    [self insertJIPEventsFromJSON:dictionnariesOfSongkickEventsForAnArtist
                                                                            error:&error];
                                                    
                                                    [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:NO];
                                                }];
    [dataTask resume];
    [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:YES];
}





/////////////////////////////////////////////////////////////////////
-(void)insertJIPEventsFromJSON:(NSArray *)arrayOfEventDictsFromApi error:(NSError **)error
{
    
    [[JIPManagedDocument sharedManagedDocument] performBlockWithDocument:^(JIPManagedDocument *managedDocument) {
    
        for (NSDictionary * eventDictFromApi in arrayOfEventDictsFromApi)
        {
            //Pour tous les events reçus de Songkick
            NSMutableDictionary * eventDict = [[NSMutableDictionary alloc]init];
            
            //event details
            eventDict[@"lat"]       = [NSString stringWithFormat:@"%@", eventDictFromApi[@"location"][@"lat"]];
            eventDict[@"long"]      = [NSString stringWithFormat:@"%@", eventDictFromApi[@"location"][@"lng"]];
            
            CLLocation *eventLocation = [[CLLocation alloc] initWithLatitude:[eventDict[@"lat"]  doubleValue]
                                                                   longitude:[eventDict[@"long"] doubleValue]];
            
            //if event dans un rayon de 30km autour de Paris alors insertIntoContext
            if ([self eventLocationIsNotTooFarFromParisCenter:eventLocation])
            {
                
                eventDict[@"id"]        = eventDictFromApi[@"id"];
                eventDict[@"name"]      = eventDictFromApi[@"displayName"];
                eventDict[@"date"]      = [NSDate dateFromAPIString:eventDictFromApi[@"start"][@"date"]] ;
                eventDict[@"startTime"] = eventDictFromApi[@"start"][@"time"] ;
                eventDict[@"venue"]     = eventDictFromApi[@"venue"][@"displayName"];
                eventDict[@"artist"]    = eventDictFromApi[@"performance"][0][@"artist"][@"displayName"] ;
                eventDict[@"uriString"] = eventDictFromApi[@"uri"];
                
                //artist details
                eventDict[@"artistId"]  = eventDictFromApi[@"performance"][0][@"artist"][@"id"];
                eventDict[@"artistUri"] = eventDictFromApi[@"performance"][0][@"artist"][@"uri"];
                
                
                //venue details
                eventDict[@"venueId"]   = eventDictFromApi[@"venue"][@"id"];
                eventDict[@"venueUri"]  = eventDictFromApi[@"venue"][@"uri"];
                eventDict[@"venueName"] = eventDictFromApi[@"venue"][@"displayName"];
                eventDict[@"venueCity"] = eventDictFromApi[@"location"][@"city"];
                
                [JIPEvent eventWithSongkickInfo:eventDict
                         inManagedObjectContext:managedDocument.managedObjectContext];
            }
            
        }
        
        #warning save context
        NSError *error = nil;
        if (![[[JIPManagedDocument sharedManagedDocument] managedObjectContext] save:&error])
        {
            NSLog(@"Can't Save! %@ \r %@", error, [error localizedDescription]);
        }
    
    }];
    
}



-(BOOL)eventLocationIsNotTooFarFromParisCenter:(CLLocation *)eventLocation
{
    CLLocation * parisCenter = [[CLLocation alloc] initWithLatitude:[@"48.862222" doubleValue] longitude:[@"2.34083333333333" doubleValue]];

    CLLocationDistance distanceFromParisCenterToEventLocation = [parisCenter distanceFromLocation:eventLocation];

    if (distanceFromParisCenterToEventLocation < [@"50000" doubleValue])
        return YES;
    else
        return NO;
}




////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////
-(NSURL *)songkickURLUpcomingEventsForArtist:(JIPArtist *)artist
{
    NSString * artistUrlPiece = [NSString stringWithFormat:@"artists/%@/calendar.json", artist.id];
    return [self songkickApiURLWithComponent:artistUrlPiece];
}



-(NSURL *)songkickURLUpcomingEventsForVenueWithId:(NSString *)venueId
{
    //goal : http://api.songkick.com/api/3.0/venues/{venue_id}.json?apikey={your_api_key}
    NSString * venueUrlPiece = [NSString stringWithFormat:@"venues/%@.json", venueId];
    return [self songkickApiURLWithComponent:venueUrlPiece];
}



-(NSURL *)songkickApiURLWithComponent:(NSString*)component
{
    if (!component)
    return nil;

    NSString * songkickAPIString = [NSString stringWithFormat:@"http://api.songkick.com/api/%@/%@?apikey=%@", JIPUpdateManagerSongkickAPIVersion,
                                                                                                              component,
                                                                                                              JIPUpdateManagerSongkickAPIKey];
    return [NSURL URLWithString:songkickAPIString];
}
////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////





-(void)clearOldEvents
{
    
        NSFetchRequest *request            = [NSFetchRequest fetchRequestWithEntityName:@"JIPEvent"];
        NSDate         *tenDaysAgo         = [NSDate dateWithTimeIntervalSinceNow:( -JIPUpdateManagerDeletionDelay * 24 * 60 * 60 )];
                        request.predicate  = [NSPredicate predicateWithFormat:@"date <= %@", tenDaysAgo]; //all JIPEvents older than XX days
            [[JIPManagedDocument sharedManagedDocument] performBlockWithDocument:^(JIPManagedDocument *managedDocument)
            {
                NSError        *error = nil;
                NSArray        *objectsToBeDeleted = [managedDocument.managedObjectContext executeFetchRequest:request
                                                                                                                                    error:&error];
                //S'il y a des events qui date de plus de 10 jours
                if ([objectsToBeDeleted count] != 0)
                //alors on les delete
                for (NSManagedObject* objectToBeDeleted in objectsToBeDeleted)
                [managedDocument.managedObjectContext deleteObject:objectToBeDeleted];
                
                //Puis on sauvegarde le contexte
                #warning save context
                NSError *error2 = nil;
                if (![managedDocument.managedObjectContext save:&error2])
                    NSLog(@"Can't Save! %@ \r %@", error2, [error2 localizedDescription]);
                
            }];
    
}





-(void)clearArtistEvents:(JIPArtist *)artist
{
    
    NSFetchRequest *request     = [NSFetchRequest fetchRequestWithEntityName:@"JIPEvent"];
    request.predicate           = [NSPredicate predicateWithFormat:@"artist.id = %@", artist.id]; //all JIPEvents for this artist
    NSError *error = nil;
    
    //#warning : BUG fetch not working, objectsToBeDeleted is always empty
    NSArray *objectsToBeDeleted = [[JIPManagedDocument sharedManagedDocument].managedObjectContext executeFetchRequest:request
                                                                                                                 error:&error];
    //SI on a des JIPEvents à supprimer
    if (! [objectsToBeDeleted count] == 0)
    {
        [[JIPManagedDocument sharedManagedDocument] performBlockWithDocument:^(JIPManagedDocument *managedDocument) {
           
            for (NSManagedObject* objectToBeDeleted in objectsToBeDeleted)
            [managedDocument.managedObjectContext deleteObject:objectToBeDeleted];
            
        }];
    }
    
    #warning save context
    NSError *error2 = nil;
    if (![[[JIPManagedDocument sharedManagedDocument] managedObjectContext] save:&error])
    {
        NSLog(@"Can't Save! %@ \r %@", error2, [error2 localizedDescription]);
    }
}

@end
