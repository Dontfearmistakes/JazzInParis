//
//  JIPManaginPageContent.m
//  JazzInParis
//
//  Created by Max on 15/04/14.
//  Copyright (c) 2014 Max. All rights reserved.
//

#import "JIPManaginPageContent.h"
#import "JIPPageContentVC.h"

@interface JIPManaginPageContent ()

@end

@implementation JIPManaginPageContent

@synthesize pageContents = _pageContents;

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    _pageContents = @[@"Over 200 Tips and Tricks",
                    @"Discover Hidden Features",
                    @"Bookmark Favorite Tip",
                    @"Free Regular Update"];
    
    // Create page view controller
    self.pageViewController = [self.storyboard instantiateViewControllerWithIdentifier:@"pageContentVC"];
    self.pageViewController.dataSource = self;
    
    JIPPageContentVC *startingViewController = [self viewControllerAtIndex:0];
    NSArray *viewControllers = @[startingViewController];
    [self.pageViewController setViewControllers:viewControllers direction:UIPageViewControllerNavigationDirectionForward animated:NO completion:nil];
    
    // Change the size of page view controller
    self.pageViewController.view.frame = CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height - 30);
    
    [self addChildViewController:_pageViewController];
    [self.view addSubview:_pageViewController.view];
    [self.pageViewController didMoveToParentViewController:self];
}


#pragma mark - Page View Controller Data Source

- (UIViewController *)pageViewController:(UIPageViewController *)pageViewController viewControllerBeforeViewController:(UIViewController *)viewController
{
    NSUInteger index = ((JIPPageContentVC*) viewController).pageIndex;
    
    if ((index == 0) || (index == NSNotFound)) {
        return nil;
    }
    
    index--;
    return [self viewControllerAtIndex:index];
}




- (UIViewController *)pageViewController:(UIPageViewController *)pageViewController viewControllerAfterViewController:(UIViewController *)viewController
{
    NSUInteger index = ((JIPPageContentVC*) viewController).pageIndex;
    
    if (index == NSNotFound) {
        return nil;
    }
    
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
    pageContentViewController.pageIndex      = index;
    pageContentViewController.contentText    = self.pageContents[index];
    
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
