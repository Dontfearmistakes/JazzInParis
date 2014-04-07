//
//  JIPArtistNameCell.m
//  JazzInParis
//
//  Created by Max on 06/04/14.
//  Copyright (c) 2014 Max. All rights reserved.
//

#import "JIPArtistNameCell.h"
#import "JIPUpdateManager.h"

@implementation JIPArtistNameCell



- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}



- (IBAction)toggleFavorite:(id)sender {
    //1) On update l'attribut favorite
    [self.artist setFavorite:[NSNumber numberWithBool:[(UISwitch*)sender isOn]]];
    
    //2) On télecharge ou efface les Events liés à cet artiste
    if ([(UISwitch*)sender isOn])
    {
        [[JIPUpdateManager sharedUpdateManager] updateUpcomingEventsForFavoriteArtist:self.artist];
    }
    else
    {
        [[JIPUpdateManager sharedUpdateManager] clearArtistEvents:self.artist];
    }
}
@end
