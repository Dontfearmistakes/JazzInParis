//
//  JIPFavoriteArtistsTableViewController.m
//  JazzInParis
//
//  Created by Max on 07/04/14.
//  Copyright (c) 2014 Max. All rights reserved.
//

#import <CoreData/CoreData.h>
#import "JIPManagedDocument.h"
#import "JIPFavoriteArtistsTableViewController.h"
#import "ECSlidingViewController.h"
#import "SideMenuViewController.h"
#import "JIPArtist.h"
#import "JIPUpdateManager.h"
#import "JIPArtistDetailVC.h"


@interface JIPFavoriteArtistsTableViewController ()

@end

@implementation JIPFavoriteArtistsTableViewController

@synthesize searchBar               = _searchBar;
@synthesize isFiltered              = _isFiltered;
@synthesize filteredFavoriteArtists = _filteredFavoriteArtists;
@synthesize favoriteArtists         = _favoriteArtists;
@synthesize artist                  = _artist;
@synthesize editBarButton           = _editBarButton;

////////////////////////////////////////////////
//method for every rootVC / implements side menu
////////////////////////////////////////////////
- (IBAction)revealMenu:(id)sender
{
    [self.slidingViewController anchorTopViewTo:ECRight];
}


///////////////////
- (void)viewDidLoad
{
    [super viewDidLoad];
    
    [JIPDesign applyBackgroundWallpaperInTableView:self.tableView];
}



////////////////////////////////////
-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    [self fetchfavoriteArtist];
    
    if ([_favoriteArtists count] == 0)
    {
        [self.searchBar setHidden:YES];
        [self.navigationItem.rightBarButtonItem setEnabled:NO];

        [self buttonIfNoFavoritesYet];
    }
    
    [self.tableView reloadData];
}

-(void)buttonIfNoFavoritesYet
{
    UILabel *label = [JIPDesign emptyTableViewLabelWithString:@"No favorite artists yet..."];
    [self.view addSubview:label];
    
    UIButton *button = [JIPDesign emptyTableViewButtonWithString:@"Add more artists"];
    [button addTarget:self
               action:@selector(segueToSearchArtists)
     forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:button];
}

-(void)segueToSearchArtists
{
    [self performSegueWithIdentifier:@"searchArtists" sender:nil];
}



-(void)fetchfavoriteArtist
{
    NSFetchRequest *request = [NSFetchRequest fetchRequestWithEntityName:@"JIPArtist"];
    request.sortDescriptors = @[[NSSortDescriptor sortDescriptorWithKey:@"name" ascending:YES]];
    request.predicate       = [NSPredicate predicateWithFormat:@"favorite == %@", @YES];
    
    NSError *error = nil;
    _favoriteArtists = [[[JIPManagedDocument sharedManagedDocument].managedObjectContext executeFetchRequest:request error:&error] mutableCopy];
}




////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
#pragma mark - UITableViewDataSource
////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    //Here, the table view passed as an argument can be either the regular tableView (appearing the 1st time the view loads)
    //                                                  or the self.searchDisplayController.searchResultsTableView (if the searchBar is used)
    if (tableView == self.searchDisplayController.searchResultsTableView)
    {
        return [_filteredFavoriteArtists count];
    }
    else
    {

        return [_favoriteArtists count];
    }
}




- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    
    //ICI self.tableView est TOUJOURS UITableView et non pas UISearchResultsTableView (c'est pour ça qu'on l'utilise pour chopper là cellule)
    //Alors que le tableView passé en argument est l'un ou l'autre (selon que les résultats affichés sont filtrés oun non)
    UITableViewCell *artistNameCell = [self.tableView dequeueReusableCellWithIdentifier:@"FavoriteArtistCell"];
    
    if (tableView == self.searchDisplayController.searchResultsTableView)
    {
        _artist = _filteredFavoriteArtists[indexPath.row];
    }
    else
    {
        _artist  = _favoriteArtists[indexPath.row];
    }
    
    artistNameCell.textLabel.text      = _artist.name;

    return artistNameCell;
}



-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    _artist = _favoriteArtists[indexPath.row];
    [self performSegueWithIdentifier:@"artistDetails" sender:nil];
}
-(void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([segue.identifier isEqualToString:@"artistDetails"])
    {
        JIPArtistDetailVC * artistDetailsVC  = [segue destinationViewController];
        artistDetailsVC.artist = _artist;
    }
}


- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Return NO if you do not want the specified item to be editable.
    return YES;
}



- (IBAction)editBarButtonClick:(id)sender {
    
    if ([self isEditing])
    {
        // If the tableView is already in edit mode, turn it off.
        // Also change the title of the button to reflect the intended verb (‘Edit’, in this case).
        [self setEditing:NO animated:YES];
        [_editBarButton setTitle:@"Edit"];
        
        if ([_favoriteArtists count] == 0)
        {
            [self.searchBar setHidden:YES];
            [self.navigationItem.rightBarButtonItem setEnabled:NO];
            [self buttonIfNoFavoritesYet];
        }
    }
    else
    {
        [_editBarButton setTitle:@"Done"];
        // Turn on edit mode
        [self setEditing:YES animated:YES];
    }
}



// Override to support editing the table view.
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (editingStyle == UITableViewCellEditingStyleDelete)
    {
        // Delete the row from the data source
        [self removeFromFavorites:indexPath];
        [_favoriteArtists removeObject:_favoriteArtists[indexPath.row]];
        [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
    }

}




- (void)removeFromFavorites:(NSIndexPath *)ip
{
    JIPArtist * artist = _favoriteArtists[ip.row];
    
    //1) On update l'attribut favorite
    [artist setFavorite:[NSNumber numberWithBool:NO]];
    
    //2) On efface les Events liés à cet artiste
    [[JIPUpdateManager sharedUpdateManager] clearArtistEvents:artist];
}




- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
        return 60;
}

////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
#pragma mark - UISearchBarDelegate
////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////




////////////////////////////////////////////////////////////
- (void)searchBarSearchButtonClicked:(UISearchBar *)searchBar
{
    #warning : this method is never called ...
    [self.searchDisplayController setActive:NO animated:YES];
}


- (BOOL)searchDisplayController:(UISearchDisplayController *)controller shouldReloadTableForSearchString:(NSString *)searchString
{
    [self filterContentForSearchText:searchString
                               scope:[[self.searchDisplayController.searchBar scopeButtonTitles] objectAtIndex:[self.searchDisplayController.searchBar selectedScopeButtonIndex]]];
    return YES;
}


////////////////////////////////////////////////////////
- (void)filterContentForSearchText:(NSString*)searchText
                             scope:(NSString*)scope
{
    NSPredicate *resultPredicate = [NSPredicate predicateWithFormat:@"name contains[cd] %@", searchText];
    
   _filteredFavoriteArtists = [_favoriteArtists filteredArrayUsingPredicate:resultPredicate];
}



////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
#pragma mark - UISearchDisplayDelegate
////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

//called whenever a character is put in searchBar
- (void)searchDisplayControllerDidBeginSearch:(UISearchDisplayController *)controller
{
    controller.searchResultsTableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    controller.searchResultsTableView.backgroundColor = [UIColor clearColor];
    //here we want want to keep miles.png as a background image when searchBar is used
    [JIPDesign applyBackgroundWallpaperInTableView:controller.searchResultsTableView];
    
}

@end
