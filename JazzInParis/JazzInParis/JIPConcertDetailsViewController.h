//
//  JIPConcertDetailsViewController.h
//  JazzInParis
//
//  Created by Max on 04/02/14.
//  Copyright (c) 2014 Max. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <MapKit/MapKit.h>
#import "JIPEvent.h"

@interface JIPConcertDetailsViewController : UIViewController <MKMapViewDelegate, UITableViewDataSource>

@property (strong, nonatomic) JIPEvent *event;
@property (strong, nonatomic) MKMapView *venueMap;

@end
