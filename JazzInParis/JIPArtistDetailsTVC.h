//
//  JIPArtistDetailsTVC.h
//  JazzInParis
// pushToYTBrowser
//  Created by Max on 12/04/14.
//  Copyright (c) 2014 Max. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "JIPArtist.h"

@interface JIPArtistDetailsTVC : UITableViewController

@property (strong, nonatomic) JIPArtist  * artist;
@property (strong, nonatomic) NSString   * searchString;
@property (strong, nonatomic) IBOutlet UISwitch *favoriteSwitchView;

@property (strong, nonatomic) IBOutlet UIImageView *artistImageView;

- (IBAction)toggleFavorite:(id)sender;

@property (nonatomic) float  ratio;

@end
