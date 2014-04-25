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
    
    //If iOS7
    float currentVersion = 7.0;
    if ([[[UIDevice currentDevice] systemVersion] floatValue] >= currentVersion)
        self.navBar.frame = CGRectMake(self.navBar.frame.origin.x, self.navBar.frame.origin.y, self.navBar.frame.size.width, 64);

    [self.slidingViewController setAnchorRightRevealAmount:180.0f];
     self.slidingViewController.underLeftWidthLayout = ECFullWidth;

    self.navBar.barTintColor = Rgb2UIColor(85, 85, 85);

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
    else if (indexPath.row == 2)
    {
        [self goTo:@"Favorite Artists"];
    }
    else if (indexPath.row == 3)
    {
        [self goTo:@"Paris Jazz Clubs"];
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
