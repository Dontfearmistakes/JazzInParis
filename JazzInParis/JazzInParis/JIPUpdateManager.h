//
//  JIPUpdateManager.h
//  JazzInParis
//
//  Created by Max on 19/03/14.
//  Copyright (c) 2014 Max. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "JIPVenue.h"
#import "JIPArtist.h"

@interface JIPUpdateManager : NSObject

+(JIPUpdateManager *) sharedUpdateManager;
-(void)updateUpcomingEvents;
-(void)updateUpcomingEventsForFavoriteArtist:(JIPArtist *)artist;
-(void)clearOldEvents;
-(void)clearArtistEvents:(JIPArtist *)artist;
-(JIPVenue *)venueFromSongkickWithId:(NSString*)venueId;

@end
