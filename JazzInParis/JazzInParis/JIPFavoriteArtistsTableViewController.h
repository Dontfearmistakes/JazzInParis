//
//  JIPFavoriteArtistsTableViewController.h
//  JazzInParis
//
//  Created by Max on 07/04/14.
//  Copyright (c) 2014 Max. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "JIPArtist.h"

@interface JIPFavoriteArtistsTableViewController : UITableViewController <UISearchBarDelegate>

@property (strong, nonatomic) NSArray              * favoriteArtists;
@property (strong, nonatomic) NSMutableArray       * filteredFavoriteArtists;
@property (strong, nonatomic) IBOutlet UISearchBar * searchBar;
@property (nonatomic)         BOOL        isFiltered;
@property (strong, nonatomic) JIPArtist * artist;


@end
