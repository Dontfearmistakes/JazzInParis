//
//  JIPSearchArtistTableViewController.h
//  JazzInParis
//
//  Created by Max on 04/04/14.
//  Copyright (c) 2014 Max. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface JIPSearchArtistTableViewController : UITableViewController <UISearchBarDelegate, UISearchDisplayDelegate, UITextFieldDelegate>

- (IBAction)revealMenu:(id)sender;
@property (strong, nonatomic) IBOutlet UIBarButtonItem *searchNavBarButton;



@end
