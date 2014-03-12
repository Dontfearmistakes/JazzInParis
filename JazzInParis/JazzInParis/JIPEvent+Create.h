//
//  JIPEvent+Create.h
//  JazzInParis
//
//  Created by Max on 11/03/14.
//  Copyright (c) 2014 Max. All rights reserved.
//

#import "JIPEvent.h"

@interface JIPEvent (Create)

+ (JIPEvent *)eventWithSongkickInfo:(NSDictionary *)eventDictionary
             inManagedObjectContext:(NSManagedObjectContext *)context;

@end
