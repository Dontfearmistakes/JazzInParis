//
//  JIPVenueMapVC.m
//  JazzInParis
//
//  Created by Max on 09/04/14.
//  Copyright (c) 2014 Max. All rights reserved.
//

#import "JIPVenueMapVC.h"
#import "JIPMyPinView.h"

@interface JIPVenueMapVC ()

@end

@implementation JIPVenueMapVC

@synthesize event            = _event  ;
@synthesize venue            = _venue  ;
@synthesize mapView          = _mapView;
@synthesize venueNameNavItem = _venueNameNavItem;
@synthesize phoneLabel       = _phoneLabel;
@synthesize addressLabel     = _addressLabel;
@synthesize websiteButton     = _websiteButton;



-(void)viewDidLoad
{
    [super viewDidLoad];
    
    _venueNameNavItem.title         = _venue.name;
    _phoneLabel.text                = _venue.phone;
    _addressLabel.text              = _venue.street;
    [_websiteButton setTitle:_venue.websiteString forState:UIControlStateNormal];


    
    _mapView         .scrollEnabled = YES;
    
    //////////////////////////////////////////// 3) POSITIONNE MAPVIEW DANS L'ESPACE AVEC eventCoordinate COMME CENTRE
    ////////////////////////////////////////////    + TRACK USER
    /////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
    double regionWidth = 2500;
    double regionHeight = 2200;
    CLLocationCoordinate2D eventCoordinate = CLLocationCoordinate2DMake(_event.location.latitude, _event.location.longitude);
    MKCoordinateRegion     startRegion     = MKCoordinateRegionMakeWithDistance(eventCoordinate, regionWidth, regionHeight);
   
    [_mapView setRegion          :startRegion     animated:YES];
    [_mapView setCenterCoordinate:eventCoordinate animated:YES];
     _mapView.showsUserLocation  = YES;
    
    
    //initialisation cf didUpdateUserLocation below
    self.event.distanceFromUserToEvent = 0;
    self.event.shouldDisplayDistanceFromUserToEvent = NO;
    
    //ADD ANNOTATION
    [_mapView addAnnotation:_event];
}



- (IBAction)venueWebsiteClick:(id)sender
{
    [[UIApplication sharedApplication] openURL:[NSURL URLWithString:_venue.websiteString]];
}


////////////////////////////////////////////////////
///Automatically show Callout every time VC appears
////////////////////////////////////////////////////
-(void)viewDidAppear:(BOOL)animated
{
    [_mapView selectAnnotation:self.event animated:YES];
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
    
    return [_mapView.userLocation.location distanceFromLocation:eventLocation];;
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