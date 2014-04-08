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

@synthesize searchBar  = _searchBar;
@synthesize isFiltered = _isFiltered;
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
    
    #warning besoin ou pas ?
    self.searchBar.delegate = self;
    
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
    
    [self.tableView reloadData];
}





////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
#pragma mark - UITableViewDataSource
////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if (_isFiltered)
        return [_filteredFavoriteArtists count];
    else
        return [_favoriteArtists     count];
}



- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    JIPArtistNameCell *artistNameCell = [tableView dequeueReusableCellWithIdentifier:@"ArtistNameCell"];
    if (!artistNameCell)
    {
        artistNameCell = [[JIPArtistNameCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"ArtistNameCell"];
    }
    
    if (_isFiltered)
    {
        _artist = _favoriteArtists[indexPath.row];
    }
    else
    {
        _artist  = self.favoriteArtists[indexPath.row];
    }
    
    artistNameCell.artist       = _artist;
    artistNameCell.UILabel.text = _artist.name;
    
    [[artistNameCell switchFavorite] setOn:[_artist.favorite boolValue]];

    
    //switchView.tag = indexPath.row;
    return artistNameCell;

}




////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
#pragma mark - UISearchBarDelegate
////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////


-(void)searchBar:(UISearchBar*)searchBar textDidChange:(NSString*)text
{
    if(text.length == 0)
    {
        _isFiltered = FALSE;
    }
    else
    {
        _isFiltered = TRUE;
        _filteredFavoriteArtists = [[NSMutableArray alloc] init];
        
        for (JIPArtist* artist in self.favoriteArtists)
        {
            NSRange nameRange = [artist.name rangeOfString:text options:NSCaseInsensitiveSearch];

            if(nameRange.location != NSNotFound)
            {
                [_filteredFavoriteArtists addObject:artist];
            }
        }
    }
    
    [self.tableView reloadData];
}


@end
