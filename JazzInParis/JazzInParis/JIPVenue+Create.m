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
    
    // 1) fetchRequest returns nil, there's an error
    if ( !matches )
    {
        //handle error
        NSLog(@"CORE DATA FETCH REQUEST ERROR");
    }
    
    // 2) there's no match in the database yet, let's create a Venue object in the database
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
    
    // 3) the object has already been created upon upcomingEvents API call
    // but is missing properties (API Call specific for Venue is being done now)
    else if ([matches count] == 1  && (venue.desc == nil || [venue.desc isEqualToString:@""] || [venue.desc isEqualToString:@"No description available"] ))
    {
        //PHONE
        if (venueDict[@"phone"] != [NSNull null])
            venue.phone      = venueDict[@"phone"];
        else
            venue.phone     = @"No phone available";
        
        
        //Website
        if (venueDict[@"websiteString"] != [NSNull null])
            venue.websiteString      = venueDict[@"websiteString"];
        else
            venue.websiteString     = @"No website available";
        
        //City
        if (venueDict[@"city"] != [NSNull null])
            venue.city      = venueDict[@"city"];
        else
            venue.city     = @"No city Available";
        //Street
        if (venueDict[@"street"] != [NSNull null])
            venue.street      = [NSString stringWithFormat:@"%@ / %@", [venueDict[@"street"] lowercaseString], venue.city];
        else
            venue.street     = @"No address available";
        
        //Capacity
        if (venueDict[@"capacity"] != [NSNull null])
            venue.capacity      = venueDict[@"capacity"];
        else
            venue.capacity     = 0;


        venue.desc          = [venueDict[@"desc"] description];
    }
    
    //there's already an object with that name in the database
    else
    {
        venue = [matches lastObject];//there's one object in matches anyway
    }
    
    return venue;
}

@end
