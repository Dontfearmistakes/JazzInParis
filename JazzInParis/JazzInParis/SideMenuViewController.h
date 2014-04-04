//
//  SideMenuViewController.h
//  df-ios
//
//  Created by Roger Ingouacka on 2013-10-15.
//  Copyright (c) 2013 LvlUp. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ECSlidingViewController.h"


/**
 *   SideMenuViewController is associated with the  Side menu page.
 This ViewController contains all the graphics implementations of the  Side menu page like textfields, button etc ... and associated events.
 It also contains a shared instance that allows us to use the data from the application
 cf : DareForgetAPISharedInstance
 */
@interface SideMenuViewController : UITableViewController
{
}
@property (weak, nonatomic) IBOutlet UINavigationBar *navBar;

@end
