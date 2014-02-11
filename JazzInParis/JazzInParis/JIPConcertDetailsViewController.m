//
//  JIPConcertDetailsViewController.m
//  JazzInParis
//
//  Created by Max on 04/02/14.
//  Copyright (c) 2014 Max. All rights reserved.
//

#import "JIPConcertDetailsViewController.h"
#import "JIPMyPinView.h"
#import "JIPVenueDetailsViewController.h"

@interface JIPConcertDetailsViewController ()

@property (strong, nonatomic) NSArray *allEventProperties;

-(double)distanceFromUserLocationToEvent;

@end


//////////////////////////////////////////////////////////////////////
//////////////////////////////////////////////////////////////////////
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
- (void)viewDidLoad
{
    [super viewDidLoad];
    self.title = [NSString stringWithFormat:@"%@ Concert", self.event.name];
    
    ///////////////////////////////////////////////////// 1) TABLE VIEW WITH EVENT DETAILS
    CGRect frame = CGRectMake(0, 0, 320, 230);
    UITableView *tableView = [[UITableView alloc] initWithFrame:frame];
    tableView.dataSource = self;
    tableView.delegate = self;
    [self.view addSubview:tableView];
    
    
    ///////////////////////////////////////////////////// 2) DESSINE MAPVIEW
    self.venueMap = [[MKMapView alloc] init];
    self.venueMap.delegate = self;
    self.venueMap.frame = CGRectMake(0, 235, 320, 200);
    self.venueMap.scrollEnabled = YES;
    self.venueMap.zoomEnabled = NO;
    [self.view addSubview:self.venueMap];
    
    ////////////////////////////////////////////POSITIONNE MAPVIEW DANS L'ESPACE AVEC eventCoordinate COMME CENTRE
    CLLocationCoordinate2D eventCoordinate = CLLocationCoordinate2DMake(self.event.location.latitude, self.event.location.longitude);
    double regionWidth = 2500;
    double regionHeight = 2200;
    MKCoordinateRegion startRegion = MKCoordinateRegionMakeWithDistance(eventCoordinate, regionWidth, regionHeight);
    [self.venueMap setRegion:startRegion
                  animated:YES];

    
    //CENTRER SUR LE VENUE ET TRACK USER
    [self.venueMap setCenterCoordinate:eventCoordinate animated:YES];
    self.venueMap.showsUserLocation = YES;
    
    //PASS distanceFromUserLocationToEvent to adhoc event @property to display it
    //as subtitle of the annotation (called by -viewForAnnotation below)
    self.event.distanceFromUserToEvent = [self distanceFromUserLocationToEvent];
    
    //ADD ANNOTATION
    [self.venueMap addAnnotation:self.event];
    
}

//////////////////////////////////////////////
///USE CURRENT USER LOCATION TO CALCULATE DISTANCE TO eventCoordinare
//////////////////////////////////////////////
-(double)distanceFromUserLocationToEvent
{

    CLLocation *eventLocation = [[CLLocation alloc] initWithLatitude:self.event.location.latitude
                                                           longitude:self.event.location.longitude];
    
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
    self.allEventProperties = @[[NSString stringWithFormat:@"Who ?  %@", self.event.artist.name],
                                [NSString stringWithFormat:@"When ?  %@", self.event.date],
                                [NSString stringWithFormat:@"Where ?  %@ : %@ in %@",self.event.venue.name, self.event.venue.street, self.event.venue.city],
                                [NSString stringWithFormat:@"Check prices here : %@", self.event.uri],
                                self.event.ageRestriction];
    return self.allEventProperties.count;
}

//////////////////////////////////////////////////////
-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"id"];
    
    //CELL GETS EVENT.NAME
    cell.textLabel.text = [NSString stringWithFormat:@"%@", self.allEventProperties[indexPath.row]];
    cell.backgroundColor = [UIColor blueColor];
    cell.textLabel.font = [UIFont fontWithName:@"Helvetica" size:16.0f];
    
    if (indexPath.row == 0 || indexPath.row == 2)
    {
        cell.accessoryType = UITableViewCellAccessoryDetailDisclosureButton;
    }
    
    return cell;
}

////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
#pragma mark - Table View Delegate
////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    //GO TO ARTIST DETAILS VC
    if (indexPath.row == 0)
    {

    }
    
    //GO TO VENUE DETAILS VC
    if (indexPath.row == 2)
    {
        JIPVenueDetailsViewController *venueDetailsVC = [[JIPVenueDetailsViewController alloc] init];
        venueDetailsVC.venue = self.event.venue;
        [self.navigationController pushViewController:venueDetailsVC animated:YES];
    }
}


////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
#pragma mark - MKMapViewDelegate
////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
- (MKAnnotationView *)mapView:(MKMapView *)mapView viewForAnnotation:(id<MKAnnotation>)annotation
{
    
    MKAnnotationView *view = [[JIPMyPinView alloc] initWithAnnotation:annotation reuseIdentifier:@"AnnotationId"];
    
    view.canShowCallout = YES;
    
    UIButton *disclosureButton = [UIButton buttonWithType:UIButtonTypeDetailDisclosure];
    view.rightCalloutAccessoryView = disclosureButton;
    
    return view;
}

-(void)mapViewDidFinishLoadingMap:(MKMapView *)mapView
{
    [mapView selectAnnotation:self.event animated:YES];
}

-(void)mapView:(MKMapView *)mapView annotationView:(MKAnnotationView *)view calloutAccessoryControlTapped:(UIControl *)control
{
    JIPVenueDetailsViewController *venueDetailsVC = [[JIPVenueDetailsViewController alloc] init];
    venueDetailsVC.venue = self.event.venue;
    [self.navigationController pushViewController:venueDetailsVC animated:YES];
}

@end
