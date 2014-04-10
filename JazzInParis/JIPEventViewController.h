//
//  JIPEventViewController.h
//  JazzInParis
//
//  Created by Max on 09/04/14.
//  Copyright (c) 2014 Max. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "JIPEvent.h"
#import "JIPVenue.h"

@interface JIPEventViewController : UIViewController
@property (strong, nonatomic) IBOutlet UILabel *artistNameLabel;
@property (strong, nonatomic) IBOutlet UILabel *concertNameLabel;
@property (strong, nonatomic) IBOutlet UITextView *venueAdressTxtView;
@property (strong, nonatomic) IBOutlet UIButton *checkMapButton;

@property (strong, nonatomic) JIPEvent    *event;
@property (strong, nonatomic) JIPVenue    *venue;


- (IBAction)checkMapClick:(id)sender;


@end
