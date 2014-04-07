//
//  JIPArtistDetailTableViewController.h
//  JazzInParis
//
//  Created by Max on 06/04/14.
//  Copyright (c) 2014 Max. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "JIPArtist.h"

@interface JIPArtistDetailTableViewController : UITableViewController

@property (strong, nonatomic) JIPArtist                 * artist;
@property (strong, nonatomic) NSMutableArray            * videoNames;
@property (strong, nonatomic) IBOutlet UINavigationItem * artistNameNavItem;

@end
