//
//  JIPVenue.h
//  JazzInParis
//
//  Created by Max on 11/02/14.
//  Copyright (c) 2014 Max. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreLocation/CoreLocation.h>

@interface JIPVenue : NSObject

@property (strong, nonatomic) NSNumber *id;
@property (strong, nonatomic) NSString *name;
@property (strong, nonatomic) NSString *description;
@property (strong, nonatomic) NSString *city;
@property (strong, nonatomic) NSString *street;
@property (strong, nonatomic) NSString *phone;
@property (nonatomic) CLLocationCoordinate2D location;
@property (strong, nonatomic) NSURL *website;
@property (strong, nonatomic) NSNumber *capacity;


@end
