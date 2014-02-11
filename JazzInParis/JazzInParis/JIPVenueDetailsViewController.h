//
//  JIPVenueDetailsViewController.h
//  JazzInParis
//
//  Created by Max on 11/02/14.
//  Copyright (c) 2014 Max. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <MapKit/MapKit.h>
#import "JIPVenue.h"

@interface JIPVenueDetailsViewController : UIViewController <UITableViewDataSource, MKMapViewDelegate>

@property (strong, nonatomic) JIPVenue *venue;
@property (strong, nonatomic) MKMapView *venueMap;


@end
