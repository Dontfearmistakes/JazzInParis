//
//  JIPJazzClubsViewController.h
//  JazzInParis
//
//  Created by Max on 12/02/14.
//  Copyright (c) 2014 Max. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <MapKit/MapKit.h>

@interface JIPJazzClubsViewController : UIViewController <MKMapViewDelegate>

@property (strong, nonatomic) NSArray * allJazzClubs;

@end
