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
#import "AFNetworking/AFHTTPRequestOperation.h"

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
    NSString* cleanArtistName = [_artist.name stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];

    
    NSURLRequest *request = [NSURLRequest requestWithURL:[NSURL URLWithString:[NSString stringWithFormat:@"https://ajax.googleapis.com/ajax/services/search/images?v=1.0&q=%@", cleanArtistName]]];
    AFHTTPRequestOperation *op = [[AFHTTPRequestOperation alloc] initWithRequest:request];
    op.responseSerializer = [AFJSONResponseSerializer serializer];
    [op setCompletionBlockWithSuccess:^(AFHTTPRequestOperation *operation, id responseObject) {
        NSLog(@"JSON: %@", responseObject);
        NSArray * results = [[responseObject objectForKey:@"responseData"] objectForKey:@"results"];
       //
        
        if ([results count] > 0) {
            NSString *imageId = [[NSString alloc] initWithString:[[[[responseObject objectForKey:@"responseData"] objectForKey:@"results"] objectAtIndex:0] objectForKey:@"imageId"]];
            NSInteger imageWitdh = [[[NSString alloc] initWithString:[[[[responseObject objectForKey:@"responseData"] objectForKey:@"results"] objectAtIndex:0] objectForKey:@"width"]] integerValue];
            NSInteger imageHeight = [[[NSString alloc] initWithString:[[[[responseObject objectForKey:@"responseData"] objectForKey:@"results"] objectAtIndex:0] objectForKey:@"height"]] integerValue];
            
            //NSLog(@"IMG ID : [%@] [%@]",imageHeight, imageWitdh);
            
            NSURLRequest *requestImg = [NSURLRequest requestWithURL:[NSURL URLWithString:[NSString stringWithFormat:@"http://t1.gstatic.com/images?q=tbn:%@",imageId]]];
            
            
            AFHTTPRequestOperation *requestOperation = [[AFHTTPRequestOperation alloc] initWithRequest:requestImg];
            requestOperation.responseSerializer = [AFImageResponseSerializer serializer];
            [requestOperation setCompletionBlockWithSuccess:^(AFHTTPRequestOperation *operation, id responseObject) {
                NSLog(@"Response: %@", responseObject);
                _artistImageView.image = responseObject;
                [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:NO];
                
                
            } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
                NSLog(@"Image error: %@", error);
            }];
            [requestOperation start];
        }
        else
            [_artistImageView setImage:[UIImage imageNamed:@"imageError"]];
            // set image error
        
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        NSLog(@"Error: %@", error);
        // set image error

    }];
    [op start];
    
    
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
