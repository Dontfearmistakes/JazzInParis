//
//  JIPArtist+Create.m
//  JazzInParis
//
//  Created by Max on 11/03/14.
//  Copyright (c) 2014 Max. All rights reserved.
//

#import "JIPArtist+Create.h"

@implementation JIPArtist (Create)

+ (JIPArtist *)artistWithDict:(NSDictionary *)artistDict
       inManagedObjectContext:(NSManagedObjectContext *)context
{
    JIPArtist *artist = nil;
    
    NSFetchRequest *request = [NSFetchRequest fetchRequestWithEntityName:@"JIPArtist"];
    
    //check if some artist with same name is already in the context
    request.predicate = [NSPredicate predicateWithFormat:@"name = %@", artistDict[@"name"]];
    
    NSError *error = nil;
    NSArray *matches = [context executeFetchRequest:request error:&error];
    
    //fetchRequest returns nil, there's an error
    if ( !matches )
    {
        //handle error
        NSLog(@"CORE DATA FETCH REQUEST ERROR");
    }
    
    //there's no match in the database yet, let's create an Artist object in the database
    else if ([matches count] == 0)
    {
        artist = [NSEntityDescription insertNewObjectForEntityForName:@"JIPArtist"
                                              inManagedObjectContext:context];
        artist.name        = artistDict[@"name"];
        artist.id          = artistDict[@"id"];;
        artist.songkickUri = artistDict[@"songkickUri"];;
    }
    
    //there's already a Photo object with that unique ID in the database
    else
    {
        artist = [matches lastObject];//there's one object in matches anyway
    }
    
    return artist;
}



////////////////////////////////////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////////////////////////
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
    
    //there's no match in the database
    else if ([matches count] == 0)
    {
        NSLog(@"NO ARTIST WITH THIS NAME : %@", artistName);
    }
    
    //there's a match
    else
    {
        artist = [matches lastObject];//there's one object in matches anyway
    }
    
    return artist;
}

@end
