//
//  JIPEvent+Create.m
//  JazzInParis
//
//  Created by Max on 11/03/14.
//  Copyright (c) 2014 Max. All rights reserved.
//

#import "JIPEvent+Create.h"
#import "JIPVenue+Create.h"
#import "JIPArtist+Create.h"

@implementation JIPEvent (Create)

+ (JIPEvent *)eventWithSongkickInfo:(NSDictionary *)eventDictionary
             inManagedObjectContext:(NSManagedObjectContext *)context
{
    //On cherche si l'event qu'on veut enregistrer est déjà dans le context
    JIPEvent *event = nil;
    NSFetchRequest *request = [NSFetchRequest fetchRequestWithEntityName:@"JIPEvent"];
    request.predicate = [NSPredicate predicateWithFormat:@"id = %@", eventDictionary[@"id"]];
    NSError *error = nil;
    NSArray *matches = [context executeFetchRequest:request error:&error];
    
    ////////////////////////////////////
    if ( !matches ) //there is an error
    {//handle error
        NSLog(@"ERROR");
    }
    
    ////////////////////////////////////////////////////////////////////////////////////
    //there's no match in the database yet, let's create an Event object in the database
    else if ([matches count] == 0)
        
    {
        event = [NSEntityDescription insertNewObjectForEntityForName:@"JIPEvent"
                                              inManagedObjectContext:context];
        
        event.id             = eventDictionary[@"id"];
        event.name           = eventDictionary[@"name"];
        event.latitude       = [NSNumber numberWithDouble:[eventDictionary[@"lat"] doubleValue]];
        event.longitude      = [NSNumber numberWithDouble:[eventDictionary[@"long"] doubleValue]];
        event.type           = eventDictionary[@"type"];
        event.date           = eventDictionary[@"date"];
        event.uriString      = eventDictionary[@"uriString"];
        event.ageRestriction = eventDictionary[@"ageRestriction"];

        
        NSMutableDictionary * venueDict = [[NSMutableDictionary alloc] init];
        [venueDict setValue:eventDictionary[@"venueCapacity"] forKey:@"capacity"];
        [venueDict setValue:eventDictionary[@"venueCity"]     forKey:@"city"];
        [venueDict setValue:eventDictionary[@"venueDesc"]     forKey:@"desc"];
        [venueDict setValue:eventDictionary[@"venueId"]       forKey:@"id"];
        [venueDict setValue:eventDictionary[@"venueLat"]      forKey:@"lat"];
        [venueDict setValue:eventDictionary[@"venueLong"]     forKey:@"long"];
        [venueDict setValue:eventDictionary[@"venueName"]     forKey:@"name"];
        [venueDict setValue:eventDictionary[@"venuePhone"]    forKey:@"phone"];
        [venueDict setValue:eventDictionary[@"venueStreet"]   forKey:@"street"];
        [venueDict setValue:eventDictionary[@"venueWebsite"]  forKey:@"websiteString"];
        
        event.venue  = [JIPVenue  venueWithDict:venueDict
                         inManagedObjectContext:context];
        
        
        NSMutableDictionary * artistDict = [[NSMutableDictionary alloc] init];
        [artistDict setValue:eventDictionary[@"artist"]    forKey:@"name"];
        [artistDict setValue:eventDictionary[@"artistId"]  forKey:@"id"];
        [artistDict setValue:eventDictionary[@"artistUri"] forKey:@"songkickUri"];
        
        event.artist = [JIPArtist artistWithDict:artistDict
                          inManagedObjectContext:context];
    }
    
    /////////////////////////////////////////////////////////////////////
    // there's already a event object with that unique ID in the database
    else
    {
        event = [matches lastObject];//there's one object in matches anyway
    }
    
    return event;
}

@end
