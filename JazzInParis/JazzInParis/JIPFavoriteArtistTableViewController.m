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

@interface JIPFavoriteArtistTableViewController ()

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

- (void)viewDidLoad
{
    [super viewDidLoad];
}

-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [[JIPManagedDocument sharedManagedDocument] performBlockWithDocument:^(JIPManagedDocument *managedDocument) {
        
        NSFetchRequest *request = [NSFetchRequest fetchRequestWithEntityName:@"JIPArtist"];
        request.sortDescriptors = @[[NSSortDescriptor sortDescriptorWithKey:@"name" ascending:YES]];
        request.predicate       = [NSPredicate predicateWithFormat:@"favorite == %@", [NSNumber numberWithBool: YES]]; //all JIPEvents starting today or later
        NSError *error = nil;
        self.favoriteArtists = [managedDocument.managedObjectContext executeFetchRequest:request error:&error];
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
    cell.textLabel.text = artist.name;
    
    return cell;
}



@end
