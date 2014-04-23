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
@synthesize ratio              = _ratio;



-(void)viewDidLoad
{
    [super viewDidLoad];
    
    //Remove space between navBar and 1st cell
    if ([[UIDevice currentDevice].systemVersion floatValue] >= 7){
        self.tableView.contentInset = UIEdgeInsetsMake(-35, 0, 0, 0);
    }
    
    self.title = _artist.name;
    [JIPDesign applyBackgroundWallpaperInTableView:self.tableView];

    [_favoriteSwitchView setOn:[_artist.favorite boolValue]];
    NSString* nsutf8ArtistName = [[_artist.name stringByReplacingOccurrencesOfString:@" " withString:@"_"] lowercaseString];
    // convert to a data object, using a lossy conversion to ASCII
    NSData *asciiEncoded = [nsutf8ArtistName dataUsingEncoding:NSASCIIStringEncoding
                             allowLossyConversion:YES];
    
    // take the data object and recreate a string using the lossy conversion
    NSString *cleanArtistName = [[NSString alloc] initWithData:asciiEncoded
                                            encoding:NSASCIIStringEncoding];
    
    

    /////////////////////////////////////
    // A) REQUEST POUR L'IMAGE ID
    /////////////////////////////////////
    NSURLRequest            *requestImgId                        = [NSURLRequest requestWithURL:[NSURL URLWithString:[NSString stringWithFormat:@"https://www.googleapis.com/freebase/v1/topic/en/%@?filter=/common/topic/image&limit=1", cleanArtistName]]];
    AFHTTPRequestOperation *operationForImgId                    = [[AFHTTPRequestOperation alloc] initWithRequest:requestImgId];
                            operationForImgId.responseSerializer = [AFJSONResponseSerializer serializer];
    
    [operationForImgId
    setCompletionBlockWithSuccess:^(AFHTTPRequestOperation *operation, id responseObject)
    {
    
        //S'il y a bien des résultats
        if ([[[responseObject objectForKey:@"property"] objectForKey:@"/common/topic/image" ] objectForKey:@"values"] > 0)
        {
            //On récupère l'id et la taille de la 1ère image
            NSString *imageId = [[NSString alloc]  initWithString:[[[[[responseObject objectForKey:@"property"] objectForKey:@"/common/topic/image" ] objectForKey:@"values"] objectAtIndex:0] objectForKey:@"id"]];
            
            
            /////////////////////////////////////
            // B) REQUEST POUR L'IMAGE ELLE MEME
            /////////////////////////////////////
            NSURLRequest            *requestImg                         = [NSURLRequest requestWithURL:[NSURL URLWithString:[NSString stringWithFormat:@"https://usercontent.googleapis.com/freebase/v1/image%@?maxwidth=2020&maxheight=2020&minwidth=1020&minheight=2020",imageId]]];
            AFHTTPRequestOperation *operationForImg                     = [[AFHTTPRequestOperation alloc] initWithRequest:requestImg];
                                    operationForImg.responseSerializer  = [AFImageResponseSerializer serializer];
            [operationForImg
             
            setCompletionBlockWithSuccess:^(AFHTTPRequestOperation *operation, id responseObject)
            {
                UIImage * responseImg = responseObject;
                _artistImageView.image = responseImg;
                
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
        [_artistImageView setImage:[UIImage imageNamed:@"errorImage"]];
        [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:NO];

    }];
    
    [operationForImgId start];
    [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:YES];
    [self performSelector:@selector(noImgAvalaible) withObject:nil afterDelay:1.5];
}


-(void)noImgAvalaible
{
    if (!_artistImageView.image)
        [_artistImageView setImage:[UIImage imageNamed:@"errorImage"]];
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
