//
//  JIPSearchArtistTableViewController.m
//  JazzInParis
//
//  Created by Max on 04/04/14.
//  Copyright (c) 2014 Max. All rights reserved.
//
#import "JIPSearchArtistTableViewController.h"
#import "JIPArtistDetailsViewController.h"
#import "JIPManagedDocument.h"
#import "JIPArtist+Create.h"
#import "ECSlidingViewController.h"
#import "SideMenuViewController.h"


@interface JIPSearchArtistTableViewController ()

@property (strong, nonatomic) NSMutableArray * artistsDictionnaries;

@end




@implementation JIPSearchArtistTableViewController

////////////////////////////////////////////
- (id)initWithStyle:(UITableViewStyle)style
{
    self = [super initWithStyle:style];
    if (self) {
        // Custom initialization
    }
    return self;
}


/////////////////////////////////
- (IBAction)revealMenu:(id)sender
{
    [self.slidingViewController anchorTopViewTo:ECRight];
}

////////////////////
- (void)viewDidLoad
{
    [super viewDidLoad];
    if (![self.slidingViewController.underLeftViewController isKindOfClass:[SideMenuViewController class]]) {
        self.slidingViewController.underLeftViewController  = [self.storyboard instantiateViewControllerWithIdentifier:@"Menu"];
    }
}


////////////////////////////////////////////////////////////////
-(void)searchSongkickArtistForSearchterm:(NSString *)searchTerm
{
    
    //1) Create http request
    NSURLSession * session   = [NSURLSession sharedSession];
    NSString     * urlString = [NSString stringWithFormat:@"http://api.songkick.com/api/3.0/search/artists.json?query=%@&apikey=vUGmX4egJWykM1TA", searchTerm];
    NSURL        * url       = [NSURL URLWithString:urlString];
    
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
                                                    [self.tableView reloadData];
                                                }];
                                                
                                            }];
    [dataTask resume];
}






////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
#pragma mark - UITableViewDataSource
////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////


///////////////////////////////////////////////////////////////////////////////////////
-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [self.artistsDictionnaries count];
}

//////////////////////////////////////////////////////////////////////////////////////////////////////
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







////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
#pragma mark - UISearchBarDelegate
////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////


////////////////////////////////////////////////////////////////////
// Click on top left bar button --> searBar becomes first responder
- (IBAction)searchClickAction:(id)sender
{
    #warning explain scrollRectToVisible
    [self.tableView scrollRectToVisible:CGRectMake(0, 0, 1, 1) animated:NO];
    [self.searchBar becomeFirstResponder];
}


//////////////////////////////////////////////////////////
-(void)searchBarTextDidEndEditing:(UISearchBar *)searchBar
{
    [self.searchBar resignFirstResponder];
}


////////////////////////////////////////////////////////////
- (void)searchBarSearchButtonClicked:(UISearchBar *)searchBar
{
    NSString* searchTerm = [self.searchDisplayController.searchBar.text stringByReplacingOccurrencesOfString:@" " withString:@"+"];
    [self searchSongkickArtistForSearchterm:searchTerm];
}


@end
