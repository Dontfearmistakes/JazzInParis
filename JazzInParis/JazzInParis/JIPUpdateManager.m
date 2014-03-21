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

static const int JIPUpdateManagerDeletionDelay = 10; //After how many days in the past should a JIPEvent be deleted from de batabase ?
static NSString const * JIPUpdateManagerSongkickAPIVersion = @"3.0";
static NSString const * JIPUpdateManagerSongkickAPIKey = @"vUGmX4egJWykM1TA";

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
    //1) Clear old events (older than X days)
    [self clearOldEvents];
    
    //2) Create http request
    NSURLSession * session = [NSURLSession sharedSession];
    NSURL *url = [self songkickURLUpcomingEventsForArtist:nil];
    NSURLSessionDataTask *dataTask = [session dataTaskWithURL:url
                                            completionHandler:^(NSData *data, NSURLResponse *response, NSError *error) {
                                                
               //NSLog(@"DATA : %@", [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding]);
               // FIXME:ICI JSON into NSDict (parser) cf NSJSONSerialisation
               // + Créer object avec les attributes
               // + Insert them intoContext
               // Objectif : méthodes réutilisables pour autres appels
               // ex : constantes pour les keys de retour de Songkick (mettre dans .h pour utilisation publique et nottament par JIPEvent + Create pour modifier les eventDict[keyFromSongkick])
                                                
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
    
    NSArray *dictionnariesOfEvents = parsedObject[@"resultsPage"][@"results"][@"event"];
    for (NSDictionary * dictionnaryOfEvent in dictionnariesOfEvents)
    {
        NSMutableDictionary * eventDict = [[NSMutableDictionary alloc]init];
        [eventDict setValue:dictionnaryOfEvent[@"id"]                                                  forKey:@"id"];
        [eventDict setValue:dictionnaryOfEvent[@"displayName"]                                         forKey:@"name"];
        [eventDict setValue:[NSString stringWithFormat:@"%@", dictionnaryOfEvent[@"location"][@"lat"]] forKey:@"lat"];
        [eventDict setValue:[NSString stringWithFormat:@"%@", dictionnaryOfEvent[@"location"][@"lng"]] forKey:@"long"];
        [eventDict setValue:[NSDate dateFromAPIString:dictionnaryOfEvent[@"start"][@"date"]]           forKey:@"date"];
        [eventDict setValue:dictionnaryOfEvent[@"venue"][@"displayName"]                               forKey:@"venue"];
        [eventDict setValue:dictionnaryOfEvent[@"performance"][0][@"artist"][@"displayName"]           forKey:@"artist"];
        [eventDict setValue:dictionnaryOfEvent[@"type"]                                                forKey:@"type"];
        [eventDict setValue:dictionnaryOfEvent[@"uri"]                                                 forKey:@"uriString"];
        [eventDict setValue:[NSString stringWithFormat:@"%@", dictionnaryOfEvent[@"ageRestriction"]]   forKey:@"ageRestriction"];
        [eventDict setValue:dictionnaryOfEvent[@"venue"][@"id"]                                        forKey:@"venueId"];
        
        [eventDict setValue:dictionnaryOfEvent[@"performance"][0][@"artist"][@"id"]  forKey:@"artistId"];
        [eventDict setValue:dictionnaryOfEvent[@"performance"][0][@"artist"][@"uri"] forKey:@"artistUri"];
        
        [eventDict setValue:dictionnaryOfEvent[@"venue"][@"capacity"]                forKey:@"venueCapacity"];
        [eventDict setValue:dictionnaryOfEvent[@"venue"][@"city"][@"displayName"]    forKey:@"venueCity"];
        [eventDict setValue:dictionnaryOfEvent[@"venue"][@"description"]             forKey:@"venueDesc"];
        [eventDict setValue:dictionnaryOfEvent[@"venue"][@"id"]                      forKey:@"venueId"];
        [eventDict setValue:[NSString stringWithFormat:@"%@", dictionnaryOfEvent[@"venue"][@"lat"]]                     forKey:@"venueLat"];
        [eventDict setValue:[NSString stringWithFormat:@"%@", dictionnaryOfEvent[@"venue"][@"lng"]]                     forKey:@"venueLong"];
        [eventDict setValue:dictionnaryOfEvent[@"venue"][@"displayName"]             forKey:@"venueName"];
        [eventDict setValue:dictionnaryOfEvent[@"venue"][@"phone"]                   forKey:@"venuePhone"];
        [eventDict setValue:dictionnaryOfEvent[@"venue"][@"street"]                  forKey:@"venueStreet"];
        [eventDict setValue:dictionnaryOfEvent[@"venue"][@"website"]                 forKey:@"venueWebsite"];
        
        
        [[JIPManagedDocument sharedManagedDocument] performBlockWithDocument:^(JIPManagedDocument *managedDocument) {

             [JIPEvent eventWithSongkickInfo:eventDict
                      inManagedObjectContext:managedDocument.managedObjectContext];
        }];
    }
    
}
















/////////////////////////////////////////////////////////////////////
/////////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////
-(NSURL *)songkickURLUpcomingEventsForArtist:(JIPArtist *)artist
{
    if (!artist) {
        NSString * artistUrlPiece = [NSString stringWithFormat:@"artists/%@/calendar.json", @76327];
        return [self songkickApiURLWithComponent:artistUrlPiece];
    }
    
    NSString * artistUrlPiece = [NSString stringWithFormat:@"artists/%@/calendar.json", artist.id];
    return [self songkickApiURLWithComponent:artistUrlPiece];
}

////////////////////////////////////////////////////////////////
-(NSURL *)songkickURLUpcomingEventsForVenueWithId:(NSString *)venueId
{
    NSString * venueUrlPiece = [NSString stringWithFormat:@"venues/%@.json", venueId];
    return [self songkickApiURLWithComponent:venueUrlPiece];
}

///////////////////////////////////////////////////////
-(NSURL *)songkickApiURLWithComponent:(NSString*)component
{
    if (!component) {
        return nil;
    }

    NSString * songkickAPIString = [NSString stringWithFormat:@"http://api.songkick.com/api/%@/%@?apikey=%@", JIPUpdateManagerSongkickAPIVersion, component, JIPUpdateManagerSongkickAPIKey];
    return [NSURL URLWithString:songkickAPIString];
}





/////////////////////
-(void)clearOldEvents
{
    [[JIPManagedDocument sharedManagedDocument] performBlockWithDocument:^(JIPManagedDocument *managedDocument) {
        
        NSFetchRequest *request = [NSFetchRequest fetchRequestWithEntityName:@"JIPEvent"];
        NSDate *tenDaysAgo= [NSDate dateWithTimeIntervalSinceNow:( -JIPUpdateManagerDeletionDelay * 24 * 60 * 60 )];
        request.predicate = [NSPredicate predicateWithFormat:@"date <= %@", tenDaysAgo]; //all JIPEvents starting today or later
        NSError *error = nil;
        NSArray *objectsToBeDeleted = [managedDocument.managedObjectContext executeFetchRequest:request
                                                                                   error:&error];
        
        if (!objectsToBeDeleted)
        {
            for (NSManagedObject* objectToBeDeleted in objectsToBeDeleted)
            {
                [managedDocument.managedObjectContext deleteObject:objectToBeDeleted];
            }
        }
    }];
}

@end
