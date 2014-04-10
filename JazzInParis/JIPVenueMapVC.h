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
#import "JIPVenue.h"

@interface JIPVenueMapVC : UIViewController <MKMapViewDelegate>
@property (strong, nonatomic) IBOutlet MKMapView        *mapView;
@property (strong, nonatomic) IBOutlet UINavigationItem *venueNameNavItem;
@property (strong, nonatomic)          JIPEvent         *event;
@property (strong, nonatomic)          JIPVenue         *venue;
@property (strong, nonatomic) IBOutlet UILabel *phoneLabel;
@property (strong, nonatomic) IBOutlet UILabel *addressLabel;
@property (strong, nonatomic) IBOutlet UIButton *websiteButton;
- (IBAction)venueWebsiteClick:(id)sender;


@end
