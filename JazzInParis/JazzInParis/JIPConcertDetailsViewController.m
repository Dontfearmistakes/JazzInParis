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


-(NSUInteger)supportedInterfaceOrientations
{
    return UIInterfaceOrientationMaskAll;
}


//////////////////////////////////////////////////////////////////////
- (void)viewDidLoad
{
    [super viewDidLoad];
    
    ///////////////////////////////////////////////////// 1) TABLE VIEW WITH EVENT DETAILS
    //////////////////////////////////////////////////////////////////////////////////////
    
    self.topTableView = [[UITableView alloc] initWithFrame:CGRectZero];
    //Resizing when super view redraw itself (rotation for example)
    
    self.topTableView.dataSource = self;
    self.topTableView.delegate = self;
    [self.view addSubview:self.topTableView];
    
    ///////////////////////////////////////////////////// 2) DESSINE MAPVIEW
    ////////////////////////////////////////////////////////////////////////
    self.venueMap = [[MKMapView alloc] initWithFrame:CGRectZero];

    self.venueMap.delegate = self;
    self.venueMap.scrollEnabled = YES;
    self.venueMap.zoomEnabled = NO;
    [self.view addSubview:self.venueMap];
    
    //////////////////////////////////////////// 3) POSITIONNE MAPVIEW DANS L'ESPACE AVEC eventCoordinate COMME CENTRE
    //////////////////////////////////////////////// + TRACK USER
    /////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
    CLLocationCoordinate2D eventCoordinate = CLLocationCoordinate2DMake(self.event.location.latitude, self.event.location.longitude);
    double regionWidth = 2500;
    double regionHeight = 2200;
    MKCoordinateRegion startRegion = MKCoordinateRegionMakeWithDistance(eventCoordinate, regionWidth, regionHeight);
    [self.venueMap setRegion:startRegion
                  animated:YES];

    [self.venueMap setCenterCoordinate:eventCoordinate animated:YES];
    self.venueMap.showsUserLocation = YES;
    
    
    //initialisation cf didUpdateUserLocation below
    self.event.distanceFromUserToEvent = 0;
    self.event.shouldDisplayDistanceFromUserToEvent = NO;
    
    //ADD ANNOTATION
    [self.venueMap addAnnotation:self.event];
    
}



-(void)viewDidLayoutSubviews
//called when bounds are redrawn
{
    CGFloat superViewWidth = self.view.bounds.size.width;
    CGFloat superViewHeight = self.view.bounds.size.height;
    self.tableViewHeight = superViewHeight * JIPConcertDetailsTableViewHeightPercenatge;
    
    self.topTableView.frame = CGRectMake(0, 0, superViewWidth, self.tableViewHeight);
    
    self.venueMap.frame = CGRectMake(0, self.tableViewHeight, superViewWidth, superViewHeight - self.tableViewHeight);

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



//////////////////////////////////////////////
///ROTATION
//////////////////////////////////////////////
-(void)didRotateFromInterfaceOrientation:(UIInterfaceOrientation)fromInterfaceOrientation
{
    [super didRotateFromInterfaceOrientation:fromInterfaceOrientation];
    [self.topTableView reloadData];
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
                                [NSString stringWithFormat:@"Check prices : %@", self.event.uriString],
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
        
        //FETCH VENUE IN CONTEXT AND PASS IT TO venueDetailsVC.venue
        [[JIPManagedDocument sharedManagedDocument] performBlockWithDocument:^(JIPManagedDocument *managedDocument)
         {
             venueDetailsVC.venue = [JIPVenue venueWithName:self.event.venue.name
                                     inManagedObjectContext:managedDocument.managedObjectContext];
         }];
        
        [self.navigationController pushViewController:venueDetailsVC animated:YES];
    }
    
    //Go to Songkick's event page to check prices
    if (indexPath.row == 3)
    {
        [[UIApplication sharedApplication] openURL:[NSURL URLWithString:self.event.uriString]];
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
    
    //FETCH VENUE IN CONTEXT AND PASS IT TO venueDetailsVC.venue
    [[JIPManagedDocument sharedManagedDocument] performBlockWithDocument:^(JIPManagedDocument *managedDocument)
    {
        venueDetailsVC.venue = [JIPVenue venueWithName:self.event.venue.name
                                inManagedObjectContext:managedDocument.managedObjectContext];
    }];
    
    [self.navigationController pushViewController:venueDetailsVC animated:YES];
}

@end
