//
//  JIPVenue+Create.m
//  JazzInParis
//
//  Created by Max on 10/03/14.
//  Copyright (c) 2014 Max. All rights reserved.
//

#import "JIPVenue+Create.h"
#import "JIPUpdateManager.h"

@implementation JIPVenue (Create)

+ (JIPVenue *)venueWithDict:(NSDictionary *)venueDict
     inManagedObjectContext:(NSManagedObjectContext *)context
{
    JIPVenue *venue = nil;
    
    NSFetchRequest *request = [NSFetchRequest fetchRequestWithEntityName:@"JIPVenue"];
    request.predicate = [NSPredicate predicateWithFormat:@"id = %@", venueDict[@"id"]];
    
    NSError *error = nil;
    NSArray *matches = [context executeFetchRequest:request error:&error];
    venue = [matches lastObject];
    //fetchRequest returns nil, there's an error
    if ( !matches )
    {
        //handle error
        NSLog(@"CORE DATA FETCH REQUEST ERROR");
    }
    
    //there's no match in the database yet, let's create a Venue object in the database
    else if ([matches count] == 0 )
    {
        venue = [NSEntityDescription insertNewObjectForEntityForName:@"JIPVenue"
                                                     inManagedObjectContext:context];
        if (venueDict[@"id"] != [NSNull null])
        {
            venue.id       = venueDict[@"id"];
        }
        venue.name     = venueDict[@"name"];
        venue.city     = venueDict[@"city"];
        venue.latitude = [NSNumber numberWithDouble:[venueDict[@"lat"] doubleValue]];
        venue.longitude = [NSNumber numberWithDouble:[venueDict[@"long"] doubleValue]];
        venue.desc     = venueDict[@"desc"];
        venue.capacity = venueDict[@"capacity"];
        venue.street   = venueDict[@"street"];
        venue.phone    = venueDict[@"phone"];
        venue.websiteString = venueDict[@"websiteString"];
    }
    
    //or the object exist is missing properties (API Call specific for Venue is being done now)
    else if ([matches count] == 1  && (venue.desc == nil || [venue.desc isEqualToString:@""] || [venue.desc isEqualToString:@"No description available"] ))
    {
        venue.street        = [venueDict[@"street"] description];
        venue.phone         = [venueDict[@"phone"]  description];
        venue.websiteString = [venueDict[@"websiteString"] description];
        if (venueDict[@"capacity"] != [NSNull null])
        {
            venue.capacity      = venueDict[@"capacity"];
        }
        venue.city          = [venueDict[@"city"] description];
        venue.desc          = [venueDict[@"desc"] description];
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
+ (JIPVenue *)venueWithId:(NSString *)venueId
   inManagedObjectContext:(NSManagedObjectContext *)context
{
    JIPVenue *venue = nil;
    
    NSFetchRequest *request = [NSFetchRequest fetchRequestWithEntityName:@"JIPVenue"];
    request.predicate = [NSPredicate predicateWithFormat:@"id = %@", venueId];
    
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
        NSLog(@"NO VENUE WITH THIS id YET LET'S DOWNLOAD. ID = %@", venueId);
    }
    
    //there's a match
    else
    {
        venue = [matches lastObject];//there's one object in matches anyway
    }
    
    return venue;
}

@end
