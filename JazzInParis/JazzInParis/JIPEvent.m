//
//  JIPEvent.m
//  JazzInParis
//
//  Created by Max on 02/02/14.
//  Copyright (c) 2014 Max. All rights reserved.
//

#import "JIPEvent.h"

@implementation JIPEvent

// Check if we have a custom display name for the event.
// If not, set and use the artist's name as the display name.
- (NSString *)name
{
    if (!_name && [_name isEqualToString:@""]) {
        _name = @"Artist name"; // TODO: change it to the artist's name
    }
    return _name;
}

@end
