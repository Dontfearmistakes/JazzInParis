//
//  JIPArtist+Create.m
//  JazzInParis
//
//  Created by Max on 11/03/14.
//  Copyright (c) 2014 Max. All rights reserved.
//

#import "JIPArtist+Create.h"

@implementation JIPArtist (Create)

+ (JIPArtist *)artistWithName:(NSString *)artistName
       inManagedObjectContext:(NSManagedObjectContext *)context
{
    JIPArtist *artist = nil;
    
    NSFetchRequest *request = [NSFetchRequest fetchRequestWithEntityName:@"JIPArtist"];
    request.predicate = [NSPredicate predicateWithFormat:@"name = %@", artistName];
    
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
        artist = [NSEntityDescription insertNewObjectForEntityForName:@"JIPArtist"
                                              inManagedObjectContext:context];
        artist.name        = artistName;
        artist.id          = @1;
        artist.songkickUri = @"www.jjj.com";
    }
    
    //there's already a Photo object with that unique ID in the database
    else
    {
        artist = [matches lastObject];//there's one object in matches anyway
    }
    
    return artist;
}

@end
