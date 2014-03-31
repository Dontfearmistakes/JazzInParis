//
//  JIPArtistDetailsViewController.h
//  JazzInParis
//
//  Created by Max on 11/02/14.
//  Copyright (c) 2014 Max. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "JIPArtist.h"

@interface JIPArtistDetailsViewController : UIViewController <UITableViewDataSource>

@property (strong, nonatomic) JIPArtist *artist;
@property (strong, nonatomic) UIActivityIndicatorView *activityIndicator;
@end
