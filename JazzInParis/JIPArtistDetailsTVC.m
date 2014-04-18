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
    
    //Remove space between navBar and 1st cell
    if ([[UIDevice currentDevice].systemVersion floatValue] >= 7){
        self.tableView.contentInset = UIEdgeInsetsMake(-35, 0, 0, 0);
    }
    
    self.title = _artist.name;
    [JIPDesign applyBackgroundWallpaperInTableView:self.tableView];
}


- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [_favoriteSwitchView setOn:[_artist.favorite boolValue]];

    //fetching GoogleImage
    NSURLSession * session    = [NSURLSession sharedSession];
    NSString* cleanArtistName = [_artist.name stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
    NSURL *url = [NSURL URLWithString:[NSString stringWithFormat:@"https://ajax.googleapis.com/ajax/services/search/images?v=1.0&q=%@", cleanArtistName]];
    
    NSURLSessionDataTask *dataTask = [session dataTaskWithURL:url
                                            completionHandler:^(NSData *data, NSURLResponse *response, NSError *error) {
                                                
                                                NSError      *localError   = nil;
                                                NSDictionary *parsedObject = [NSJSONSerialization JSONObjectWithData:data options:0 error:&localError];
                                                NSString     * imageId     = parsedObject[@"responseData"][@"results"][0][@"imageId"];
                                                
                                                NSURL *imageUrl = [NSURL URLWithString:[NSString stringWithFormat:@"http://t1.gstatic.com/images?q=tbn:%@",imageId]];
                                                NSData *myData  = [NSData dataWithContentsOfURL:imageUrl];
                                                UIImage *googleImage  = [[UIImage alloc] initWithData:myData];

                                                [_artistImageView setImage:googleImage];
                                                                  
                                                [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:NO];
                                            }];
    [dataTask resume];
    [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:YES];
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
