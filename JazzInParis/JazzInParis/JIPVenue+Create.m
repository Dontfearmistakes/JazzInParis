//
//  JIPVenue+Create.m
//  JazzInParis
//
//  Created by Max on 10/03/14.
//  Copyright (c) 2014 Max. All rights reserved.
//

#import "JIPVenue+Create.h"

@implementation JIPVenue (Create)

+ (JIPVenue *)venueWithDict:(NSDictionary *)venueDict
     inManagedObjectContext:(NSManagedObjectContext *)context
{
    JIPVenue *venue = nil;
    
    NSFetchRequest *request = [NSFetchRequest fetchRequestWithEntityName:@"JIPVenue"];
    request.predicate = [NSPredicate predicateWithFormat:@"name = %@", venueDict[@"name"]];
    
    NSError *error = nil;
    NSArray *matches = [context executeFetchRequest:request error:&error];
    
    //fetchRequest returns nil, there's an error
    if ( !matches )
    {
        //handle error
        NSLog(@"CORE DATA FETCH REQUEST ERROR");
    }
    
    //there's no match in the database yet, let's create a Venue object in the database
    else if ([matches count] == 0)
    {
        venue = [NSEntityDescription insertNewObjectForEntityForName:@"JIPVenue"
                                                     inManagedObjectContext:context];
        venue.name     = venueDict[@"name"];
        venue.capacity = venueDict[@"capacity"];
        venue.city     = venueDict[@"city"];
        venue.desc     = venueDict[@"desc"];
        venue.id       = venueDict[@"id"];
        venue.street   = venueDict[@"street"];
        venue.phone    = venueDict[@"phone"];
        venue.websiteString = venueDict[@"websiteString"];
        venue.latitude = [NSNumber numberWithDouble:[venueDict[@"lat"] doubleValue]];
        venue.longitude = [NSNumber numberWithDouble:[venueDict[@"long"] doubleValue]];
    }
    
    //there's already an object with that name in the database
    else
    {
        venue = [matches lastObject];//there's one object in matches anyway
    }
    
    return venue;
}



////////////////////////////////////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////////////////////////
+ (JIPVenue *)venueWithName:(NSString *)venueName
     inManagedObjectContext:(NSManagedObjectContext *)context
{
    JIPVenue *venue = nil;
    
    NSFetchRequest *request = [NSFetchRequest fetchRequestWithEntityName:@"JIPVenue"];
    request.predicate = [NSPredicate predicateWithFormat:@"name = %@", venueName];
    
    NSError *error = nil;
    NSArray *matches = [context executeFetchRequest:request error:&error];
    
    //fetchRequest returns nil, there's an error
    if ( !matches )
    {
        //handle error
        NSLog(@"CORE DATA FETCH REQUEST ERROR");
    }
    
    //there's no match in the database
    else if ([matches count] == 0)
    {
        NSLog(@"NO VENUE WITH THIS NAME : %@", venueName);
    }
    
    //there's a match
    else
    {
        venue = [matches lastObject];//there's one object in matches anyway
    }
    
    return venue;
}

@end
