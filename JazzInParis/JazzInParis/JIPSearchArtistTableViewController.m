//
//  JIPSearchArtistTableViewController.m
//  JazzInParis
//
//  Created by Max on 04/04/14.
//  Copyright (c) 2014 Max. All rights reserved.
//
#import "JIPSearchArtistTableViewController.h"
#import "JIPArtistDetailTableViewController.h"
#import "JIPManagedDocument.h"
#import "JIPArtist+Create.h"
#import "ECSlidingViewController.h"
#import "SideMenuViewController.h"


@interface JIPSearchArtistTableViewController ()

@property (strong, nonatomic) NSMutableArray * artistsDictionnaries;
@property (strong, nonatomic) NSMutableDictionary * artistDict;
@property (strong, nonatomic) JIPManagedDocument * managedDocument;

@end




@implementation JIPSearchArtistTableViewController

@synthesize artistDict = _artistDict;
@synthesize managedDocument = _managedDocument;



////////////////////////////////////////////////
//method for every rootVC / implements side menu
////////////////////////////////////////////////
- (IBAction)revealMenu:(id)sender
{
    [self.slidingViewController anchorTopViewTo:ECRight];
}

////////////////////
- (void)viewDidLoad
{
    [super viewDidLoad];
    
    //Page qui appraît au lancement de l'appli = rattacher le side menu à la page de lancement
    if (![self.slidingViewController.underLeftViewController isKindOfClass:[SideMenuViewController class]])
    {
        self.slidingViewController.underLeftViewController  = [self.storyboard instantiateViewControllerWithIdentifier:@"Menu"];
    }
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


//////////////////////////////////////////////////////////////////////////////////////////
-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    _artistDict = [[NSMutableDictionary alloc]init];

    _artistDict[@"name"]        = self.artistsDictionnaries[indexPath.row][@"displayName"]  ;
    _artistDict[@"id"]          = self.artistsDictionnaries[indexPath.row][@"id"]           ;
    _artistDict[@"songkickUri"] = self.artistsDictionnaries[indexPath.row][@"uri"]          ;
    
    
    if ([self.artistsDictionnaries[0][@"displayName"]  isEqualToString: @"No upcoming concert for this artist"] == false
        &&
        [self.artistsDictionnaries[0][@"displayName"]  isEqualToString: @"No network connection"]               == false)
    {
        [[JIPManagedDocument sharedManagedDocument] performBlockWithDocument:^(JIPManagedDocument *managedDocument)
         {
             _managedDocument = managedDocument;
             [self performSegueWithIdentifier:@"ArtistDetails" sender:nil];
         }];
    }
    else
    //DEBUG
    {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Pas entré dans le segue"
                                                        message:@"Dee dee doo doo."
                                                       delegate:self
                                              cancelButtonTitle:@"OK" 
                                              otherButtonTitles:nil];
        [alert show];
    }
    
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
}




/////////////////////////////////////////////////
-(void)prepareForSegue:(UIStoryboardSegue *)segue
                sender:(id)sender
{    
    if ([segue.identifier isEqualToString:@"ArtistDetails"])
    //FETCH ARTIST IN CONTEXT AND PASS IT TO artistDetailsVC.artist
    {
        JIPArtistDetailTableViewController *artistDetailsVC = [segue destinationViewController];
        artistDetailsVC.artist = [JIPArtist artistWithDict:_artistDict
                                    inManagedObjectContext:_managedDocument.managedObjectContext];
    }
}





////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
#pragma mark - UISearchBarDelegate
////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////


///////////////////////////////////////////////////////////////////////////
// Click on top left bar button (loupe) --> searBar becomes first responder
- (IBAction)searchClickAction:(id)sender
{
    [self.tableView scrollRectToVisible:CGRectMake(0, 0, 1, 1) animated:NO];
    [self.searchBar becomeFirstResponder];
}


////////////////////////////////////////////////////////////
- (void)searchBarSearchButtonClicked:(UISearchBar *)searchBar
{
    NSString* searchTerm = [self.searchDisplayController.searchBar.text stringByReplacingOccurrencesOfString:@" " withString:@"+"];
    [self searchSongkickArtistForSearchterm:searchTerm];
    [self.searchDisplayController setActive:NO animated:YES];
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


@end
