//
//  SideMenuViewController.m
//  df-ios
//
//  Created by Roger Ingouacka on 2013-10-15.
//  Copyright (c) 2013 LvlUp. All rights reserved.
//

#import "SideMenuViewController.h"

@interface SideMenuViewController ()

@end

@implementation SideMenuViewController

- (id)initWithStyle:(UITableViewStyle)style
{
    self = [super initWithStyle:style];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];


    if ([self respondsToSelector:@selector(edgesForExtendedLayout)])
        self.edgesForExtendedLayout = UIRectEdgeNone;
    float currentVersion = 7.0;
    if ([[[UIDevice currentDevice] systemVersion] floatValue] >= currentVersion) {
        // iOS 7
        self.navBar.frame = CGRectMake(self.navBar.frame.origin.x, self.navBar.frame.origin.y, self.navBar.frame.size.width, 64);
    }

    [self.slidingViewController setAnchorRightRevealAmount:180.0f];
    self.slidingViewController.underLeftWidthLayout = ECFullWidth;

    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
 
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
}


-(void)viewWillAppear:(BOOL)animated
{
    //
    [super viewWillAppear:animated];

}

-(void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/**
 *  Tells the delegate that the specified row is now deselected.
 
 
 *
 *  @param tableView A table-view object informing the delegate about the row deselection.
 *  @param indexPath An index path locating the deselected row in tableView.An index path locating the deselected row in tableView.
 */

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{

    if (indexPath.row == 0 && indexPath.section == 1)
    {
        
    }
    else if (indexPath.row == 0)
    {
        [self goTo:@"SelectionPage"];
    }
    else if (indexPath.row == 1)
    {
        [self goTo:@"MonitoringPage"];
    }
}


-(void)goTo:(NSString*)page
{
    
    UIViewController *newTopViewController = [self.storyboard instantiateViewControllerWithIdentifier:page];
    
    [self.slidingViewController anchorTopViewOffScreenTo:ECRight animations:nil onComplete:^{
        CGRect frame = self.slidingViewController.topViewController.view.frame;
        self.slidingViewController.topViewController = newTopViewController;
        self.slidingViewController.topViewController.view.frame = frame;
        [self.slidingViewController resetTopView];
    }];
}

@end
