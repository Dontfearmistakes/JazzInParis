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
@synthesize searchArtistTextField = _searchArtistTextField;
@synthesize tapGesture           = _tapGesture;

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
    

    
    _tapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(didTapOnTableView:)];
    [self.tableView addGestureRecognizer:_tapGesture];
}

-(void) didTapOnTableView:(id) sender
{
    [_searchArtistTextField resignFirstResponder];
}




////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
#pragma mark - UITableViewDataSource
////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////


-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    //Enable -didTapOnTableView if tableView is empty
    if ([self.artistsDictionnaries count] != 0)
    {
        [self.tableView removeGestureRecognizer:_tapGesture];
    }
    else
    {
        [self.tableView addGestureRecognizer:_tapGesture];
    }
    
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
    
    [self performSegueWithIdentifier:@"ArtistDetails" sender:nil];

    [tableView deselectRowAtIndexPath:indexPath animated:YES];
}



-(void)prepareForSegue:(UIStoryboardSegue *)segue
                sender:(id)sender
{    
    if ([segue.identifier isEqualToString:@"ArtistDetails"])
    //SAVE ARTIST IN CONTEXT AND PASS IT TO artistDetailsVC.artist
    {
        JIPArtistDetailsTVC *artistDetailsTVC = [segue destinationViewController];
        artistDetailsTVC.artist = [JIPArtist artistWithDict:_artistDict
                                     inManagedObjectContext:[JIPManagedDocument sharedManagedDocument].managedObjectContext];
    }
}





////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
#pragma mark - UITextFieldDelegate
////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////


-(BOOL)textFieldShouldReturn:(UITextField *)textField
{
    NSString* searchTerm = [[textField.text stringByReplacingOccurrencesOfString:@" " withString:@"+"] stringByReplacingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
    
    // convert to a data object, using a lossy conversion to ASCII
    NSData *asciiEncoded = [searchTerm dataUsingEncoding:NSASCIIStringEncoding
                                            allowLossyConversion:YES];
    
    // take the data object and recreate a string using the lossy conversion
    NSString *searchTerm2 = [[NSString alloc] initWithData:asciiEncoded
                                            encoding:NSASCIIStringEncoding];

    [self searchSongkickArtistForSearchterm:searchTerm2];
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
                                                        [[NSOperationQueue mainQueue] addOperationWithBlock:^{
                                                            
                                                            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"No upcoming concert for this artist"
                                                                                                            message:@"Check the spelling"
                                                                                                           delegate:self
                                                                                                  cancelButtonTitle:@"OK"
                                                                                                  otherButtonTitles:nil];
                                                            [alert show];
                                                        }];
                                                    }
                                                }
                                                
                                                //2) Si pas de réponse : pas de réseau
                                                else
                                                {
                                                    [[NSOperationQueue mainQueue] addOperationWithBlock:^{
                                                    
                                                        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"No network connection"
                                                                                                        message:@"Check your internet conncetion"
                                                                                                       delegate:self
                                                                                              cancelButtonTitle:@"OK"
                                                                                              otherButtonTitles:nil];
                                                        [alert show];
                                                    }];
                                                }
                                                
                                                
                                                //3) Si une réponse json remplie alors on enregistre les résultats
                                                for (NSDictionary * artistDict in resultsDict[@"resultsPage"][@"results"][@"artist"]) {
                                                    
                                                    [self.artistsDictionnaries addObject:artistDict];
                                                }
                                                
                                                
                                                
                                                //4) Dans tous les cas, on recharge le TableView
                                                [[NSOperationQueue mainQueue] addOperationWithBlock:^{
                                                    [self.tableView reloadData];
                                                    [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:NO];
                                                }];
                                                
                                            }];
    [dataTask resume];
    [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:YES];
}


@end
