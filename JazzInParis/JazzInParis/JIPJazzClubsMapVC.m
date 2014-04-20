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


@interface JIPJazzClubsMapVC ()

@end

@implementation JIPJazzClubsMapVC

@synthesize allJazzClubsMap = _allJazzClubsMap;
@synthesize jazzClubsArray  = _jazzClubsArray;

////////////////////////////////////////////////
//method for every rootVC / implements side menu
////////////////////////////////////////////////
- (IBAction)revealMenu:(id)sender
{
    [self.slidingViewController anchorTopViewTo:ECRight];
}



- (void)viewDidLoad
{
    
    [super viewDidLoad];
    self.title = @"Jazz Clubs in Paris";

    ////////////////////////////////////////////FETCH JAZZ CLUBS IN CORE DATA
    NSFetchRequest *request = [NSFetchRequest fetchRequestWithEntityName:@"JIPVenue"];
    request.predicate = [NSPredicate predicateWithFormat:@"id = -1"];
    NSError *error = nil;
    _jazzClubsArray = [[JIPManagedDocument sharedManagedDocument].managedObjectContext executeFetchRequest:request error:&error];
    
    ////////////////////////////////////////////POSITIONNE MAPVIEW DANS L'ESPACE AVEC PARIS COMME CENTRE
    CLLocationCoordinate2D parisCenterCoordinate = CLLocationCoordinate2DMake(48.86222222222222, 2.340833333333333);
    double regionWidth  = 12000;
    double regionHeight = 11000;
    MKCoordinateRegion startRegion = MKCoordinateRegionMakeWithDistance(parisCenterCoordinate, regionWidth, regionHeight);
    [_allJazzClubsMap setRegion:startRegion
                    animated:YES];
    
    //CENTRER SUR LE VENUE ET TRACK USER
    _allJazzClubsMap.showsUserLocation = YES;
    
    [_allJazzClubsMap addAnnotations:_jazzClubsArray];
    
}


////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
#pragma mark - MKMapViewDelegate
////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
- (MKAnnotationView *)mapView:(MKMapView *)mapView viewForAnnotation:(id<MKAnnotation>)annotation
{
    //We want to display UserLocation as classic blue dot, not custom
    if([annotation isKindOfClass:[MKUserLocation class]]) {return nil;}
    
    MKAnnotationView *view = [[MKAnnotationView alloc] initWithAnnotation:annotation reuseIdentifier:@"AnnotationId"];
    
    view.canShowCallout = YES;
    view.image = [UIImage imageNamed:@"Venue"];
    
    UIButton *disclosureButton = [UIButton buttonWithType:UIButtonTypeDetailDisclosure];
    view.rightCalloutAccessoryView = disclosureButton;
    
    return view;
}

-(void)mapView:(MKMapView *)mapView didAddAnnotationViews:(NSArray *)views
{
    for (MKAnnotationView *annView in views)
    {
        CGRect endFrame = annView.frame;
        annView.frame = CGRectOffset(endFrame, 0, -500);
        [UIView animateWithDuration:0.5
                         animations:^{ annView.frame = endFrame; }];
    }
}

@end