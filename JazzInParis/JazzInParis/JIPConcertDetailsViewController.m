//
//  JIPConcertDetailsViewController.m
//  JazzInParis
//
//  Created by Max on 04/02/14.
//  Copyright (c) 2014 Max. All rights reserved.
//

#import "JIPConcertDetailsViewController.h"
#import "JIPMapAnnotation.h"

@interface JIPConcertDetailsViewController ()

@end

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
//////////////////////////////////////////////////////////////////////
- (void)viewDidLoad
{
    [super viewDidLoad];
    self.title = [NSString stringWithFormat:@"%@ Concert", self.event.name];
	// Do any additional setup after loading the view.
    
    
    /////////////////////////////////////////////////////NAME OF CONCERT LABEL//
    UILabel *concertNameLabel = [[UILabel alloc] init];
    concertNameLabel.frame = CGRectMake(30,100,200,40);
    concertNameLabel.backgroundColor = [UIColor blueColor];
    concertNameLabel.textAlignment = NSTextAlignmentCenter;
    concertNameLabel.font = [UIFont fontWithName:@"Helvetica" size:16.0f];
    concertNameLabel.text = self.event.name;
    [self.view addSubview:concertNameLabel];
    
    
    /////////////////////////////////////////////////////CONCERT VENUE MAPVIEW//
    self.venueMap = [[MKMapView alloc] init];
    self.venueMap.delegate = self;
    self.venueMap.frame = CGRectMake(0, 140, 320, 300);
    self.venueMap.scrollEnabled = YES;
    self.venueMap.zoomEnabled = NO;
    [self.view addSubview:self.venueMap];
    
    CLLocationCoordinate2D centerCoordinate = CLLocationCoordinate2DMake(self.event.location.latitude, self.event.location.longitude);
    double regionWidth = 2500;
    double regionHeight = 2200;
    MKCoordinateRegion startRegion = MKCoordinateRegionMakeWithDistance(centerCoordinate, regionWidth, regionHeight);
    [self.venueMap setRegion:startRegion
                  animated:YES];
    
    self.venueMap.showsUserLocation = NO;
    
    CLLocationCoordinate2D annotationCoordinate = CLLocationCoordinate2DMake(self.event.location.latitude, self.event.location.longitude)
    ;
    
    JIPMapAnnotation *annotation = [[JIPMapAnnotation alloc] init];
    annotation.coordinate = annotationCoordinate;
    
    [self.venueMap addAnnotation:annotation];
    
}

- (MKAnnotationView *)mapView:(MKMapView *)mapView viewForAnnotation:(id<MKAnnotation>)annotation
{
    if([annotation isKindOfClass:[MKUserLocation class]]) {
        return nil;
    }
    
    MKAnnotationView *view = [self.venueMap dequeueReusableAnnotationViewWithIdentifier:@"annoView"];
    if(!view) {
        view = [[MKAnnotationView alloc] initWithAnnotation:annotation reuseIdentifier:@"annoView"];
    }
    
    view.canShowCallout = YES;
    
    return view;
}



@end
