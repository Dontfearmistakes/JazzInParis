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
    
}

////////////////////////////////////
-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    NSFetchRequest *request = [NSFetchRequest fetchRequestWithEntityName:@"JIPArtist"];
    request.sortDescriptors = @[[NSSortDescriptor sortDescriptorWithKey:@"name" ascending:YES]];
    request.predicate       = [NSPredicate predicateWithFormat:@"favorite == %@", @YES];
    
    NSError *error = nil;
    self.favoriteArtists = [[JIPManagedDocument sharedManagedDocument].managedObjectContext executeFetchRequest:request error:&error];
    
    [self.tableView reloadData];
}





////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
#pragma mark - UITableViewDataSource
////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return self.favoriteArtists.count;
}



- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    JIPArtistNameCell *artistNameCell = [tableView dequeueReusableCellWithIdentifier:@"ArtistNameCell"];
    if (!artistNameCell)
    {
        artistNameCell = [[JIPArtistNameCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"ArtistNameCell"];
    }
    
    
    JIPArtist * artist  = self.favoriteArtists[indexPath.row];
    artistNameCell.artist = artist;
    artistNameCell.UILabel.text = artist.name;
    
    [[artistNameCell switchFavorite] setOn:[artist.favorite boolValue]];
    
    
    //switchView.tag = indexPath.row;
    return artistNameCell;

}



@end
