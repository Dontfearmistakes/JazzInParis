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
    if ([[[UIDevice currentDevice] systemVersion] floatValue] >= currentVersion)
    {
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





- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{

    if (indexPath.row == 0 && indexPath.section == 1)
    {
        
    }
    else if (indexPath.row == 0)
    {
        [self goTo:@"Search Artist"];
    }
    else if (indexPath.row == 1)
    {
        [self goTo:@"All Concerts"];
    }
}


-(void)goTo:(NSString*)page
{
    
    UIViewController *newTopViewController = [self.storyboard instantiateViewControllerWithIdentifier:page];
    
    [self.slidingViewController anchorTopViewOffScreenTo:ECRight
                                              animations:nil
                                              onComplete:^{
        CGRect frame = self.slidingViewController.topViewController.view.frame;
        self.slidingViewController.topViewController = newTopViewController;
        self.slidingViewController.topViewController.view.frame = frame;
        [self.slidingViewController resetTopView];
    }];
}

@end
