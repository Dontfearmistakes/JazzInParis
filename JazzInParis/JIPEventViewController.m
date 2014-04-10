//
//  JIPEventViewController.m
//  JazzInParis
//
//  Created by Max on 09/04/14.
//  Copyright (c) 2014 Max. All rights reserved.
//

#import "JIPEventViewController.h"
#import "JIPVenueMapVC.h"

@interface JIPEventViewController ()

@end

@implementation JIPEventViewController

@synthesize artistNameLabel    = _artistNameLabel;
@synthesize concertNameLabel   = _concertNameLabel;
@synthesize venueAdressTxtView = _venueAdressTxtView;
@synthesize checkMapButton     = _checkMapButton;
@synthesize event              = _event;


- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    _artistNameLabel   .text = _event.artist.name;
    _concertNameLabel  .text = _event.name;
    _venueAdressTxtView.text = _event.venue.street;
}



- (IBAction)checkMapClick:(id)sender
{
    [self performSegueWithIdentifier:@"VenueMapView" sender:nil];
}




-(void)prepareForSegue:(UIStoryboardSegue *)segue
                sender:(id)sender
{
    if ([segue.identifier isEqualToString:@"VenueMapView"])
    {
        JIPVenueMapVC *venueMapVC        = [segue destinationViewController];
                       venueMapVC.event  = _event;
    }
}

@end
