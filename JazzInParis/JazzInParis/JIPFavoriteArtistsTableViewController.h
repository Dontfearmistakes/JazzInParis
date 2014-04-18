//
//  JIPFavoriteArtistsTableViewController.h
//  JazzInParis
//
//  Created by Max on 07/04/14.
//  Copyright (c) 2014 Max. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "JIPArtist.h"

@interface JIPFavoriteArtistsTableViewController : UITableViewController <UISearchBarDelegate, UISearchDisplayDelegate>

@property (strong, nonatomic) NSMutableArray       * favoriteArtists;
@property (strong, nonatomic) NSArray              * filteredFavoriteArtists;
@property (nonatomic)         BOOL                   isFiltered;
@property (strong, nonatomic) JIPArtist            * artist;

@property (strong, nonatomic) IBOutlet UISearchBar * searchBar;

@property (strong, nonatomic) IBOutlet UIBarButtonItem *editBarButton;
- (IBAction)editBarButtonClick:(id)sender;


@end
