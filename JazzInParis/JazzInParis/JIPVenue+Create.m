//
//  JIPVenue+Create.m
//  JazzInParis
//
//  Created by Max on 10/03/14.
//  Copyright (c) 2014 Max. All rights reserved.
//

#import "JIPVenue+Create.h"

@implementation JIPVenue (Create)

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
    
    //there's no match in the database yet, let's create a Photo object in the database
    else if ([matches count] == 0)
    {
        venue = [NSEntityDescription insertNewObjectForEntityForName:@"JIPVenue"
                                                     inManagedObjectContext:context];
        venue.name     = venueName;
        venue.capacity = @200;
        venue.city     = @"Paris";
        venue.desc     = @"Best place ever";
        venue.id       = @1;
        venue.street   = @"3 Rue des Lombards";
        venue.phone    = @"00000000";
        venue.websiteString = [NSURL URLWithString:@"www.jjj.com"];
        venue.location = CLLocationCoordinate2DMake(0.0, 0.0) ;
    }
    
    //there's already a Photo object with that unique ID in the database
    else
    {
        venue = [matches lastObject];//there's one object in matches anyway
    }
    
    return venue;
}

@end
