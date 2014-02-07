//
//  JIPMapAnnotation.h
//  JazzInParis
//
//  Created by Max on 06/02/14.
//  Copyright (c) 2014 Max. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <MapKit/MapKit.h>

@interface JIPMapAnnotation : NSObject <MKAnnotation>
{
    CLLocationCoordinate2D coordinate;
}

@property CLLocationCoordinate2D coordinate;

- (id) initWithCoordinate:(CLLocationCoordinate2D)coord;

@end
