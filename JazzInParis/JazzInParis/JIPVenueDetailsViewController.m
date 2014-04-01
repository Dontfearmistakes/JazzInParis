//
//  JIPVenueDetailsViewController.m
//  JazzInParis
//
//  Created by Max on 11/02/14.
//  Copyright (c) 2014 Max. All rights reserved.
//


#import "JIPVenueDetailsViewController.h"
#import "JIPMyPinView.h"
#import "JIPManagedDocument.h"
#import "JIPUpdateManager.h"
#import "JIPVenue+Create.m"

////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////

const CGFloat JIPVenueDetailsTableViewHeightPercenatge = 0.5;

@interface JIPVenueDetailsViewController ()

@property (strong, nonatomic) NSArray *venueDetailsRows;
@property (strong, nonatomic) UITableView *topTableView;

@end


////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////
@implementation JIPVenueDetailsViewController



- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.title = [NSString stringWithFormat:@"%@", self.venue.name];
    
    ///////////////////////////////////////////////////// 1) TABLE VIEW WITH EVENT DETAILS
    //////////////////////////////////////////////////////////////////////////////////////
    CGFloat superViewWidth  = self.view.bounds.size.width;
    CGFloat superViewHeight = self.view.bounds.size.height;
    CGFloat tableViewHeight = superViewHeight * JIPVenueDetailsTableViewHeightPercenatge;
    
    CGRect frame = CGRectMake(0, 0, superViewWidth, tableViewHeight);
    self.topTableView = [[UITableView alloc] initWithFrame:frame];
    
    //Resizing when super view redraw itself (rotation for example)
    self.topTableView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;

    self.topTableView.dataSource = self;
    self.topTableView.delegate   = self;
    [self.view addSubview:self.topTableView];
    
    ///////////////////////////////////////////////////// 2) DESSINE MAPVIEW
    ////////////////////////////////////////////////////////////////////////
    self.venueMap = [[MKMapView alloc] init];
    self.venueMap.delegate      = self;
    self.venueMap.frame         = CGRectMake(0, tableViewHeight, superViewWidth, superViewHeight-tableViewHeight);
    self.venueMap.scrollEnabled = YES;
    self.venueMap.zoomEnabled   = NO;
    [self.view addSubview:self.venueMap];
    
    self.venueMap.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    
    //////////////////////////////////////////// 3)POSITIONNE MAPVIEW DANS L'ESPACE AVEC eventCoordinate COMME CENTRE ET TRACK USER
    /////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
    CLLocationCoordinate2D venueCoordinate = CLLocationCoordinate2DMake(self.venue.location.latitude, self.venue.location.longitude);
    double regionWidth  = 2500;
    double regionHeight = 2200;
    MKCoordinateRegion startRegion = MKCoordinateRegionMakeWithDistance(venueCoordinate, regionWidth, regionHeight);
    [self.venueMap setRegion:startRegion
                    animated:YES];

    [self.venueMap setCenterCoordinate:venueCoordinate animated:YES];
    self.venueMap.showsUserLocation = YES;
    

    //initialisation cf didUpdateUserLocation below
    self.venue.distanceFromUserToVenue = 0;
    self.venue.shouldDisplayDistanceFromUserToVenue = NO;
    
    //ADD ANNOTATION
    [self.venueMap addAnnotation:self.venue];
}

-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:YES];

    //1) Create http request
    NSURLSession * session  = [NSURLSession sharedSession];
    NSURL *url = [[JIPUpdateManager sharedUpdateManager] songkickURLUpcomingEventsForVenueWithId:[NSString stringWithFormat:@"%@", self.venue.id]];
    
    NSURLSessionDataTask *dataTask = [session dataTaskWithURL:url
                                            completionHandler:^(NSData *data, NSURLResponse *response, NSError *error) {
                                                
                                                NSError *localError = nil;
                                                NSDictionary *parsedObject = [NSJSONSerialization JSONObjectWithData:data options:0 error:&localError];
                                                NSDictionary *dictionnaryOfVenue = parsedObject[@"resultsPage"][@"results"][@"venue"];
                                                
                                                [[JIPManagedDocument sharedManagedDocument] performBlockWithDocument:^(JIPManagedDocument *managedDocument)
                                                    {
                                                        self.venue = [JIPVenue venueWithDict:@{@"id"            : dictionnaryOfVenue[@"id"],
                                                                                               @"street"        : dictionnaryOfVenue[@"street"],
                                                                                               @"capacity"      : dictionnaryOfVenue[@"capacity"],
                                                                                               @"desc"          : dictionnaryOfVenue[@"description"],
                                                                                               @"phone"         : dictionnaryOfVenue[@"phone"],
                                                                                               @"websiteString" : dictionnaryOfVenue[@"website"],
                                                                                               @"city"          : dictionnaryOfVenue[@"city"][@"displayName"]
                                                                                  }
                                                         inManagedObjectContext:managedDocument.managedObjectContext];
                                                    }
                                                ];
                                                [self.topTableView reloadData];
                                            }];
    
    [dataTask resume];
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
-(double)distanceFromUserLocationToVenue
{
    CLLocation *eventLocation = [[CLLocation alloc] initWithLatitude:self.venue.location.latitude
                                                           longitude:self.venue.location.longitude];
    
    double distance = [self.venueMap.userLocation.location distanceFromLocation:eventLocation];
    return distance;
}

//////////////////////////////////////////////
///Called when userLocation updated
//////////////////////////////////////////////
-(void)mapView:(MKMapView *)mapView didUpdateUserLocation:(MKUserLocation *)userLocation
{
    if (!userLocation)
    {
        self.venue.shouldDisplayDistanceFromUserToVenue = NO;
        self.venue.distanceFromUserToVenue = 0;
    }
    else
    {
        //PASS distanceFromUserLocationToEvent to adhoc event @property to display it
        //as subtitle of the annotation (called by -viewForAnnotation below)
        self.venue.shouldDisplayDistanceFromUserToVenue = YES;
        self.venue.distanceFromUserToVenue = [self distanceFromUserLocationToVenue];
    }
}



-(void)mapView:(MKMapView *)mapView didFailToLocateUserWithError:(NSError *)error
{
    self.venue.shouldDisplayDistanceFromUserToVenue = NO;
    self.venue.distanceFromUserToVenue = 0;
}



////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
#pragma mark - UITableViewDataSource
////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{

    if (self.venue.street == nil){
        self.venue.street = @"No adress available";
    }
    if (self.venue.city == nil) {
        self.venue.city = @"No city available";
    }
    if (self.venue.desc == nil || [self.venue.desc isEqualToString:@""]) {
        self.venue.desc = @"No description available";
    }
    if (self.venue.websiteString == nil) {
        self.venue.websiteString = @"No website available";
    }
    if (self.venue.phone == nil || [self.venue.phone isEqualToString:@"<null>"]) {
        self.venue.phone = @"No Phone available";
    }
    
    self.venueDetailsRows = @[
                              [NSString stringWithFormat:@"%@ - %@", self.venue.street, self.venue.city],
                              self.venue.desc,
                              self.venue.websiteString,
                              self.venue.phone];
    return self.venueDetailsRows.count;
}


//////////////////////////////////////////////////////
-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"id"];
    
    //CELL GETS EVENT.NAME
    cell.textLabel.text = [NSString stringWithFormat:@"%@", self.venueDetailsRows[indexPath.row]];
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
        [[UIApplication sharedApplication] openURL:[NSURL URLWithString:self.venue.websiteString]];
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
    
    return view;
}
@end
