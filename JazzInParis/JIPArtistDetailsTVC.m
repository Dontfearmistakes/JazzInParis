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
#import "AFNetworking/AFHTTPRequestOperation.h"
#import "UIImage+Resize.h"

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

    // A) REQUEST POUR L'IMAGE ID
    /////////////////////////////
    NSURLRequest *requestImgId      = [NSURLRequest requestWithURL:[NSURL URLWithString:[NSString stringWithFormat:@"https://ajax.googleapis.com/ajax/services/search/images?v=1.0&q=%@", cleanArtistName]]];
    AFHTTPRequestOperation *operationForImgId = [[AFHTTPRequestOperation alloc] initWithRequest:requestImgId];
    operationForImgId.responseSerializer      = [AFJSONResponseSerializer serializer];
    
    [operationForImgId
    setCompletionBlockWithSuccess:^(AFHTTPRequestOperation *operation, id responseObject)
    {
        NSArray * results = [[responseObject objectForKey:@"responseData"] objectForKey:@"results"];
        
        //S'il y a bien des résultats
        if ([results count] > 0)
        {
            //On récupère l'id et la taille de la 1ère image
            #warning : Pkoi on refait responseData + Results ?? Pkoi on utilise pas results au dessus ??
            NSString *imageId = [[NSString alloc] initWithString:[[[[responseObject objectForKey:@"responseData"] objectForKey:@"results"] objectAtIndex:0] objectForKey:@"imageId"]];
            NSInteger imageWitdh = [[[NSString alloc] initWithString:[[[[responseObject objectForKey:@"responseData"] objectForKey:@"results"] objectAtIndex:0] objectForKey:@"width"]] integerValue];
            NSInteger imageHeight = [[[NSString alloc] initWithString:[[[[responseObject objectForKey:@"responseData"] objectForKey:@"results"] objectAtIndex:0] objectForKey:@"height"]] integerValue];
            
            //0) calcule ratio image reçue ex : 2/1
            float ratio = (float)imageHeight/(float)imageWitdh;
            
            
            //1) resize imageView
            _artistImageView.frame = CGRectMake(0, 0, 320, 320 * ratio);
            
            
            /////////////////////////////////////
            // B) REQUEST POUR L'IMAGE ELLE MEME
            /////////////////////////////////////
            NSURLRequest *requestImg = [NSURLRequest requestWithURL:[NSURL URLWithString:[NSString stringWithFormat:@"http://t1.gstatic.com/images?q=tbn:%@",imageId]]];
            AFHTTPRequestOperation *operationForImg = [[AFHTTPRequestOperation alloc] initWithRequest:requestImg];
            operationForImg.responseSerializer = [AFImageResponseSerializer serializer];
            [operationForImg
             
            setCompletionBlockWithSuccess:^(AFHTTPRequestOperation *operation, id responseObject)
            {
                //2) resize image (au max 320 x 200) selon ratio
                UIImage* resizedImg = [UIImage imageWithImage:responseObject scaledToSize:CGSizeMake(320.0, 320.0 * ratio)];
                
                _artistImageView.image = resizedImg;
                [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:NO];
            }
             
            failure:^(AFHTTPRequestOperation *operation, NSError *error)
            {
                NSLog(@"Image error: %@", error);
                [_artistImageView setImage:[UIImage imageNamed:@"errorImage"]];
            }];
            [operationForImg start];
            
        }
        
        //S'il n'y a pas de résultats
        else
        {
            [_artistImageView setImage:[UIImage imageNamed:@"errorImage"]];
            [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:NO];
        }
        
    }
    
    failure:^(AFHTTPRequestOperation *operation, NSError *error)
    {
        NSLog(@"Error: %@", error);
        [_artistImageView setImage:[UIImage imageNamed:@"imageError"]];
        [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:NO];

    }];
    
    [operationForImgId start];
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
