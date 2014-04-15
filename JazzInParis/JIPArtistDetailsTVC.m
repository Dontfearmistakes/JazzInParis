//
//  JIPArtistDetailsTVC.m
//  JazzInParis
//
//  Created by Max on 12/04/14.
//  Copyright (c) 2014 Max. All rights reserved.
//

#import "JIPArtistDetailsTVC.h"
#import "JIPUpdateManager.h"
#import "YouTubeVC.h"
#import "WikipediaHelper.h"

@interface JIPArtistDetailsTVC ()

@end

@implementation JIPArtistDetailsTVC

@synthesize artist             = _artist;
@synthesize artistImageView    = _artistImageView;
@synthesize searchString       = _searchString;
@synthesize favoriteSwitchView = _favoriteSwitchView;


-(void)viewDidLoad
{
    [super viewDidLoad];
    
    self.title = _artist.name;
    [JIPDesign applyBackgroundWallpaperInTableView:self.tableView];
    
}


- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [_favoriteSwitchView setOn:[_artist.favorite boolValue]];
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



-(void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    _searchString = _artist.name;
    
    if ([segue.identifier isEqualToString:@"pushToYTBrowser"])
    {
        YouTubeVC * youTubeVC  = [segue destinationViewController];
        [youTubeVC setSearchString:_searchString];
    }
}



@end
