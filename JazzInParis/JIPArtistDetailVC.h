//
//  JIPArtistDetailVC.h
//  JazzInParis
//
//  Created by Max on 11/04/14.
//  Copyright (c) 2014 Max. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "JIPArtist.h"

@interface JIPArtistDetailVC : UIViewController
@property (strong, nonatomic) JIPArtist  * artist;
@property (strong, nonatomic) NSString   * searchString;
@property (strong, nonatomic) IBOutlet UISwitch *favoriteSwitchView;

- (IBAction)toggleFavorite:(id)sender;

@end
