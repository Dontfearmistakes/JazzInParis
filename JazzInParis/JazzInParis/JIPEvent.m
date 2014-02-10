//
//  JIPEvent.m
//  JazzInParis
//
//  Created by Max on 02/02/14.
//  Copyright (c) 2014 Max. All rights reserved.
//

#import "JIPEvent.h"

@implementation JIPEvent

////////////////////////////////////////
-(id)init
{
    return [self initWithID:@0
                       name:NSLocalizedString(@"event", @"Default event title")
                   location:CLLocationCoordinate2DMake(0, 0)
                       date:[NSDate date]];
}

////////////////////////////////////////
- (instancetype)initWithID:(NSNumber *)id
                      name:(NSString *)name
                  location:(CLLocationCoordinate2D)location
                      date:(NSDate *)date
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

////////////////////////////////////////
// Check if we have a custom display name for the event.
// If not, set and use the artist's name as the display name.
- (NSString *)name
{
    if (!_name && [_name isEqualToString:@""]) {
        _name = @"Artist name"; // TODO: change it to the artist's name
    }
    return _name;
}

-(CLLocationCoordinate2D)coordinate
{
    return self.location;
}

-(NSString *)title
{
    return @"Venue Name";
}

-(NSString *)subtitle
{
    return @"xxx km from you";
}

@end
