//
//  JIPManagedDocument.h
//  JazzInParis
//
//  Created by Max on 13/03/14.
//  Copyright (c) 2014 Max. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface JIPManagedDocument : UIManagedDocument

+(JIPManagedDocument *) sharedManagedDocument;
-(void) performBlockWithDocument:(void (^)(JIPManagedDocument * managedDocument))block;

@end
