//
//  JIPVenue.h
//  JazzInParis
//
//  Created by Max on 11/02/14.
//  Copyright (c) 2014 Max. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreLocation/CoreLocation.h>
#import <MapKit/MapKit.h>
#import <CoreData/CoreData.h>

@interface JIPVenue : NSObject <MKAnnotation>

@property (strong, nonatomic) NSNumber *id;
@property (strong, nonatomic) NSString *name;
@property (strong, nonatomic) NSString *desc;
@property (strong, nonatomic) NSString *city;
@property (strong, nonatomic) NSString *street;
@property (strong, nonatomic) NSString *phone;
@property (nonatomic) CLLocationCoordinate2D location;
@property (strong, nonatomic) NSURL *website;
@property (strong, nonatomic) NSNumber *capacity;

@property (nonatomic) double distanceFromUserToVenue;

- (instancetype)initWithID:(NSNumber *)id
                      name:(NSString *)name
               description:(NSString *) description
                      city:(NSString *) city
                    street:(NSString *) street
                     phone:(NSString *) phone
                   website:(NSURL *) website
                  capacity:(NSNumber *) capacity;



@end
