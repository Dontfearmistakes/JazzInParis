//
//  JIPSearchArtistsViewController.m
//  JazzInParis
//
//  Created by Max on 21/03/14.
//  Copyright (c) 2014 Max. All rights reserved.
//

#import "JIPSearchArtistsViewController.h"
#import "JIPArtistDetailsViewController.h"
#import "JIPManagedDocument.h"
#import "JIPArtist+Create.h"

const CGFloat JIPSearchArtistSearchBarHeightPercenatge = 0.09;

@interface JIPSearchArtistsViewController ()

@property (strong, nonatomic) UIActivityIndicatorView *activityIndicator;
@property (strong, nonatomic) UIView *contentSubview;
@property (nonatomic)         CGFloat searchBarHeight;
@property (strong, nonatomic) UITableView * downTableView;
@property (strong, nonatomic) UITextField * searchBar;
@property (strong, nonatomic) NSString * searchTerm;
@property (strong, nonatomic) NSMutableArray * artistsDictionnaries;

@end

//////////////////////////////////////////////////////////////////////
//////////////////////////////////////////////////////////////////////
@implementation JIPSearchArtistsViewController


//////////////////////////////////////////////////////////////////////
- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        self.title = @"Search Artists";
        self.tabBarItem.image = [UIImage imageNamed:@"Venue"];
    }
    return self;
}

//////////////////////////////////////////////////////////////////////
-(NSUInteger)supportedInterfaceOrientations
{
    return UIInterfaceOrientationMaskAll;
}


////////////////
-(void)loadView
{
    UIView *view = [[UIView alloc] init];
    view.backgroundColor = [UIColor greenColor];
    self.contentSubview = [[UIView alloc] init];
    self.contentSubview.backgroundColor = [UIColor orangeColor];
    [view addSubview:self.contentSubview];
    
    self.view = view;
}


/////////////////////////////
-(void)viewWillLayoutSubviews
{
    self.contentSubview.frame = CGRectMake(
                                           0,
                                           self.topLayoutGuide.length,
                                           CGRectGetWidth(self.view.frame),
                                           CGRectGetHeight(self.view.frame) - self.topLayoutGuide.length - self.bottomLayoutGuide.length
                                           );
}


////////////////////////////////
-(void)viewDidLayoutSubviews
//called when bounds are redrawn
{
    CGFloat superViewWidth  = self.contentSubview.bounds.size.width;
    CGFloat superViewHeight = self.contentSubview.bounds.size.height;
    
    self.searchBarHeight     = superViewHeight * JIPSearchArtistSearchBarHeightPercenatge;
    
    self.searchBar.frame     = CGRectMake(4, 4, superViewWidth-8, self.searchBarHeight);

    self.downTableView.frame = CGRectMake(0, (8 + self.searchBarHeight), superViewWidth, (superViewHeight - self.searchBarHeight));
}


//////////////////////////////////////////////////////////////////////
- (void)viewDidLoad
{
    [super viewDidLoad];
	
    //1) setup the search text field
    self.searchBar                        = [[UITextField alloc] initWithFrame:CGRectZero];
    self.searchBar.borderStyle            = UITextBorderStyleRoundedRect;
    self.searchBar.backgroundColor        = [UIColor whiteColor];
    self.searchBar.font                   = [UIFont systemFontOfSize:24];
    self.searchBar.delegate               = self;
    self.searchBar.placeholder            = @"Enter Artist's name";
    self.searchBar.clearButtonMode        = UITextFieldViewModeAlways;
    self.searchBar.autocapitalizationType = UITextAutocapitalizationTypeNone;
    [self.contentSubview addSubview: self.searchBar];

    //2) setup the tableView
    self.downTableView            = [[UITableView alloc] initWithFrame:CGRectZero];
    self.downTableView.dataSource = self;
    self.downTableView.delegate   = self;
    [self.contentSubview addSubview:self.downTableView];
    
    //3) Activity Indicator
    self.activityIndicator = [[UIActivityIndicatorView alloc] initWithFrame:CGRectMake(self.view.bounds.size.width/2 - 22, self.view.bounds.size.height/2 -22, 44, 44)];
    self.activityIndicator.activityIndicatorViewStyle = UIActivityIndicatorViewStyleGray;
    self.activityIndicator.hidesWhenStopped = YES;
    [self.view addSubview:self.activityIndicator];
}



