//
//  JIPArtistDetailsViewController.m
//  JazzInParis
//
//  Created by Max on 11/02/14.
//  Copyright (c) 2014 Max. All rights reserved.
//

#import "JIPArtistDetailsViewController.h"
#import "JIPManagedDocument.h"
#import "JIPUpdateManager.h"

@interface JIPArtistDetailsViewController ()

@property (strong, nonatomic) UITableView    * tableView;
@property (strong, nonatomic) NSMutableArray * videoNames;
@property (nonatomic)         CGFloat          switchButtonLineHeight;


@end

@implementation JIPArtistDetailsViewController


//////////////////////////////////////////////////////////////////////
-(NSUInteger)supportedInterfaceOrientations
{
    return UIInterfaceOrientationMaskAll;
}

////////////////////////////////////////////////////////////////////
-(void)viewDidLayoutSubviews
//called when bounds are redrawn
{
    CGFloat superViewWidth = self.view.bounds.size.width;
    CGFloat superViewHeight = self.view.bounds.size.height;
    
    self.tableView.frame = CGRectMake(0,0, superViewWidth, superViewHeight);

}

//////////////////////////////////////////////////////////////////////
- (void)viewDidLoad
{
    [super viewDidLoad];
    self.title = [NSString stringWithFormat:@"%@", self.artist.name];
    
    //1) setup the SwitchButton tableView
    self.tableView = [[UITableView alloc] initWithFrame:CGRectMake(0, 0, self.view.bounds.size.width, self.view.bounds.size.height)];
    self.tableView.dataSource = self;
    [self.view addSubview:self.tableView];
    
    self.activityIndicator = [[UIActivityIndicatorView alloc] initWithFrame:CGRectMake(self.view.bounds.size.width/2 - 22, self.view.bounds.size.height/2 -22, 44, 44)];
    self.activityIndicator.activityIndicatorViewStyle = UIActivityIndicatorViewStyleGray;
    self.activityIndicator.hidesWhenStopped = YES;
    [self.view addSubview:self.activityIndicator];
    
    
    //2) load youtube videos
    [self searchYoutubeVideosForTerm:self.artist.name];
    
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

-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [self.tableView reloadData];
}

/////////////////////////////////////////////////////////////////////////////
/////////////////////////////////////////////////////////////////////////////

-(void)searchYoutubeVideosForTerm:(NSString*)term
{
    [self.activityIndicator startAnimating];

    NSURLSession * session   = [NSURLSession sharedSession];
    term = [term stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
    NSURL* url = [NSURL URLWithString:[NSString stringWithFormat:@"http://gdata.youtube.com/feeds/api/videos?q=%@&max-results=50&alt=json", term]];
    
    NSURLSessionDataTask *dataTask = [session dataTaskWithURL:url
                                            completionHandler:^(NSData *data, NSURLResponse *response, NSError *error) {
                                                

                                                NSDictionary *resultsDict = [NSJSONSerialization JSONObjectWithData:data options:0 error:&error];
                                                
                                                self.videoNames = [[NSMutableArray alloc] init];
                                                for (int i=0; i<[resultsDict[@"feed"][@"entry"] count]; i++)
                                                {
                                                    [self.videoNames addObject:resultsDict[@"feed"][@"entry"][i][@"content"][@"$t"]];
                                                }
                                                
                                                //Recharge la TableView
                                                [[NSOperationQueue mainQueue] addOperationWithBlock:^{
                                                    [self.tableView reloadData];
                                                    [self.activityIndicator stopAnimating];

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
-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return (self.videoNames.count + 2);
}


//////////////////////////////////////////////////////
-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"cell"];
    if (!cell)
    {
        cell = [[UITableViewCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"cell"];
    }
    
    if (indexPath.row == 0)
    {

        //CELL GETS EVENT.NAME
        cell.textLabel.text =@"Add/Remove to Favorite";
        UISwitch *switchView = [[UISwitch alloc] initWithFrame:CGRectZero];
        cell.accessoryView = switchView;
        
        [switchView setOn:[self.artist.favorite boolValue] animated:NO];
        
        [switchView addTarget:self action:@selector(toggleFavorite:) forControlEvents:UIControlEventValueChanged];

    }
    else if (indexPath.row == 1)
    {
        cell.textLabel.text =@"YouTube Videos : ";
        cell.accessoryView = nil;
    }
    else
    {
        cell.textLabel.text = self.videoNames[indexPath.row - 2];
        cell.accessoryView = nil;
    }
    
    
    
    return cell;
}


////////////////////////////////////
- (void) toggleFavorite:(id)sender {
    UISwitch* switchControl = sender;

    [self.artist setFavorite:[NSNumber numberWithBool:switchControl.on]];

    
    [[JIPUpdateManager sharedUpdateManager] updateUpcomingEvents];
}

@end
