//
//  JIPJazzClubsViewController.m
//  JazzInParis
//
//  Created by Max on 12/02/14.
//  Copyright (c) 2014 Max. All rights reserved.
//

#import "JIPJazzClubsViewController.h"

@interface JIPJazzClubsViewController ()

@property (strong, nonatomic) MKMapView *parisMap;

@end

@implementation JIPJazzClubsViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
        self.title = @"Jazz Clubs";
        //self.tabBarItem.image = [UIImage imageNamed:@"Venue"];
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.
    ///////////////////////////////////////////////////// 2) DESSINE MAPVIEW
    self.parisMap = [[MKMapView alloc] init];
    self.parisMap.delegate = self;
    self.parisMap.frame = CGRectMake(0, 0, 320, 480);
    self.parisMap.scrollEnabled = YES;
    self.parisMap.zoomEnabled = YES;
    [self.view addSubview:self.parisMap];
    
    ////////////////////////////////////////////POSITIONNE MAPVIEW DANS L'ESPACE AVEC eventCoordinate COMME CENTRE
    CLLocationCoordinate2D parisCenterCoordinate = CLLocationCoordinate2DMake(48.86222222222222, 2.340833333333333);
    double regionWidth = 12000;
    double regionHeight = 11000;
    MKCoordinateRegion startRegion = MKCoordinateRegionMakeWithDistance(parisCenterCoordinate, regionWidth, regionHeight);
    [self.parisMap setRegion:startRegion
                    animated:YES];
    
    //CENTRER SUR LE VENUE ET TRACK USER
    self.parisMap.showsUserLocation = YES;
}


@end
