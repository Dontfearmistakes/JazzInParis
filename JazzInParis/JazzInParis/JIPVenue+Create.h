//
//  JIPVenue+Create.h
//  JazzInParis
//
//  Created by Max on 10/03/14.
//  Copyright (c) 2014 Max. All rights reserved.
//

#import "JIPVenue.h"

@interface JIPVenue (Create)


+ (JIPVenue *)venueWithDict:(NSDictionary *)venueDict
     inManagedObjectContext:(NSManagedObjectContext *)context;

+ (JIPVenue *)venueWithName:(NSString *)name
  inManagedObjectContext:(NSManagedObjectContext *)context;

@end
