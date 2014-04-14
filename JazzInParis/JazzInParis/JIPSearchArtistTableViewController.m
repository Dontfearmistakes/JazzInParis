//
//  JIPSearchArtistTableViewController.m
//  JazzInParis
//
//  Created by Max on 04/04/14.
//  Copyright (c) 2014 Max. All rights reserved.
//
#import "JIPSearchArtistTableViewController.h"
#import "JIPArtistDetailsTVC.h"
#import "JIPManagedDocument.h"
#import "JIPArtist+Create.h"
#import "ECSlidingViewController.h"
#import "SideMenuViewController.h"
#import "JIPSearchArtistNameCell.h"


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



- (void)viewDidLoad
{
    [super viewDidLoad];
    
    //Page qui appraît au lancement de l'appli = rattacher le side menu à la page de lancement
    if (![self.slidingViewController.underLeftViewController isKindOfClass:[SideMenuViewController class]])
    {
        self.slidingViewController.underLeftViewController  = [self.storyboard instantiateViewControllerWithIdentifier:@"Menu"];
    }
    
    [JIPDesign applyBackgroundWallpaperInTableView:self.tableView];
}



//called whenever a character is put in searchBar
//here we want want to keep miles.png as a background image when searchBar is used
- (void)searchDisplayControllerDidBeginSearch:(UISearchDisplayController *)controller
{
    controller.searchResultsTableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    controller.searchResultsTableView.backgroundColor = [UIColor clearColor];
    [JIPDesign applyBackgroundWallpaperInTableView:controller.searchResultsTableView];
}


- (BOOL)searchDisplayController:(UISearchDisplayController *)controller shouldReloadTableForSearchString:(NSString *)searchString
{
    //FIXME: garder la même couleur pour pas que le user pense que la search est lancée
    [controller.searchResultsTableView setBackgroundColor:[UIColor colorWithWhite:0.0 alpha:0.8]]; //on pourrait aussi mettre UIColor clearColor
    [controller.searchResultsTableView setRowHeight:800];
    [controller.searchResultsTableView setScrollEnabled:NO];
    return NO;
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



-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    JIPSearchArtistNameCell *cell = [self.tableView dequeueReusableCellWithIdentifier:@"artist"];
    
    //CELL GETS EVENT.NAME
    cell.artistNameLabel.text = self.artistsDictionnaries[indexPath.row][@"displayName"];
    
    return cell;
}



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
    //SAVE ARTIST IN CONTEXT AND PASS IT TO artistDetailsVC.artist
    {
        JIPArtistDetailsTVC *artistDetailsTVC = [segue destinationViewController];
        artistDetailsTVC.artist = [JIPArtist artistWithDict:_artistDict
                                    inManagedObjectContext:_managedDocument.managedObjectContext];
    }
}





////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
#pragma mark - UITextFieldDelegate
////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////


-(BOOL)textFieldShouldReturn:(UITextField *)textField
{
    NSString* searchTerm = [textField.text stringByReplacingOccurrencesOfString:@" " withString:@"+"];
    #warning : BUG if search term contains accents
    [self searchSongkickArtistForSearchterm:searchTerm];
    [textField resignFirstResponder];
    
    return YES;
}

////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
#pragma mark - UISearchBarDelegate
////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

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
                                                if (resultsDict)
                                                {
                                                    if (!resultsDict[@"resultsPage"][@"results"][@"artist"])
                                                    {
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
