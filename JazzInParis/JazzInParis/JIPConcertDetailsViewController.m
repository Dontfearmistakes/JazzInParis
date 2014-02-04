//
//  JIPConcertDetailsViewController.m
//  JazzInParis
//
//  Created by Max on 04/02/14.
//  Copyright (c) 2014 Max. All rights reserved.
//

#import "JIPConcertDetailsViewController.h"

@interface JIPConcertDetailsViewController ()

@end

@implementation JIPConcertDetailsViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

//////////////////////////////////////////////////////////////////////
//////////////////////////////////////////////////////////////////////
- (void)viewDidLoad
{
    [super viewDidLoad];
    self.title = [NSString stringWithFormat:@"%@ Concert", self.name];
	// Do any additional setup after loading the view.
    
    /////////////////////////////////////////////////////NAME OF CONCERT LABEL//
    UILabel *concertNameLabel = [[UILabel alloc] init];
    concertNameLabel.frame = CGRectMake(40,100,200,40);
    concertNameLabel.backgroundColor = [UIColor blueColor];
    concertNameLabel.textAlignment = NSTextAlignmentCenter;
    concertNameLabel.font = [UIFont fontWithName:@"Helvetica" size:16.0f];
    concertNameLabel.text = self.name;
    [self.view addSubview:concertNameLabel];
    
}



@end
