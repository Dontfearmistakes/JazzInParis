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
    
    ////////////////////////////////////
    else if ([matches count] == 0) //there's no match in the database yet, let's create an Event object in the database
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

        event.venue  = [JIPVenue  venueWithName:eventDictionary[@"venue"]  inManagedObjectContext:context];
        event.artist = [JIPArtist artistWithName:eventDictionary[@"artist"] inManagedObjectContext:context];
    }
    
    ////////////////////////////////////
    else //there's already a event object with that unique ID in the database
    {
        event = [matches lastObject];//there's one object in matches anyway
    }
    
    return event;
}

@end
