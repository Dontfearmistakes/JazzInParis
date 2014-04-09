 //
//  JIPArtistNameCell.h
//  JazzInParis
//
//  Created by Max on 06/04/14.
//  Copyright (c) 2014 Max. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "JIPArtist.h"

@interface JIPArtistNameCell : UITableViewCell

@property (strong, nonatomic) IBOutlet UISwitch *switchFavorite;

@property (strong, nonatomic) IBOutlet UILabel *UILabel;
@property (strong, nonatomic) IBOutlet UILabel *testLabel;

@property (strong, nonatomic) JIPArtist *artist;

- (IBAction)toggleFavorite:(id)sender;

@end
