//
//  JIPConcertDetailsViewController.h
//  JazzInParis
//
//  Created by Max on 04/02/14.
//  Copyright (c) 2014 Max. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <CoreLocation/CoreLocation.h>

@interface JIPConcertDetailsViewController : UIViewController

@property (strong, nonatomic) NSString *type;
@property (strong, nonatomic) NSString *name;
@property (strong, nonatomic) NSURL *uri;
@property (strong, nonatomic) NSString *ageRestriction;

@property (nonatomic) CLLocationCoordinate2D location;

@property (strong, nonatomic) NSDate *date;

@end
