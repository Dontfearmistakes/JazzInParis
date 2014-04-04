//
//  JIPConcertDetailsViewController.m
//  JazzInParis
//
//  Created by Max on 04/02/14.
//  Copyright (c) 2014 Max. All rights reserved.
//

#import "JIPManagedDocument.h"
#import "JIPConcertDetailsViewController.h"
#import "JIPMyPinView.h"
#import "JIPVenueDetailsViewController.h"
#import "JIPArtistDetailsViewController.h"
#import "NSDate+Formatting.h"
#import "JIPVenue+Create.h"
#import "JIPArtist+Create.h"
#import "JIPUpdateManager.h"

const CGFloat JIPConcertDetailsTableViewHeightPercenatge = 0.5;

@interface JIPConcertDetailsViewController ()

@property (strong, nonatomic) UIView      *contentSubview;
@property (strong, nonatomic) NSArray     *allEventProperties;
@property (nonatomic)         CGFloat      tableViewHeight;
@property (strong, nonatomic) UITableView *topTableView;
@property (strong, nonatomic) MKMapView   *venueMap;

-(double)distanceFromUserLocationToEvent;

@end


//////////////////////////////////////////////////////////////////////
//////////////////////////////////////////////////////////////////////
@implementation JIPConcertDetailsViewController


-(NSUInteger)supportedInterfaceOrientations
{
    return UIInterfaceOrientationMaskAll;
}


////////////////
-(void)loadView
{
    UIView *view         = [[UIView alloc] init];
    view.backgroundColor = [UIColor greenColor];
    self.contentSubview  = [[UIView alloc] init];
    self.contentSubview.backgroundColor = [UIColor orangeColor];
    [view addSubview:self.contentSubview];
    
    self.view = view;
}


/////////////////////////////
-(void)viewWillLayoutSubviews
{
    self.contentSubview.frame = CGRectMake(
                                           0,
                                           0,
                                           CGRectGetWidth(self.view.frame),
                                           CGRectGetHeight(self.view.frame) - self.bottomLayoutGuide.length
                                           );
}

///////////////////
- (void)viewDidLoad
{
    [super viewDidLoad];
    
    ///////////////////////////////////////////////////// 1) TABLE VIEW WITH EVENT DETAILS
    //////////////////////////////////////////////////////////////////////////////////////
    
    self.topTableView = [[UITableView alloc] initWithFrame:CGRectZero];
    //Sizes are implemented in viewDidLayoutSubviews
    
    self.topTableView.dataSource       = self;
    self.topTableView.delegate         = self;
    self.topTableView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    [self.contentSubview addSubview:self.topTableView];
    
    ///////////////////////////////////////////////////// 2) DESSINE MAPVIEW
    ////////////////////////////////////////////////////////////////////////
    self.venueMap = [[MKMapView alloc] initWithFrame:CGRectZero];

    self.venueMap.delegate      = self;
    self.venueMap.scrollEnabled = YES;
    self.venueMap.zoomEnabled   = NO;
    self.venueMap.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    [self.contentSubview addSubview:self.venueMap];
    
    //////////////////////////////////////////// 3) POSITIONNE MAPVIEW DANS L'ESPACE AVEC eventCoordinate COMME CENTRE
    ////////////////////////////////////////////    + TRACK USER
    /////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
    CLLocationCoordinate2D eventCoordinate = CLLocationCoordinate2DMake(self.event.location.latitude, self.event.location.longitude);
    double regionWidth = 2500;
    double regionHeight = 2200;
    MKCoordinateRegion startRegion = MKCoordinateRegionMakeWithDistance(eventCoordinate, regionWidth, regionHeight);
    [self.venueMap setRegion:startRegion
                  animated:YES];

    [self.venueMap setCenterCoordinate:eventCoordinate animated:YES];
     self.venueMap .showsUserLocation = YES;
    
    
    //initialisation cf didUpdateUserLocation below
    self.event.distanceFromUserToEvent = 0;
    self.event.shouldDisplayDistanceFromUserToEvent = NO;
    
    //ADD ANNOTATION
    [self.venueMap addAnnotation:self.event];
    
}


////////////////////////////
-(void)viewDidLayoutSubviews
//called when bounds are redrawn
{
    CGFloat superViewWidth  = self.contentSubview.bounds.size.width;
    CGFloat superViewHeight = self.contentSubview.bounds.size.height;
    self.tableViewHeight    = superViewHeight * JIPConcertDetailsTableViewHeightPercenatge;
    
    self.topTableView.frame = CGRectMake(0, 0, superViewWidth, self.tableViewHeight);
    self.venueMap    .frame = CGRectMake(0, self.tableViewHeight, superViewWidth, superViewHeight - self.tableViewHeight);
}


/////////////////////////////////////////////////////////////////////////////////////////////
-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    [self viewDidLayoutSubviews]; // calling it first to make sure that all size have already been recalculated before sizing the cell
    CGFloat cellHeight = (self.tableViewHeight - 55) / [self.allEventProperties count];
    return cellHeight;
}



//////////////////////////////////////////////
///Called when userLocation updated
//////////////////////////////////////////////
-(void)mapView:(MKMapView *)mapView didUpdateUserLocation:(MKUserLocation *)userLocation
{
    if (!userLocation)
    {
        self.event.shouldDisplayDistanceFromUserToEvent = NO;
        self.event.distanceFromUserToEvent = 0;
    }
    else
    {
        //PASS distanceFromUserLocationToEvent to adhoc event @property to display it
        //as subtitle of the annotation (called by -viewForAnnotation below)
        self.event.shouldDisplayDistanceFromUserToEvent = YES;
        self.event.distanceFromUserToEvent = [self distanceFromUserLocationToEvent];
    }
}



-(void)mapView:(MKMapView *)mapView didFailToLocateUserWithError:(NSError *)error
{
    self.event.shouldDisplayDistanceFromUserToEvent = NO;
    self.event.distanceFromUserToEvent = 0;
}



//////////////////////////////////////////////
///USE CURRENT USER LOCATION TO CALCULATE DISTANCE TO eventCoordinare
//////////////////////////////////////////////
-(double)distanceFromUserLocationToEvent
{
    CLLocation *eventLocation = [[CLLocation alloc] initWithLatitude:self.event.location.latitude
                                                           longitude:self.event.location.longitude];
    
    return [self.venueMap.userLocation.location distanceFromLocation:eventLocation];;
}



//////////////////////////////////////////////
///Automatically show Callout
//////////////////////////////////////////////
-(void)viewDidAppear:(BOOL)animated
{
    [self.venueMap selectAnnotation:self.event animated:YES];
}








////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
#pragma mark - UITableViewDataSource
////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    self.allEventProperties = @[[NSString stringWithFormat:@"Who   ?  %@", self.event.artist.name],
                                [NSString stringWithFormat:@"When  ?  %@", [NSDate stringFromDate:self.event.date]],
                                [NSString stringWithFormat:@"Where ?  %@",self.event.venue.name],
                                [NSString stringWithFormat:@"Check prices on Songkick"]];
    return self.allEventProperties.count;
}



/////////////////////////////////////////////////////////////////////////////////////////////////////
-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"id"];
    
    //CELL GETS EVENT.NAME
    cell.textLabel.text = [NSString stringWithFormat:@"%@", self.allEventProperties[indexPath.row]];
    cell.backgroundColor = [UIColor blueColor];
    
    //Disclosure Indicator
    if (indexPath.row == 2 || indexPath.row == 3)
    {
        cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
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
        [[UIApplication sharedApplication] openURL:[NSURL URLWithString:self.event.uriString]];
    }
    
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
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
