//
//  JIPConcertDetailsViewController.m
//  JazzInParis
//
//  Created by Max on 04/02/14.
//  Copyright (c) 2014 Max. All rights reserved.
//

#import "JIPConcertDetailsViewController.h"
#import "JIPMyPinView.h"

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
	// Do any additional setup after loading the view.
    
    /////////////////////////////////////////////////////TABLE VIEW WITH EVENT DETAILS//
    CGRect frame = CGRectMake(0, 0, 320, 230);
    UITableView *tableView = [[UITableView alloc] initWithFrame:frame];
    tableView.dataSource = self;
    [self.view addSubview:tableView];
    
    
    /////////////////////////////////////////////////////DESSINE MAPVIEW//
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

    
    //CENTRER SUR LE VENUE ET NE PAS MONTRER LA POSITION SYSTEME
    [self.venueMap setCenterCoordinate:eventCoordinate animated:YES];
    self.venueMap.showsUserLocation = YES;
    
    //ADD ANNOTATION
    self.event.distanceFromUserToEvent = [self distanceFromUserLocationToEvent];
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
    NSLog(@"%@", self.venueMap.userLocation.location);
    NSLog(@"%@", eventLocation);
    NSLog(@"%f", distance);
    return distance;
}

////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
#pragma mark - UITableViewDataSource
////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    self.allEventProperties = @[self.event.name, self.event.type, self.event.uri, self.event.ageRestriction];
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
    
    return cell;
}


////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
#pragma mark - MKMapViewDelegate
////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
- (MKAnnotationView *)mapView:(MKMapView *)mapView viewForAnnotation:(id<MKAnnotation>)annotation
{
    
    MKAnnotationView *view = [[JIPMyPinView alloc] initWithAnnotation:annotation reuseIdentifier:@"AnnotationId"];
    
    view.canShowCallout = YES;
    view.image = [[UIImage imageNamed:@"Venue"] imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
    
    UIButton *disclosureButton = [UIButton buttonWithType:UIButtonTypeDetailDisclosure];
    view.rightCalloutAccessoryView = disclosureButton;
    
    return view;
}

-(void)mapViewDidFinishLoadingMap:(MKMapView *)mapView
{
    [mapView selectAnnotation:self.event animated:YES];
}

@end
