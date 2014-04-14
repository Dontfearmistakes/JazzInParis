//
//  JIPArtistDetailsTVC.h
//  JazzInParis
//
//  Created by Max on 12/04/14.
//  Copyright (c) 2014 Max. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "JIPArtist.h"

@interface JIPArtistDetailsTVC : UITableViewController

@property (strong, nonatomic) JIPArtist  * artist;
@property (strong, nonatomic) NSString   * searchString;
@property (strong, nonatomic) IBOutlet UISwitch *favoriteSwitchView;
@property (strong, nonatomic) IBOutlet UITableViewCell *showYouTubeCell;

- (IBAction)toggleFavorite:(id)sender;

@end