//////////////////////////////////////////////////////////////////////
-(void)searchSongkickArtistForSearchterm:(NSString *)searchTerm
{


    //1) Create http request
    NSURLSession * session   = [NSURLSession sharedSession];
    NSString     * urlString = [NSString stringWithFormat:@"http://api.songkick.com/api/3.0/search/artists.json?query=%@&apikey=vUGmX4egJWykM1TA", searchTerm];
    NSURL        *url        = [[NSURL alloc]initWithString:urlString];
    
    NSURLSessionDataTask *dataTask = [session dataTaskWithURL:url
                                            completionHandler:^(NSData *data, NSURLResponse *response, NSError *error) {
                                                
                                                NSDictionary *resultsDict = [NSJSONSerialization JSONObjectWithData:data options:0 error:&error];
                                                
                                                self.artistsDictionnaries = [[NSMutableArray alloc] init];
                                                
                                                //1) Si on reçoit une réponse json mais vide : pas de concerts à venir
                                                if (resultsDict) {
                                                    if (!resultsDict[@"resultsPage"][@"results"][@"artist"]) {
                                                        
                                                        [self.artistsDictionnaries addObject:@{@"displayName": @"No upcoming concert for this artist"}];
                                                    }
                                                }
                                                
                                                //2) Si pas de réponse : pas de réseau
                                                else
                                                {
                                                    [self.artistsDictionnaries addObject:@{@"displayName": @"No network connection"}];
                                                }
                                                
                                                
                                                //3) Si une réponse json remplie alors on enregistre les résultats
                                                for (NSDictionary * artistDict in resultsDict[@"resultsPage"][@"results"][@"artist"]) {
                                                    
                                                    [self.artistsDictionnaries addObject:artistDict];
                                                }

                                                
                                                
                                                //4) Dans tous les cas, on recharge le TableView
                                                [[NSOperationQueue mainQueue] addOperationWithBlock:^{
                                                    [self.downTableView reloadData];
                                                    [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:NO];
                                                }];
                                                
                                            }];
    [dataTask resume];
    [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:YES];
}



//////////////////////////////////////
//fire up API search on Enter pressed
///////////////////////////////////////
-(BOOL)textFieldShouldReturn:(UITextField *)textField
{
    [textField resignFirstResponder];
    self.searchTerm = [textField.text stringByReplacingOccurrencesOfString:@" " withString:@"+"];
    [self searchSongkickArtistForSearchterm:self.searchTerm];
    return YES;
}



////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
#pragma mark - UITableViewDataSource
////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [self.artistsDictionnaries count];
}



//////////////////////////////////////////////////////
-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"artist"];
    if (!cell)
    {
        cell = [[UITableViewCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"artist"];
    }
    
    //CELL GETS EVENT.NAME
    cell.textLabel.text = self.artistsDictionnaries[indexPath.row][@"displayName"];
    
    return cell;
}


-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    JIPArtistDetailsViewController *artistDetailsVC = [[JIPArtistDetailsViewController alloc] init];
    NSMutableDictionary* artistDict = [[NSMutableDictionary alloc] init];
    [artistDict setValue:self.artistsDictionnaries[indexPath.row][@"displayName"] forKey:@"name"];
    [artistDict setValue:self.artistsDictionnaries[indexPath.row][@"id"]          forKey:@"id"];
    [artistDict setValue:self.artistsDictionnaries[indexPath.row][@"uri"]         forKey:@"songkickUri"];
    
    //FETCH ARTIST IN CONTEXT AND PASS IT TO artistDetailsVC.artist
    if ([self.artistsDictionnaries[0][@"displayName"]  isEqualToString: @"No upcoming concert for this artist"] == false &&
        [self.artistsDictionnaries[0][@"displayName"]  isEqualToString: @"No network connection"]               == false)
    {
        [[JIPManagedDocument sharedManagedDocument] performBlockWithDocument:^(JIPManagedDocument *managedDocument)
         {
             artistDetailsVC.artist = [JIPArtist artistWithDict:artistDict
                                         inManagedObjectContext:managedDocument.managedObjectContext];
             
             [self.navigationController pushViewController:artistDetailsVC animated:YES];
         }];
    }
    
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
}



@end
