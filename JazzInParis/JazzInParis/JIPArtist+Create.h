//
//  JIPArtist+Create.h
//  JazzInParis
//
//  Created by Max on 11/03/14.
//  Copyright (c) 2014 Max. All rights reserved.
//

#import "JIPArtist.h"

@interface JIPArtist (Create)

+ (JIPArtist *)artistWithDict:(NSDictionary *)artistName
       inManagedObjectContext:(NSManagedObjectContext *)context;

+ (JIPArtist *)artistWithName:(NSString *)artistName
       inManagedObjectContext:(NSManagedObjectContext *)context;

@end
