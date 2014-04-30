//
//  JIPJazzClubsMapVC.m
//  JazzInParis
//
//  Created by Max on 20/04/14.
//  Copyright (c) 2014 Max. All rights reserved.
//

#import "JIPMyPinView.h"
#import "JIPJazzClubsMapVC.h"
#import "JIPVenue+Create.h"
#import "JIPManagedDocument.h"
#import "ECSlidingViewController.h"
#import "JIPVenueMapVC.h"
#import "JIPVenue.h"


@interface JIPJazzClubsMapVC ()

@end

@implementation JIPJazzClubsMapVC

@synthesize allJazzClubsMap             = _allJazzClubsMap;
@synthesize jazzClubsArrayFromCoreData  = _jazzClubsArrayFromCoreData;
@synthesize venue                       = _venue;

////////////////////////////////////////////////
//method for every rootVC / implements side menu
////////////////////////////////////////////////
- (IBAction)revealMenu:(id)sender
{
    [self.slidingViewController anchorTopViewTo:ECRight];
}


-(void)viewDidLoad
{
    [super viewDidLoad];
    
    self.title = @"Jazz Clubs in Paris";

    ///////////////////////////////////////////////////////Style buttons
    _buttonForUserLocation.layer.cornerRadius = 5;
    _buttonForUserLocation.layer.borderColor = [UIColor grayColor].CGColor;
    _buttonForUserLocation.layer.borderWidth = 1;
    
    _buttonBackToLargeView.layer.cornerRadius = 5;
    _buttonBackToLargeView.layer.borderColor = [UIColor grayColor].CGColor;
    _buttonBackToLargeView.layer.borderWidth = 1;

    
    ////////////////////////////////////////////POSITIONNE MAPVIEW DANS L'ESPACE AVEC PARIS COMME CENTRE
    CLLocationCoordinate2D parisCenterCoordinate = CLLocationCoordinate2DMake(48.86222222222222, 2.340833333333333);
    double regionWidth  = 12000;
    double regionHeight = 11000;
    MKCoordinateRegion startRegion = MKCoordinateRegionMakeWithDistance(parisCenterCoordinate, regionWidth, regionHeight);
    [_allJazzClubsMap setRegion:startRegion
                       animated:YES];

}




-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:YES];

    ////////////////////////////////////////////////////////FETCH JAZZ CLUBS IN CORE DATA
    
    [[JIPManagedDocument sharedManagedDocument] performBlockWithDocument:^(JIPManagedDocument *managedDocument) {
    
        NSFetchRequest *request = [NSFetchRequest fetchRequestWithEntityName:@"JIPVenue"];
        request.predicate = [NSPredicate predicateWithFormat:@"isJazzClub == %@", @1];
        NSError *error = nil;
        _jazzClubsArrayFromCoreData = [managedDocument.managedObjectContext executeFetchRequest:request error:&error];
        
        ///////////////////////////////////////////////////////Don't display distance to userLocation
        for (JIPVenue *jazzClub in _jazzClubsArrayFromCoreData)
        {
            [jazzClub setShouldDisplayDistanceFromUserToVenue:NO];
        }
        
        [_allJazzClubsMap addAnnotations:_jazzClubsArrayFromCoreData];
    }];
    
}


////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
#pragma mark - MKMapViewDelegate
////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
- (MKAnnotationView *)mapView:(MKMapView *)mapView viewForAnnotation:(id<MKAnnotation>)annotation
{
    //We want to display UserLocation as classic blue dot, not custom
    if([annotation isKindOfClass:[MKUserLocation class]])
        return nil;
    
    JIPMyPinView *view = [[JIPMyPinView alloc] initWithAnnotation:annotation reuseIdentifier:@"AnnotationId"];
    
    view.canShowCallout = YES;
    view.rightCalloutAccessoryView = [UIButton buttonWithType:UIButtonTypeDetailDisclosure];;
    
    return view;
}




-(void)mapView:(MKMapView *)mapView annotationView:(MKAnnotationView *)view calloutAccessoryControlTapped:(UIControl *)control
{
    _venue = view.annotation;
    [self performSegueWithIdentifier:@"toVenueDetails" sender:nil];
}


-(void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([segue.identifier isEqualToString:@"toVenueDetails"])
    {
        JIPVenueMapVC * venueMapVC  = [segue destinationViewController];
        [venueMapVC setVenue:_venue];
    }
}

////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
#pragma mark - IBActions
////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////


- (IBAction)buttonForUserLocationClick:(id)sender
{
    if ([CLLocationManager authorizationStatus] != kCLAuthorizationStatusDenied)
    {
        double regionWidth  = 1200;
        double regionHeight = 1100;
        MKCoordinateRegion startRegion = MKCoordinateRegionMakeWithDistance(_allJazzClubsMap.userLocation.location.coordinate, regionWidth, regionHeight);
        [_allJazzClubsMap setRegion:startRegion
                           animated:YES];
    }
    else
    {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Location Service disabled for Dontfearmistakes."
                                                        message:@"Please go to your settings"
                                                       delegate:self
                                              cancelButtonTitle:@"OK"
                                              otherButtonTitles:nil];
        [alert show];
    }
}

- (IBAction)buttonBackToLargeViewClick:(id)sender
{
    CLLocationCoordinate2D parisCenterCoordinate = CLLocationCoordinate2DMake(48.86222222222222, 2.340833333333333);
    double regionWidth  = 12000;
    double regionHeight = 11000;
    MKCoordinateRegion startRegion = MKCoordinateRegionMakeWithDistance(parisCenterCoordinate, regionWidth, regionHeight);
    [_allJazzClubsMap setRegion:startRegion
                       animated:YES];
}
@end