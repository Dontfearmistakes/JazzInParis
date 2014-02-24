//
//  JIPArtist.h
//  JazzInParis
//
//  Created by Max on 11/02/14.
//  Copyright (c) 2014 Max. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>


@interface JIPArtist : NSManagedObject

@property (strong, nonatomic) NSNumber *id;
@property (strong, nonatomic) NSString *name;
@property (strong, nonatomic) NSURL *songkickUri;

-(instancetype)initWithID: (NSNumber *)id
                     name: (NSString *)name
              songkickUri: (NSURL *)songkickUri;





@end
