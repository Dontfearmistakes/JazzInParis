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
#import "JIPArtistNameCell.h"
#import "JIPArtist.h"


@interface JIPFavoriteArtistsTableViewController ()

@end

@implementation JIPFavoriteArtistsTableViewController

@synthesize searchBar               = _searchBar;
@synthesize isFiltered              = _isFiltered;
@synthesize filteredFavoriteArtists = _filteredFavoriteArtists;
@synthesize favoriteArtists         = _favoriteArtists;
@synthesize artist                  = _artist;

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
    
    
    NSFetchRequest *request = [NSFetchRequest fetchRequestWithEntityName:@"JIPArtist"];
    request.sortDescriptors = @[[NSSortDescriptor sortDescriptorWithKey:@"name" ascending:YES]];
    request.predicate       = [NSPredicate predicateWithFormat:@"favorite == %@", @YES];
    
    NSError *error = nil;
    _favoriteArtists = [[JIPManagedDocument sharedManagedDocument].managedObjectContext executeFetchRequest:request error:&error];
    
    if ([_favoriteArtists count] == 0)
    {
        [self.searchBar setHidden:YES];
    }
    
    #warning : is this line useful ?
    //[self.tableView reloadData];
}



//called whenever a character is put in searchBar
//here we want want to keep miles.png as a background image when searchBar is used
- (void)searchDisplayControllerDidBeginSearch:(UISearchDisplayController *)controller
{
    controller.searchResultsTableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    controller.searchResultsTableView.backgroundColor = [UIColor clearColor];
    [JIPDesign applyBackgroundWallpaperInTableView:controller.searchResultsTableView];
    
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
    JIPArtistNameCell *artistNameCell = [self.tableView dequeueReusableCellWithIdentifier:@"ArtistNameCell"];
    
    if (tableView == self.searchDisplayController.searchResultsTableView)
    {
        _artist = _filteredFavoriteArtists[indexPath.row];
    }
    else
    {
        _artist  = _favoriteArtists[indexPath.row];
    }
    
    artistNameCell.artist       = _artist;
    artistNameCell.UILabel.text = _artist.name;
    
    [[artistNameCell switchFavorite] setOn:[_artist.favorite boolValue]];

    return artistNameCell;
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


///////////////////////////////////////////////////////////////////////////
// Click on top left bar button (loupe) --> searBar becomes first responder
- (IBAction)searchBarButtonItemClick:(id)sender
{
    [self.tableView scrollRectToVisible:CGRectMake(0, 0, 1, 1) animated:NO];
    [self.searchBar becomeFirstResponder];
}


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

@end
