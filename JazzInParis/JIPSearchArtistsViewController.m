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

@interface JIPSearchArtistsViewController ()


@property (strong, nonatomic) UITableView * downTableView;
@property (strong, nonatomic) NSString * searchTerm;
@property (strong, nonatomic) NSMutableArray * artistsDictionnaries;

@end

@implementation JIPSearchArtistsViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        self.title = @"Search Artists";
        self.tabBarItem.image = [UIImage imageNamed:@"Venue"];
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	
    //setup the search text field
    UITextField * fldSearch = [[UITextField alloc] initWithFrame:CGRectMake(4,70,312,35)];
    fldSearch.borderStyle = UITextBorderStyleRoundedRect;
    fldSearch.backgroundColor = [UIColor whiteColor];
    fldSearch.font = [UIFont systemFontOfSize:24];
    fldSearch.delegate = self;
    fldSearch.placeholder = @"Enter Artist";
    fldSearch.clearButtonMode = UITextFieldViewModeAlways;
    fldSearch.autocapitalizationType = UITextAutocapitalizationTypeNone;
    [self.view addSubview: fldSearch];

    self.downTableView = [[UITableView alloc] initWithFrame:CGRectMake(0,
                                                                      105,
                                                                      self.view.bounds.size.width,
                                                                      self.view.bounds.size.height - fldSearch.bounds.size.height)];
    self.downTableView.dataSource = self;
    self.downTableView.delegate = self;
    [self.view addSubview:self.downTableView];

}

-(void)searchSongkickArtistForSearchterm:(NSString *)searchTerm
{

    //http://api.songkick.com/api/3.0/search/artists.json?query={search_query}&apikey={your_api_key}

    //1) Create http request
    NSURLSession * session   = [NSURLSession sharedSession];
    NSString     * urlString = [NSString stringWithFormat:@"http://api.songkick.com/api/3.0/search/artists.json?query=%@&apikey=vUGmX4egJWykM1TA", searchTerm];
    NSURL        *url        = [[NSURL alloc]initWithString:urlString];
    NSLog(@"url : %@", url);
    
    NSURLSessionDataTask *dataTask = [session dataTaskWithURL:url
                                            completionHandler:^(NSData *data, NSURLResponse *response, NSError *error) {
                                                
                                                NSDictionary *resultsDict = [NSJSONSerialization JSONObjectWithData:data options:0 error:&error];
                                                NSLog(@"class of serialized results : %@", [resultsDict[@"resultsPage"][@"results"][@"artist"][0] class]);
                                                NSLog(@"data in resultsDict of class : %@", resultsDict[@"resultsPage"][@"results"][@"artist"]);
                                                
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
                                                }];
                                                
                                            }];
    [dataTask resume];
}


////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
#pragma mark - UITableViewDataSource
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
    [[JIPManagedDocument sharedManagedDocument] performBlockWithDocument:^(JIPManagedDocument *managedDocument)
     {
         artistDetailsVC.artist = [JIPArtist artistWithDict:artistDict
                                     inManagedObjectContext:managedDocument.managedObjectContext];
     }];
    
    [self.navigationController pushViewController:artistDetailsVC animated:YES];
}

//////////////////////////////////////
//fire up API search on Enter pressed
///////////////////////////////////////
-(BOOL)textFieldShouldReturn:(UITextField *)textField
{
    [textField resignFirstResponder];
    self.searchTerm = [textField.text stringByReplacingOccurrencesOfString:@" " withString:@"+"];
    [self searchSongkickArtistForSearchterm:self.searchTerm];
    [self.downTableView reloadData];
    return YES;
}

@end
