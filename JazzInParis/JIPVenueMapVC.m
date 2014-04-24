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

@synthesize event             = _event  ;
@synthesize venue             = _venue  ;
@synthesize mapView           = _mapView;
@synthesize venueNameNavItem  = _venueNameNavItem;
@synthesize phoneNumberButton = _phoneNumberButton;
@synthesize addressLabel      = _addressLabel;
@synthesize websiteButton     = _websiteButton;



-(void)viewDidLoad
{
    [super viewDidLoad];
    
    self.view.backgroundColor = Rgb2UIColor(48, 48, 48);
    
    _venueNameNavItem.title         = _venue.name;
    _addressLabel.text              = _venue.street;
    
    
    [_phoneNumberButton setTitle:_venue.phone         forState:UIControlStateNormal] ;
    [_websiteButton     setTitle:_venue.websiteString forState:UIControlStateNormal];

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
    //_venue.distanceFromUserToVenue = 0;
    //_venue.shouldDisplayDistanceFromUserToVenue = NO;
    
    //ADD ANNOTATION
    [_mapView addAnnotation:_venue];
}


- (IBAction)phoneNumberClick:(id)sender
{
    NSString *spacesFreePhoneNumber = [_venue.phone stringByReplacingOccurrencesOfString:@" " withString:@""];
    [[UIApplication sharedApplication] openURL:[NSURL URLWithString:[NSString stringWithFormat:@"tel://%@", spacesFreePhoneNumber]]];
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
    [_mapView selectAnnotation:_venue animated:YES];
}





//////////////////////////////////////////////
///Called when userLocation updated
//////////////////////////////////////////////
-(void)mapView:(MKMapView *)mapView didUpdateUserLocation:(MKUserLocation *)userLocation
{
    if (!userLocation)
    {
        _venue.shouldDisplayDistanceFromUserToVenue = NO;
        _venue.distanceFromUserToVenue = 0;
    }
    else
    {
        //PASS distanceFromUserLocationToEvent to adhoc event @property to display it
        //as subtitle of the annotation (called by -viewForAnnotation below)
        _venue.shouldDisplayDistanceFromUserToVenue = YES;
        _venue.distanceFromUserToVenue = [self distanceFromUserLocationToEvent];
    }
}



-(void)mapView:(MKMapView *)mapView didFailToLocateUserWithError:(NSError *)error
{
    _venue.shouldDisplayDistanceFromUserToVenue = NO;
    _venue.distanceFromUserToVenue = 0;
}



//////////////////////////////////////////////
///USE CURRENT USER LOCATION TO CALCULATE DISTANCE TO eventCoordinare
//////////////////////////////////////////////
-(double)distanceFromUserLocationToEvent
{
    CLLocation *eventLocation = [[CLLocation alloc] initWithLatitude:_venue.location.latitude
                                                           longitude:_venue.location.longitude];
    
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
    //We want to display UserLocation as classic blue dot, not custom
    if([annotation isKindOfClass:[MKUserLocation class]])
    {
        return nil;
    }
    
    view.canShowCallout = YES;
    
    return view;
}



@end