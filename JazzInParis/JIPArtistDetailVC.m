//
//  JIPArtistDetailVC.m
//  JazzInParis
//
//  Created by Max on 11/04/14.
//  Copyright (c) 2014 Max. All rights reserved.
//

#import "JIPArtistDetailVC.h"
#import "JIPUpdateManager.h"
#import "YouTubeVC.h"

@interface JIPArtistDetailVC ()

@end

@implementation JIPArtistDetailVC

@synthesize artist             = _artist;
@synthesize searchString       = _searchString;
@synthesize favoriteSwitchView = _favoriteSwitchView;

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    [_favoriteSwitchView setOn:[_artist.favorite boolValue]];
}


-(void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    _searchString = _artist.name;
    
    
    
    if ([segue.identifier isEqualToString:@"pushToYTBrowser"])
    {
        
        YouTubeVC * youTubeVC  = [segue destinationViewController];
        youTubeVC.searchString = _searchString;
    }
}



- (IBAction)toggleFavorite:(id)sender {
    //1) On update l'attribut favorite
    [self.artist setFavorite:[NSNumber numberWithBool:[(UISwitch*)sender isOn]]];
    
    //2) On télecharge ou efface les Events liés à cet artiste
    if ([(UISwitch*)sender isOn])
    {
        [[JIPUpdateManager sharedUpdateManager] updateUpcomingEventsForFavoriteArtist:self.artist];
    }
    else
    {
        [[JIPUpdateManager sharedUpdateManager] clearArtistEvents:self.artist];
    }
}


@end
