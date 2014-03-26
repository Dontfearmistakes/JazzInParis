//
//  JIPArtist.m
//  JazzInParis
//
//  Created by Max on 11/02/14.
//  Copyright (c) 2014 Max. All rights reserved.
//

#import "JIPArtist.h"

@implementation JIPArtist

@dynamic id;
@dynamic name;
@dynamic songkickUri;
@dynamic events;
@dynamic favorite;

//////////////////////////////////////////////////////////////////
- (id)init
{
    return [self initWithID:@0
                       name:@"Default Name"
                songkickUri:@"www.defaultURL"];
}
//////////////////////////////////////////////////////////////////
-(instancetype)initWithID:(NSNumber *)id
                     name:(NSString *)name
              songkickUri:(NSString *)songkickUri
{
    self = [super init];
    if(self)
    {
        self.id = id;
        self.name = name;
        self.songkickUri = songkickUri;
    }
    return  self;
}

@end
