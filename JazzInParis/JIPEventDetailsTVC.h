//
//  JIPEventDetailsTVC.h
//  JazzInParis
//
//  Created by Max on 14/04/14.
//  Copyright (c) 2014 Max. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "JIPEvent.h"

@interface JIPEventDetailsTVC : UITableViewController

@property (strong, nonatomic) IBOutlet UIImageView *eventImageView;
@property (strong, nonatomic) IBOutlet UILabel  *concertDateLabel;

@property (strong, nonatomic) JIPEvent    *event;
@property (strong, nonatomic) JIPVenue    *venue;


@end
