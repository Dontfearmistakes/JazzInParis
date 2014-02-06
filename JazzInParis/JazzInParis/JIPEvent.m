//
//  JIPEvent.m
//  JazzInParis
//
//  Created by Max on 02/02/14.
//  Copyright (c) 2014 Max. All rights reserved.
//

#import "JIPEvent.h"

@implementation JIPEvent

- (instancetype)initWithID:(NSNumber *)id name:(NSString *)name location:(CLLocationCoordinate2D)location date:(NSDate *)date
{
    self = [super init];
    if (self)
    {
        self.id = id;
        self.name = name;
        self.location = location;
        self.date = date;
    }
    return self;
}

// Check if we have a custom display name for the event.
// If not, set and use the artist's name as the display name.
- (NSString *)name
{
    if (!_name && [_name isEqualToString:@""]) {
        _name = @"Artist name"; // TODO: change it to the artist's name
    }
    return _name;
}

- (id)copyWithZone:(NSZone *)zone {
    JIPEvent *newEvent = [[[self class] allocWithZone:zone] init];
    newEvent.id = [_id copyWithZone:zone];
    newEvent.type = [_type copyWithZone:zone];
    newEvent.name = [_name copyWithZone:zone];
    newEvent.uri = [_uri copyWithZone:zone];
    newEvent.ageRestriction = [_ageRestriction copyWithZone:zone];
    //newEvent.location = [self.location copyWithZone:zone]; HOW TO COPY WITH ZONE A NON POINTER OBJECT ????
    newEvent.date = [_date copyWithZone:zone];

    return newEvent;
}

@end
