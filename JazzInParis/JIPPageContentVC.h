//
//  JIPPageContentVC.h
//  JazzInParis
//
//  Created by Max on 15/04/14.
//  Copyright (c) 2014 Max. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface JIPPageContentVC : UIViewController
@property (strong, nonatomic) IBOutlet UITextView *initialTextView;
@property NSUInteger pageIndex;
@property NSString  *contentText;
@property (strong, nonatomic) IBOutlet UIButton *finishWelcomePageControllerButton;
- (IBAction)finishWelcomePageControllerClick:(id)sender;

@end
