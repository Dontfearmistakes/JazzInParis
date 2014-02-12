//
//  JIPJazzClubsViewController.m
//  JazzInParis
//
//  Created by Max on 12/02/14.
//  Copyright (c) 2014 Max. All rights reserved.
//

#import "JIPJazzClubsViewController.h"
#import "JIPVenue.h"
#import "JIPMyPinView.h"

@interface JIPJazzClubsViewController ()

@property (strong, nonatomic) MKMapView *parisMap;
-(NSArray*)arrayFromJazzClubs;

@end

@implementation JIPJazzClubsViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
        self.title = @"Jazz Clubs";
        //self.tabBarItem.image = [UIImage imageNamed:@"Venue"];
    }
    return self;
}

-(NSArray*)arrayFromJazzClubs
{
    NSMutableArray *mutArray = [[NSMutableArray alloc] init];
    
    JIPVenue *baiserSale = [[JIPVenue alloc] initWithID:@1
                                                  name:@"Baiser Salé"
                                           description:@"Baiser Salé is an awesome Jazz Club with a Jam Session every Monday night"
                                                  city:@"Paris"
                                                street:@"58, rue des Lombards"
                                                 phone:@"+33 1 42 33 37 71"
                                               website:[NSURL URLWithString:@"http://www.lebaisersale.com"]
                                              capacity:@100];
    baiserSale.location = CLLocationCoordinate2DMake(48.859722222222224, 2.348055555555556);
    
    [mutArray addObject:baiserSale];
    
    NSArray *allJazzClubs = [[NSArray alloc]initWithArray:mutArray];
    return allJazzClubs;
    
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.
    ///////////////////////////////////////////////////// 2) DESSINE MAPVIEW
    self.parisMap = [[MKMapView alloc] init];
    self.parisMap.delegate = self;
    self.parisMap.frame = CGRectMake(0, 0, 320, 480);
    self.parisMap.scrollEnabled = YES;
    self.parisMap.zoomEnabled = YES;
    [self.view addSubview:self.parisMap];
    
    ////////////////////////////////////////////POSITIONNE MAPVIEW DANS L'ESPACE AVEC eventCoordinate COMME CENTRE
    CLLocationCoordinate2D parisCenterCoordinate = CLLocationCoordinate2DMake(48.86222222222222, 2.340833333333333);
    double regionWidth = 12000;
    double regionHeight = 11000;
    MKCoordinateRegion startRegion = MKCoordinateRegionMakeWithDistance(parisCenterCoordinate, regionWidth, regionHeight);
    [self.parisMap setRegion:startRegion
                    animated:YES];
    
    //CENTRER SUR LE VENUE ET TRACK USER
    self.parisMap.showsUserLocation = YES;

    [self.parisMap addAnnotations:[self arrayFromJazzClubs]];
    
}


////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
#pragma mark - MKMapViewDelegate
////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
- (MKAnnotationView *)mapView:(MKMapView *)mapView viewForAnnotation:(id<MKAnnotation>)annotation
{
    //We want to display UserLocation as classic blue dot, not custom
    if([annotation isKindOfClass:[MKUserLocation class]]) {return nil;}
    
    MKAnnotationView *view = [[JIPMyPinView alloc] initWithAnnotation:annotation reuseIdentifier:@"AnnotationId"];
    
    view.canShowCallout = YES;
    
    UIButton *disclosureButton = [UIButton buttonWithType:UIButtonTypeDetailDisclosure];
    view.rightCalloutAccessoryView = disclosureButton;
    
    return view;
}

@end
