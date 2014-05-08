//
//  ViewController.m
//  YTBrowser
//
//  Created by Marin Todorov on 03/01/2013.
//  Copyright (c) 2013 Underplot ltd. All rights reserved.
//

#import "YouTubeVC.h"

#import "MGBox.h"
#import "MGScrollView.h"

#import "JSONModelLib.h"
#import "VideoModel.h"

#import "PhotoBox.h"
#import "WebVideoViewController.h"

@interface YouTubeVC () <UITextFieldDelegate>
{
    IBOutlet MGScrollView* scroller;
    MGBox* searchBox;
    
    NSArray* videos;
}

@end

@implementation YouTubeVC

@synthesize searchString = _searchString;

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.
    
    //setup the scroll view
    scroller.contentLayoutMode = MGLayoutGridStyle;
    scroller.bottomPadding = 8;
    scroller.backgroundColor = [UIColor colorWithWhite:0.25 alpha:1];

    
    //fire up the first search
    [self searchYoutubeVideosForTerm: _searchString];
}

-(void)searchYoutubeVideosForTerm:(NSString*)term
{
    NSLog(@"Searching for '%@' ...", term);
    
    //URL escape the term
    term = [term stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
    
    //make HTTP call
    NSString* searchCall = [NSString stringWithFormat:@"http://gdata.youtube.com/feeds/api/videos?q=%@&max-results=50&alt=json", term];

    [JSONHTTPClient getJSONFromURLWithString: searchCall
                                  completion:^(NSDictionary *json, JSONModelError *err) {
                                      
                                      if (err) {
                                          [[[UIAlertView alloc] initWithTitle:@"Network Problem"
                                                                      message:@"YouTube videos couldn't be downloaded"
                                                                     delegate:nil
                                                            cancelButtonTitle:@"Close"
                                                            otherButtonTitles: nil] show];
                                          return;
                                      }
                                      
                                      //initialize the models
                                      videos = [VideoModel arrayOfModelsFromDictionaries:
                                                json[@"feed"][@"entry"]
                                                ];
                                      
                                      if (videos)
                                      {
                                          NSLog(@"Loaded successfully models");
                                      }
                                      else
                                      {
                                          UILabel* label = [JIPDesign emptyTableViewLabelWithString:@"No videos for this artist"];
                                          [self.view addSubview:label];
                                      }
                                      

                                      //show the videos
                                      [self showVideos];
                                      
                                  }];
}

-(void)showVideos
{
    
    //add boxes for all videos
    for (int i=0;i<videos.count;i++) {
        
        //get the data
        VideoModel* video = videos[i];
        MediaThumbnail* thumb = video.thumbnail[0];
        
        //create a box
        PhotoBox *box = [PhotoBox photoBoxForURL:thumb.url title:video.title];
        box.onTap = ^{
            [self performSegueWithIdentifier:@"videoViewSegue" sender:video];
        };
        
        //add the box
        [scroller.boxes addObject:box];
    }
    
    //re-layout the scroll view
    [scroller layoutWithSpeed:0.3 completion:nil];
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    WebVideoViewController* controller = segue.destinationViewController;
    controller.video = sender;
}

@end
