//
//  JIPVenueDetailsViewController.m
//  JazzInParis
//
//  Created by Max on 11/02/14.
//  Copyright (c) 2014 Max. All rights reserved.
//


#import "JIPVenueDetailsViewController.h"
#import "JIPMyPinView.h"

////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////

const CGFloat JIPVenueDetailsTableViewHeightPercenatge = 0.5;

@interface JIPVenueDetailsViewController ()

@property (strong, nonatomic) NSArray *allVenueProperties;
@property (strong, nonatomic) UITableView *topTableView;
-(double)distanceFromUserLocationToEvent;

@end


////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////
@implementation JIPVenueDetailsViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
        
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.title = [NSString stringWithFormat:@"%@", self.venue.name];
    
    ///////////////////////////////////////////////////// 1) TABLE VIEW WITH EVENT DETAILS
    //////////////////////////////////////////////////////////////////////////////////////
    CGFloat superViewWidth = self.view.bounds.size.width;
    CGFloat superViewHeight = self.view.bounds.size.height;
    CGFloat tableViewHeight = superViewHeight * JIPVenueDetailsTableViewHeightPercenatge;
    NSLog(@"tableViewHeight = %f", tableViewHeight);
    
    CGRect frame = CGRectMake(0, 0, superViewWidth, tableViewHeight);
    self.topTableView = [[UITableView alloc] initWithFrame:frame];
    
    //Resizing when super view redraw itself (rotation for example)
    self.topTableView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    NSLog(@"FRAME : %f, %f", frame.size.height, frame.size.width);

    self.topTableView.dataSource = self;
    self.topTableView.delegate = self;
    [self.view addSubview:self.topTableView];
    
    ///////////////////////////////////////////////////// 2) DESSINE MAPVIEW
    ////////////////////////////////////////////////////////////////////////
    self.venueMap = [[MKMapView alloc] init];
    self.venueMap.delegate = self;
    self.venueMap.frame = CGRectMake(0, tableViewHeight, superViewWidth, superViewHeight-tableViewHeight);
    self.venueMap.scrollEnabled = YES;
    self.venueMap.zoomEnabled = NO;
    [self.view addSubview:self.venueMap];
    
    self.venueMap.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    
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
///IN PROGRESS
//////////////////////////////////////////////
-(void)didRotateFromInterfaceOrientation:(UIInterfaceOrientation)fromInterfaceOrientation
{
    NSLog(@"AFTER ROTATION VIEW HEIGHT * JIPVenueDetailsTableViewHeightPercenatge : %f", self.view.bounds.size.height * JIPVenueDetailsTableViewHeightPercenatge);
    NSLog(@"AFTER ROTATION TABLEVIEW HEIGHT/WIDTH : %f / %f", self.topTableView.frame.size.height, self.topTableView.frame.size.width);
    NSLog(@"AFTER ROTATION MAPVIEW HEIGHT/WIDTH : %f / %f", self.venueMap.frame.size.height, self.venueMap.frame.size.width);
}

//////////////////////////////////////////////
///Automatically show Callout
//////////////////////////////////////////////
-(void)viewDidAppear:(BOOL)animated
{
    [self.venueMap selectAnnotation:self.venue animated:YES];
}

//////////////////////////////////////////////
///USE CURRENT USER LOCATION TO CALCULATE DISTANCE TO eventCoordinare
//////////////////////////////////////////////
-(double)distanceFromUserLocationToEvent
{
    CLLocation *eventLocation = [[CLLocation alloc] initWithLatitude:self.venue.location.latitude
                                                           longitude:self.venue.location.longitude];
    
    double distance = [self.venueMap.userLocation.location distanceFromLocation:eventLocation];
    NSLog(@"self.venueMap.userLocation.location.coordinate.longitude/latitude : %f / %f", self.venueMap.userLocation.location.coordinate.longitude, self.venueMap.userLocation.location.coordinate.latitude);
    NSLog(@"eventLocation.coordinate.longitude/latitude : %f / %f", eventLocation.coordinate.longitude, eventLocation.coordinate.latitude);
    NSLog(@"distance : %f", distance);
    return distance;
}

////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
#pragma mark - UITableViewDataSource
////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    self.allVenueProperties = @[[NSString stringWithFormat:@"%@ in %@", self.venue.street, self.venue.city],
                                 self.venue.description,
                                 self.venue.websiteString,
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

////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
#pragma mark - Table View Delegate
////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    //Go to Venue's website
    if (indexPath.row == 2)
    {
        [[UIApplication sharedApplication] openURL:self.venue.websiteString];
    }
}

////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
#pragma mark - MKMapViewDelegate
////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
- (MKAnnotationView *)mapView:(MKMapView *)mapView viewForAnnotation:(id<MKAnnotation>)annotation
{
    
    MKAnnotationView *view = [[JIPMyPinView alloc] initWithAnnotation:annotation reuseIdentifier:@"AnnotationId"];
    
    view.canShowCallout = YES;
    
    return view;
}
@end
