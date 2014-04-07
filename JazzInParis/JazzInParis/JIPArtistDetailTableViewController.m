//
//  JIPArtistDetailTableViewController.m
//  JazzInParis
//
//  Created by Max on 06/04/14.
//  Copyright (c) 2014 Max. All rights reserved.
//

#import "JIPArtistDetailTableViewController.h"
#import "JIPArtistNameCell.h"
#import "JIPYouTubeVideoCell.h"
#import "JIPUpdateManager.h"

@interface JIPArtistDetailTableViewController ()

@end


@implementation JIPArtistDetailTableViewController

@synthesize videoNames        = _videoNames;
@synthesize artist            = _artist;
@synthesize artistNameNavItem = _artistNameNavItem;


////////////////////////////////////////////////////////////////////
#warning how to keep sizes when upon rotate ??
////////////////////////////////////////////////////////////////////
//-(void)viewDidLayoutSubviews
//called when bounds are redrawn
//{
//    CGFloat superViewWidth = self.view.bounds.size.width;
//    CGFloat superViewHeight = self.view.bounds.size.height;
//    
//    self.tableView.frame = CGRectMake(0,0, superViewWidth, superViewHeight);
//    
//}


/////////////////////
- (void)viewDidLoad
{
    [super viewDidLoad];
    
    //Set NavItem title
    _artistNameNavItem.title = self.artist.name;
    
    _videoNames = [[NSMutableArray alloc] init];
    
    //Fire YouTube Call
    [self searchYoutubeVideosForTerm:self.artist.name];
}


/////////////////////////////////////////////////
-(void)searchYoutubeVideosForTerm:(NSString*)term
{
    
    NSURLSession * session   = [NSURLSession sharedSession];
    term = [term stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
    NSURL* url = [NSURL URLWithString:[NSString stringWithFormat:@"http://gdata.youtube.com/feeds/api/videos?q=%@&max-results=50&alt=json", term]];
    
    NSURLSessionDataTask *dataTask = [session dataTaskWithURL:url
                                            completionHandler:^(NSData *data, NSURLResponse *response, NSError *error) {
                                                
                                                
                                                NSDictionary *resultsDict = [NSJSONSerialization JSONObjectWithData:data options:0 error:&error];
                                                
                                                for (int i=0; i<[resultsDict[@"feed"][@"entry"] count]; i++)
                                                {
                                                    [_videoNames addObject:resultsDict[@"feed"][@"entry"][i][@"content"][@"$t"]];
                                                }
                                                
                                                //Recharge la TableView
                                                [[NSOperationQueue mainQueue] addOperationWithBlock:^{
                                                    [self.tableView reloadData];
                                                    
                                                }];
                                                
                                                if (error)
                                                {
                                                    [[[UIAlertView alloc] initWithTitle:@"Error"
                                                                                message:[error localizedDescription]
                                                                               delegate:nil
                                                                      cancelButtonTitle:@"Close"
                                                                      otherButtonTitles: nil] show];
                                                    return;
                                                }
                                                
                                            }];
    [dataTask resume];
}


////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
#pragma mark - UITableViewDataSource
////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}


/////////////////////////////////////////////////////////////////////////////////////////
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return (_videoNames.count + 1);
}

/////////////////////////////////////////////////////////////////////////////////////////////////////
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    JIPArtistNameCell   *nameCell;
    JIPYouTubeVideoCell *youTubeCell ;
    
    if (indexPath.row == 0)
    {
       nameCell = [tableView dequeueReusableCellWithIdentifier:@"ArtistNameCell" forIndexPath:indexPath];
       nameCell.artist = self.artist;
        
      #warning : pourquoi pas d'alloc init ?  Et si le dequeueReusableCellWithIdentifier ne renvoie rien ?
      [[nameCell switchFavorite] setOn:[self.artist.favorite boolValue]];
       return nameCell;
    }
    else
    {
        youTubeCell = [tableView dequeueReusableCellWithIdentifier:@"YouTubeVideo" forIndexPath:indexPath];
        return youTubeCell;
    }
    
}



///////////////////////////////////////////////////////////////////////////////////////////////
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.row == 0)
    {
        return 100;
    }
    else
    {
        return 135;
    }
}


@end
