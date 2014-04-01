//
//  JIPFavoriteArtistTableViewController.m
//  JazzInParis
//
//  Created by Max on 28/03/14.
//  Copyright (c) 2014 Max. All rights reserved.
//

#import "JIPFavoriteArtistTableViewController.h"
#import "JIPManagedDocument.h"
#import <CoreData/CoreData.h>
#import "JIPArtist.h"
#import "JIPUpdateManager.h"

@interface JIPFavoriteArtistTableViewController ()

@property (strong, nonatomic) JIPArtist * tmpArtist;

@end

@implementation JIPFavoriteArtistTableViewController

- (id)initWithStyle:(UITableViewStyle)style
{
    self = [super initWithStyle:style];
    if (self) {
        self.title = @"Favorite Artists";
        self.tabBarItem.image = [UIImage imageNamed:@"Venue"];
    }
    return self;
}


-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
        
    NSFetchRequest *request = [NSFetchRequest fetchRequestWithEntityName:@"JIPArtist"];
    request.sortDescriptors = @[[NSSortDescriptor sortDescriptorWithKey:@"name" ascending:YES]];
    request.predicate       = [NSPredicate predicateWithFormat:@"favorite == %@", @YES]; 
    [[JIPManagedDocument sharedManagedDocument] performBlockWithDocument:^(JIPManagedDocument *managedDocument)
    {
        NSError *error = nil;
        self.favoriteArtists = [[JIPManagedDocument sharedManagedDocument].managedObjectContext executeFetchRequest:request error:&error];
    }];
     
    [self.tableView reloadData];
}




- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return self.favoriteArtists.count;
}





- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"cell"];
    if (!cell)
    {
        cell = [[UITableViewCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"cell"];
    }
    

    JIPArtist * artist = self.favoriteArtists[indexPath.row];
    self.tmpArtist = artist;
    cell.textLabel.text = artist.name;
    
    UISwitch *switchView = [[UISwitch alloc] initWithFrame:CGRectZero];
    
    cell.accessoryView = switchView;
    switchView.tag = indexPath.row;
    
    [switchView setOn:[artist.favorite boolValue] animated:NO];
    
    [switchView addTarget:self action:@selector(toggleFavorite:) forControlEvents:UIControlEventValueChanged];
    
    return cell;
}




////////////////////////////////////
- (void) toggleFavorite:(id)sender {
    UISwitch* switchControl = sender;
    
    [self.favoriteArtists[switchControl.tag] setFavorite:[NSNumber numberWithBool:switchControl.on]];
    
    if (switchControl.on) {
        [[JIPUpdateManager sharedUpdateManager] updateUpcomingEventsForFavoriteArtist:self.favoriteArtists[switchControl.tag]];
    }
    else {
        [[JIPUpdateManager sharedUpdateManager] clearArtistEvents:self.favoriteArtists[switchControl.tag]];
    }
}

@end
