//
//  JIPManaginPageContent.m
//  JazzInParis
//
//  Created by Max on 15/04/14.
//  Copyright (c) 2014 Max. All rights reserved.
//

#import "JIPManagingPageContent.h"
#import "JIPPageContentVC.h"

@interface JIPManagingPageContent ()

@end

@implementation JIPManagingPageContent

@synthesize pageContents = _pageContents;

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    [[self navigationController] setNavigationBarHidden:YES];
    
    _pageContents = @[@"\rWelcome to Dontfearmistakes, \rthe app for jazz concerts in Paris !\r\r  Follow your favorites artists concerts in Paris and say goodbye to missed concerts !",
                    @"\rStart by adding your favorite artists \rfrom the 'Search Artist' tab.\r\r Then follow their upcoming concerts \r in the 'All Concerts' tab.",
                    @"\r\rWant to stop following an artist ?\r\r Manage your list from the 'Favorite Artist' tab.",
                    @"\r\r\rEnjoy the Paris Jazz scene !"];
    
    // Create page view controller
    self.pageViewController            = [self.storyboard instantiateViewControllerWithIdentifier:@"pageVC"];
    self.pageViewController.dataSource =  self;
    
    //Create the VC that will be the content of the PageController
    JIPPageContentVC *startingViewController =  [self viewControllerAtIndex:0];
    NSArray          *viewControllers        = @[startingViewController];
    [self.pageViewController setViewControllers:viewControllers
                                      direction:UIPageViewControllerNavigationDirectionForward
                                       animated:NO
                                     completion:nil];
    
    // Change the size of page view controller
    self.pageViewController.view.frame = CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height - 30);
    
    [self      addChildViewController: _pageViewController     ];
    [self.view addSubview            : _pageViewController.view];
    [self.pageViewController didMoveToParentViewController:self];
}



////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////
#pragma mark - Page View Controller Data Source
////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////

//Slide forward
- (UIViewController *)pageViewController:(UIPageViewController *)pageViewController
      viewControllerBeforeViewController:(UIViewController *)    viewController
{
    NSUInteger index = ((JIPPageContentVC*) viewController).pageIndex;
    
    if ((index == 0) || (index == NSNotFound))
        return nil;
    
    index--;
    return [self viewControllerAtIndex:index];
}




//Slide backward
- (UIViewController *)pageViewController:(UIPageViewController *)pageViewController
       viewControllerAfterViewController:(UIViewController *)viewController
{
    NSUInteger index = ((JIPPageContentVC*) viewController).pageIndex;
    
    if (index == NSNotFound)
        return nil;

    
    index++;
    if (index == [self.pageContents count]) {
        return nil;
    }
    return [self viewControllerAtIndex:index];
}



- (JIPPageContentVC *)viewControllerAtIndex:(NSUInteger)index
{
    if (([self.pageContents count] == 0) || (index >= [self.pageContents count])) {
        return nil;
    }
    
    // Create a new view controller and pass suitable data.
    JIPPageContentVC *pageContentViewController = [self.storyboard instantiateViewControllerWithIdentifier:@"pageContentVC"];
    pageContentViewController.pageIndex         = index;
    pageContentViewController.contentText       = self.pageContents[index];
    
    return pageContentViewController;
}



- (NSInteger)presentationCountForPageViewController:(UIPageViewController *)pageViewController
{
    return [self.pageContents count];
}

- (NSInteger)presentationIndexForPageViewController:(UIPageViewController *)pageViewController
{
    return 0;
}

@end
