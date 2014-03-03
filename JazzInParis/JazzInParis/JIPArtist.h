//
//  JIPArtist.h
//  JazzInParis
//
//  Created by Max on 11/02/14.
//  Copyright (c) 2014 Max. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class JIPEvent;

@interface JIPArtist : NSManagedObject

@property (strong, nonatomic) NSNumber *id;
@property (strong, nonatomic) NSString *name;
@property (strong, nonatomic) NSURL *songkickUri;
@property (nonatomic, retain) NSSet *events;

-(instancetype)initWithID: (NSNumber *)id
name: (NSString *)name
songkickUri: (NSURL *)songkickUri;

@end

@interface JIPArtist (CoreDataGeneratedAccessors)

- (void)addEventsObject:(JIPEvent *)event;
- (void)removeEventsObject:(JIPEvent *)event;
- (void)addEvents:(NSSet *)events;
- (void)removeEvents:(NSSet *)events;

@end
