//
//  JIPJazzClubsMapVC.m
//  JazzInParis
//
//  Created by Max on 20/04/14.
//  Copyright (c) 2014 Max. All rights reserved.
//

#import "JIPJazzClubsMapVC.h"
#import "JIPVenue+Create.h"
#import "JIPManagedDocument.h"
#import "ECSlidingViewController.h"
#import "JIPVenueMapVC.h"
#import "JIPVenue.h"

@interface JIPJazzClubsMapVC ()

@end

@implementation JIPJazzClubsMapVC

@synthesize allJazzClubsMap = _allJazzClubsMap;
@synthesize jazzClubsArray  = _jazzClubsArray;
@synthesize venue           = _venue;

////////////////////////////////////////////////
//method for every rootVC / implements side menu
////////////////////////////////////////////////
- (IBAction)revealMenu:(id)sender
{
    [self.slidingViewController anchorTopViewTo:ECRight];
}



- (void)viewWillAppear:(BOOL)animated
{
    
    [super viewWillAppear:YES];
    self.title = @"Jazz Clubs in Paris";

    ////////////////////////////////////////////FETCH JAZZ CLUBS IN CORE DATA
    NSFetchRequest *request = [NSFetchRequest fetchRequestWithEntityName:@"JIPVenue"];
    request.predicate = [NSPredicate predicateWithFormat:@"id = -1"];
    NSError *error = nil;
    _jazzClubsArray = [[JIPManagedDocument sharedManagedDocument].managedObjectContext executeFetchRequest:request error:&error];
    
    for (JIPVenue *jazzClub in _jazzClubsArray)
    {
        //initialisation cf didUpdateUserLocation below
        jazzClub.distanceFromUserToVenue = 0;
        jazzClub.shouldDisplayDistanceFromUserToVenue = NO;
    }
    
    ////////////////////////////////////////////POSITIONNE MAPVIEW DANS L'ESPACE AVEC PARIS COMME CENTRE
    CLLocationCoordinate2D parisCenterCoordinate = CLLocationCoordinate2DMake(48.86222222222222, 2.340833333333333);
    double regionWidth  = 12000;
    double regionHeight = 11000;
    MKCoordinateRegion startRegion = MKCoordinateRegionMakeWithDistance(parisCenterCoordinate, regionWidth, regionHeight);
    [_allJazzClubsMap setRegion:startRegion
                    animated:YES];

    
    [_allJazzClubsMap addAnnotations:_jazzClubsArray];
    
}



//////////////////////////////////////////////
///Called when userLocation updated
//////////////////////////////////////////////
-(void)mapView:(MKMapView *)mapView didUpdateUserLocation:(MKUserLocation *)userLocation
{
    if (!userLocation)
    {
        for (JIPVenue *jazzClub in _jazzClubsArray)
        {
            jazzClub.shouldDisplayDistanceFromUserToVenue = NO;
            jazzClub.distanceFromUserToVenue = 0;
        }
    }
    else
    {
        for (JIPVenue *jazzClub in _jazzClubsArray)
        {
            //PASS distanceFromUserLocationToEvent to adhoc event @property to display it
            //as subtitle of the annotation (called by -viewForAnnotation below)
            jazzClub.shouldDisplayDistanceFromUserToVenue = YES;
            _venue = jazzClub;
            jazzClub.distanceFromUserToVenue = [self distanceFromUserLocationToEvent];
        }
    }
}



-(void)mapView:(MKMapView *)mapView didFailToLocateUserWithError:(NSError *)error
{
    for (JIPVenue *jazzClub in _jazzClubsArray)
    {
        jazzClub.shouldDisplayDistanceFromUserToVenue = NO;
        jazzClub.distanceFromUserToVenue = 0;
    }
}



//////////////////////////////////////////////
///USE CURRENT USER LOCATION TO CALCULATE DISTANCE TO eventCoordinare
//////////////////////////////////////////////
-(double)distanceFromUserLocationToEvent
{
    CLLocation *eventLocation = [[CLLocation alloc] initWithLatitude:_venue.location.latitude
                                                           longitude:_venue.location.longitude];
    
    return [_allJazzClubsMap.userLocation.location distanceFromLocation:eventLocation];;
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
    
    MKAnnotationView *view = [[MKAnnotationView alloc] initWithAnnotation:annotation reuseIdentifier:@"AnnotationId"];
    
    view.canShowCallout = YES;
    view.image = [UIImage imageNamed:@"jazzClubIcon"];
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


-(void)mapView:(MKMapView *)mapView didAddAnnotationViews:(NSArray *)views
{
    for (MKAnnotationView *annView in views)
    {
        #warning try to exclude userLocation blue dot from animation
        if([annView isKindOfClass:[MKUserLocation class]])
        {
            
        }
        else
        {
            CGRect endFrame = annView.frame;
            annView.frame = CGRectOffset(endFrame, 0, -500);
            [UIView animateWithDuration:0.5
                             animations:^{ annView.frame = endFrame; }];            
        }
    }
}

@end