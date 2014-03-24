//
//  JIPArtistDetailsViewController.m
//  JazzInParis
//
//  Created by Max on 11/02/14.
//  Copyright (c) 2014 Max. All rights reserved.
//

#import "JIPArtistDetailsViewController.h"

@interface JIPArtistDetailsViewController ()

@property (strong, nonatomic) UITableView * switchButtonLine;
@property (nonatomic)         CGFloat       switchButtonLineHeight;

@end

@implementation JIPArtistDetailsViewController


//////////////////////////////////////////////////////////////////////
-(NSUInteger)supportedInterfaceOrientations
{
    return UIInterfaceOrientationMaskAll;
}

////////////////////////////////////////////////////////////////////
-(void)viewDidLayoutSubviews
//called when bounds are redrawn
{
    CGFloat superViewWidth = self.view.bounds.size.width;
    CGFloat superViewHeight = self.view.bounds.size.height;
    
    self.switchButtonLine.frame = CGRectMake(0,0, superViewWidth, superViewHeight);

}

//////////////////////////////////////////////////////////////////////
- (void)viewDidLoad
{
    [super viewDidLoad];
    //FIXME: Artist Name appears on second load only
    self.title = [NSString stringWithFormat:@"%@", self.artist.name];
    
    
    //1) setup the SwitchButton tableView
    self.switchButtonLine = [[UITableView alloc] initWithFrame:CGRectMake(0, 0, self.view.bounds.size.width, self.view.bounds.size.height)];
    
    self.switchButtonLine.dataSource = self;
    [self.view addSubview:self.switchButtonLine];
    
    ////////////////////////////////////////////////////////////////////////
    ////////////////////////////////////////////////////////////////////////
    
//    IDEAS
//    - Toggle button : Add/Remove to/from Favorites
//    - Wikipedia description
//    - Href to Songkick Artist page (showing upcoming concerts)
//          -->Later : create ArtistUpcomingEventsVC with Songkick API Call retrieving upComingConcerts only for this artist
//    - YouTube vidéos through API call
    
    ////////////////////////////////////////////////////////////////////////
    ////////////////////////////////////////////////////////////////////////
}


////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
#pragma mark - UITableViewDataSource
////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return 1;
}




//////////////////////////////////////////////////////
-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"cell"];
    if (!cell)
    {
        cell = [[UITableViewCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"cell"];
    }
    
    //CELL GETS EVENT.NAME
    cell.textLabel.text =@"Add/Remove to Favorite";
    UISwitch *switchView = [[UISwitch alloc] initWithFrame:CGRectZero];
    cell.accessoryView = switchView;
    [switchView setOn:NO animated:NO];
    
    return cell;
}
@end
