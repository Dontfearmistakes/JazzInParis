//
//  JIPVenueDetailsViewController.m
//  JazzInParis
//
//  Created by Max on 11/02/14.
//  Copyright (c) 2014 Max. All rights reserved.
//
Create JIPVenueDetailsVC

Copying JIPEventDetailsVC
-UITableView on the top
-MapView on the bottom
+Make JIPVenue conform to <MKAnnottion>

#import "JIPVenueDetailsViewController.h"

@interface JIPVenueDetailsViewController ()

@property (strong, nonatomic) NSArray *allVenueProperties;
-(double)distanceFromUserLocationToEvent;

@end

@implementation JIPVenueDetailsViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
        self.title = [NSString stringWithFormat:@"%@", self.venue.name];
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    ///////////////////////////////////////////////////// 1) TABLE VIEW WITH EVENT DETAILS
    CGRect frame = CGRectMake(0, 0, 320, 230);
    UITableView *tableView = [[UITableView alloc] initWithFrame:frame];
    tableView.dataSource = self;
    [self.view addSubview:tableView];
    
    
    ///////////////////////////////////////////////////// 2) DESSINE MAPVIEW
    self.venueMap = [[MKMapView alloc] init];
    self.venueMap.delegate = self;
    self.venueMap.frame = CGRectMake(0, 235, 320, 200);
    self.venueMap.scrollEnabled = YES;
    self.venueMap.zoomEnabled = NO;
    [self.view addSubview:self.venueMap];
    
    ////////////////////////////////////////////POSITIONNE MAPVIEW DANS L'ESPACE AVEC eventCoordinate COMME CENTRE
    CLLocationCoordinate2D venueCoordinate = CLLocationCoordinate2DMake(self.venue.location.latitude, self.venue.location.longitude);
    double regionWidth = 2500;
    double regionHeight = 2200;
    MKCoordinateRegion startRegion = MKCoordinateRegionMakeWithDistance(venueCoordinate, regionWidth, regionHeight);
    [self.venueMap setRegion:startRegion
                    animated:YES];
    
    
    //CENTRER SUR LE VENUE ET TRACK USER
    [self.venueMap setCenterCoordinate:venueCoordinate animated:YES];
    self.venueMap.showsUserLocation = YES;
    
    //PASS distanceFromUserLocationToEvent to adhoc event @property to display it
    //as subtitle of the annotation (called by -viewForAnnotation below)
    self.venue.distanceFromUserToVenue = [self distanceFromUserLocationToEvent];
    
    //ADD ANNOTATION
    [self.venueMap addAnnotation:self.venue];
}

//////////////////////////////////////////////
///USE CURRENT USER LOCATION TO CALCULATE DISTANCE TO eventCoordinare
//////////////////////////////////////////////
-(double)distanceFromUserLocationToEvent
{
    
    CLLocation *eventLocation = [[CLLocation alloc] initWithLatitude:self.venue.location.latitude
                                                           longitude:self.venue.location.longitude];
    
    double distance = [self.venueMap.userLocation.location distanceFromLocation:eventLocation];
    NSLog(@"%@", self.venueMap.userLocation);
    NSLog(@"%f", self.venueMap.userLocation.location.coordinate.longitude);
    NSLog(@"%f", eventLocation.coordinate.longitude);
    NSLog(@"%f", distance);
    return distance;
}

////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
#pragma mark - UITableViewDataSource
////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    self.allVenueProperties = @[[NSString stringWithFormat:@"%@ in %@", self.venue.street, self.venue.city],
                                 self.venue.description,
                                 self.venue.website,
                                 self.venue.phone,
                                 self.venue.capacity
                                ];
    return self.allVenueProperties.count;
}

//////////////////////////////////////////////////////
-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"id"];
    
    //CELL GETS EVENT.NAME
    cell.textLabel.text = [NSString stringWithFormat:@"%@", self.allVenueProperties[indexPath.row]];
    cell.backgroundColor = [UIColor blueColor];
    cell.textLabel.font = [UIFont fontWithName:@"Helvetica" size:16.0f];
    
    return cell;
}


@end
