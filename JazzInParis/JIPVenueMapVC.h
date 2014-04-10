//
//  JIPVenueMapVC.h
//  JazzInParis
//
//  Created by Max on 09/04/14.
//  Copyright (c) 2014 Max. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <MapKit/MapKit.h>
#import "JIPEvent.h"

@interface JIPVenueMapVC : UIViewController <MKMapViewDelegate>
@property (strong, nonatomic) IBOutlet MKMapView        *mapView;
@property (strong, nonatomic) IBOutlet UINavigationItem *venueNameNavItem;
@property (strong, nonatomic)          JIPEvent         *event;

@end
