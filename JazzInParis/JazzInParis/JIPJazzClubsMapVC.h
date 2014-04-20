//
//  JIPJazzClubsMapVC.h
//  JazzInParis
//
//  Created by Max on 20/04/14.
//  Copyright (c) 2014 Max. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <MapKit/MapKit.h>
#import "JIPVenue.h"

@interface JIPJazzClubsMapVC : UIViewController <MKMapViewDelegate>
@property (strong, nonatomic) IBOutlet MKMapView *allJazzClubsMap;
@property (strong, nonatomic) NSArray *jazzClubsArray;
@property (strong, nonatomic) JIPVenue *venue;
@end
