//
//  JIPSearchArtistTableViewController.h
//  JazzInParis
//
//  Created by Max on 04/04/14.
//  Copyright (c) 2014 Max. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface JIPSearchArtistTableViewController : UITableViewController <UISearchBarDelegate, UISearchDisplayDelegate>

- (IBAction)searchClickAction:(id)sender;
@property (strong, nonatomic) IBOutlet UISearchBar *searchBar;
- (IBAction)revealMenu:(id)sender;

@end
