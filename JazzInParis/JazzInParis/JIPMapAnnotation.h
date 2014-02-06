//
//  JIPMapAnnotation.h
//  JazzInParis
//
//  Created by Max on 06/02/14.
//  Copyright (c) 2014 Max. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <MapKit/MapKit.h>
#import <CoreLocation/CoreLocation.h>

@interface JIPMapAnnotation : NSObject <MKAnnotation>

@property CLLocationCoordinate2D coordinate;

@end
