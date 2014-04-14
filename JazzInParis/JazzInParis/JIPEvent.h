//
//  JIPEvent.h
//  JazzInParis
//
//  Created by Max on 02/02/14.
//  Copyright (c) 2014 Max. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreLocation/CoreLocation.h>
#import <MapKit/MapKit.h>
#import <CoreData/CoreData.h>
#import "JIPVenue.h"
#import "JIPArtist.h"

@interface JIPEvent : NSManagedObject <MKAnnotation>

//TO BE STORED
@property (strong, nonatomic) NSNumber *id;
@property (strong, nonatomic) NSString *type;
@property (strong, nonatomic) NSString *name;
@property (strong, nonatomic) NSString *uriString;
@property (strong, nonatomic) NSString *ageRestriction;
@property (strong, nonatomic) NSString *startTime;
@property (nonatomic, retain) NSNumber * longitude;
@property (nonatomic, retain) NSNumber * latitude;
@property (strong, nonatomic) NSDate *date;
@property (nonatomic) NSString *sectionIdentifier;

//TO ONE RELATIONSHIP TO BE STORED
@property (strong, nonatomic) JIPVenue *venue;
@property (strong, nonatomic) JIPArtist *artist;

//NOT TO BE STORED (so no need to @ dynamic in the .m file)
@property (nonatomic) CLLocationCoordinate2D location;
@property (nonatomic) double distanceFromUserToEvent;
@property (nonatomic) BOOL shouldDisplayDistanceFromUserToEvent;


- (instancetype)initWithID:(NSNumber *)id
                      name:(NSString *)name
                  location:(CLLocationCoordinate2D)location
                      date:(NSDate *)date
                     venue:(JIPVenue *)venue
                    artist:(JIPArtist*) artist;

@end
