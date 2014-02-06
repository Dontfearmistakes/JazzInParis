//
//  JIPEvent.h
//  JazzInParis
//
//  Created by Max on 02/02/14.
//  Copyright (c) 2014 Max. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreLocation/CoreLocation.h>


@interface JIPEvent : NSObject <NSCopying>

@property (strong, nonatomic) NSNumber *id;
@property (strong, nonatomic) NSString *type;
@property (strong, nonatomic) NSString *name;
@property (strong, nonatomic) NSURL *uri;
@property (strong, nonatomic) NSString *ageRestriction;

@property (nonatomic) CLLocationCoordinate2D location;

@property (strong, nonatomic) NSDate *date;

- (instancetype)initWithID:(NSNumber *)id name:(NSString *)name location:(CLLocationCoordinate2D)location date:(NSDate *)date;

@end
