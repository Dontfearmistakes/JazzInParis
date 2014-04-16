//
//  JIPPageContentVC.m
//  JazzInParis
//
//  Created by Max on 15/04/14.
//  Copyright (c) 2014 Max. All rights reserved.
//

#define padding 20
#import "JIPPageContentVC.h"


@interface JIPPageContentVC ()

@end

@implementation JIPPageContentVC

@synthesize initialTextView = _initialTextView;
@synthesize contentText     = _contentText;


- (void)viewDidLoad
{
    [super viewDidLoad];

    [JIPDesign applyBackgroundWallpaperInViewController:self];
    
    [_initialTextView.layer setBorderWidth: 10.0];
    [_initialTextView.layer setBorderColor:[Rgb2UIColor(49, 49, 49) CGColor]];
    _initialTextView.layer.cornerRadius = 10.0f;

    [_initialTextView setText:_contentText];
    
    CGSize textSize = { 260.0, 10000.0 };
    //retourne width and height de mon bloc de text en fonction de la police
    CGSize size = [_initialTextView.text sizeWithFont:[UIFont systemFontOfSize:14]
                                    constrainedToSize:textSize
                                        lineBreakMode:NSLineBreakByWordWrapping];
    
    [_initialTextView setFrame:CGRectMake(padding, padding+5, size.width, size.height+padding)];
    [_initialTextView sizeToFit];
    
    if (self.pageIndex == 3)
    {
        [self.finishWelcomePageControllerButton setHidden:NO];
    }
}




- (IBAction)finishWelcomePageControllerClick:(id)sender {
    
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    [userDefaults setBool:NO forKey:@"firstLaunch"];
    
    [self dismissViewControllerAnimated:NO completion:nil];
}

@end
