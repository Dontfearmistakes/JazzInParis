//
//  JIPUpdateManager.h
//  JazzInParis
//
//  Created by Max on 19/03/14.
//  Copyright (c) 2014 Max. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface JIPUpdateManager : NSObject

+(JIPUpdateManager *) sharedUpdateManager;
-(void)updateUpcomingEvents;

@end
