//
//  JIPArtistDetailsViewController.m
//  JazzInParis
//
//  Created by Max on 11/02/14.
//  Copyright (c) 2014 Max. All rights reserved.
//

#import "JIPArtistDetailsViewController.h"

@interface JIPArtistDetailsViewController ()

@end

@implementation JIPArtistDetailsViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.
    self.title = [NSString stringWithFormat:@"%@", self.artist.name];
    
    ////////////////////////////////////////////////////////////////////////
    ////////////////////////////////////////////////////////////////////////
    
//    IDEAS
//    - Toggle button : Add/Remove to/from Favorites
//    - Wikipedia description
//    - Href to Songkick Artist page (showing upcoming concerts)
//          -->Later : create ArtistUpcomingEventsVC with Songkick API Call retrieving upComingConcerts only for this artist
//    - YouTube vidéos through API call
    
    ////////////////////////////////////////////////////////////////////////
    ////////////////////////////////////////////////////////////////////////
}

@end
