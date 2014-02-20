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
#import "JIPArtistDetailsViewController.h"
#import "NSDate+Formatting.h"

const CGFloat JIPConcertDetailsTableViewHeightPercenatge = 0.5;

@interface JIPConcertDetailsViewController ()

@property (strong, nonatomic) NSArray *allEventProperties;
@property (nonatomic) CGFloat tableViewHeight;
@property (strong, nonatomic) UITableView *topTableView;

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
    //////////////////////////////////////////////////////////////////////////////////////
    CGFloat superViewWidth = self.view.bounds.size.width;
    CGFloat superViewHeight = self.view.bounds.size.height;
    self.tableViewHeight = superViewHeight * JIPConcertDetailsTableViewHeightPercenatge;

    CGRect frame = CGRectMake(0, 0, superViewWidth, self.tableViewHeight);
    self.topTableView = [[UITableView alloc] initWithFrame:frame];
    //Resizing when super view redraw itself (rotation for example)
    self.topTableView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleBottomMargin;
    
    self.topTableView.dataSource = self;
    self.topTableView.delegate = self;
    [self.view addSubview:self.topTableView];
    
    ///////////////////////////////////////////////////// 2) DESSINE MAPVIEW
    ////////////////////////////////////////////////////////////////////////
    self.venueMap = [[MKMapView alloc] init];
    self.venueMap.frame = CGRectMake(0, self.tableViewHeight, superViewWidth, superViewHeight - self.tableViewHeight);
    self.venueMap.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;

    self.venueMap.delegate = self;
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
///Automatically show Callout
//////////////////////////////////////////////
-(void)viewDidAppear:(BOOL)animated
{
    [self.venueMap selectAnnotation:self.event animated:YES];
}


//////////////////////////////////////////////
///ROTATION
//////////////////////////////////////////////
-(void)didRotateFromInterfaceOrientation:(UIInterfaceOrientation)fromInterfaceOrientation
{
    [super didRotateFromInterfaceOrientation:fromInterfaceOrientation];
    NSLog(@"ROTATION !!!!");
    NSLog(@"fromInterfaceOrientation : %d", fromInterfaceOrientation);
    [self.topTableView reloadData];
}

//////////////////////////////////////////////
///USE CURRENT USER LOCATION TO CALCULATE DISTANCE TO eventCoordinare
//////////////////////////////////////////////
-(double)distanceFromUserLocationToEvent
{
    CLLocation *eventLocation = [[CLLocation alloc] initWithLatitude:self.event.location.latitude
                                                           longitude:self.event.location.longitude];
    
    NSLog(@"%@", self.venueMap.userLocation);
    double distance = [self.venueMap.userLocation.location distanceFromLocation:eventLocation];
    NSLog(@"self.venueMap.userLocation.location.coordinate.longitude : %f / %f", self.venueMap.userLocation.location.coordinate.longitude, self.venueMap.userLocation.location.coordinate.latitude);
    NSLog(@"eventLocation.coordinate.longitude/latitude : %f / %f", eventLocation.coordinate.longitude, eventLocation.coordinate.latitude);
    NSLog(@"distance : %f", distance);
    return distance;
}

////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
#pragma mark - UITableViewDataSource
////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    self.allEventProperties = @[[NSString stringWithFormat:@"Who ?  %@", self.event.artist.name],
                                [NSString stringWithFormat:@"When ?  %@", [NSDate stringFromDate:self.event.date]],
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
    
    //CHANGE FONT UPON ROTATION
    cell.textLabel.font = [UIFont fontWithName:@"Helvetica" size:16.0f];
    if (UIDeviceOrientationIsLandscape([UIDevice currentDevice].orientation))
    {
        cell.textLabel.font = [UIFont fontWithName:@"Helvetica" size:12.0f];
    }
    
    //BUTTONS ON CELL 0 AND 2
    if (indexPath.row == 0 || indexPath.row == 2)
    {
        cell.accessoryType = UITableViewCellAccessoryDetailDisclosureButton;
    }
    
    return cell;
}

//////////////////////////////////////////////////////
-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (UIDeviceOrientationIsLandscape([UIDevice currentDevice].orientation))
    {
        return self.tableViewHeight/10;
    }
    return self.tableViewHeight/6;
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
        JIPArtistDetailsViewController *artistDetailsVC = [[JIPArtistDetailsViewController alloc] init];
        artistDetailsVC.artist = self.event.artist;
        [self.navigationController pushViewController:artistDetailsVC animated:YES];
    }
    
    //GO TO VENUE DETAILS VC
    if (indexPath.row == 2)
    {
        JIPVenueDetailsViewController *venueDetailsVC = [[JIPVenueDetailsViewController alloc] init];
        venueDetailsVC.venue = self.event.venue;
        [self.navigationController pushViewController:venueDetailsVC animated:YES];
    }
    
    //Go to Songkick's event page to check prices
    if (indexPath.row == 3)
    {
        [[UIApplication sharedApplication] openURL:self.event.uri];
    }
}


////////////////REPLICATE didSelectRow BEHAVIOR (above) FOR ACCESSORY BUTTON///////////////////////////////
-(void)tableView:(UITableView *)tableView accessoryButtonTappedForRowWithIndexPath:(NSIndexPath *)indexPath
{
    [self tableView:tableView didSelectRowAtIndexPath:indexPath];
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
    
    UIButton *disclosureButton = [UIButton buttonWithType:UIButtonTypeDetailDisclosure];
    view.rightCalloutAccessoryView = disclosureButton;
    
    return view;
}

-(void)mapView:(MKMapView *)mapView annotationView:(MKAnnotationView *)view calloutAccessoryControlTapped:(UIControl *)control
{
    JIPVenueDetailsViewController *venueDetailsVC = [[JIPVenueDetailsViewController alloc] init];
    venueDetailsVC.venue = self.event.venue;
    [self.navigationController pushViewController:venueDetailsVC animated:YES];
}

@end
