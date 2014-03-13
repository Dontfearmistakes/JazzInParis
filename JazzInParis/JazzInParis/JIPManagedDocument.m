//
//  JIPManagedDocument.m
//  JazzInParis
//
//  Created by Max on 13/03/14.
//  Copyright (c) 2014 Max. All rights reserved.
//

#import "JIPManagedDocument.h"

static JIPManagedDocument * _sharedManagedDocument;

@implementation JIPManagedDocument

+(JIPManagedDocument *)sharedManagedDocument
{
    
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        NSURL *url = [[[NSFileManager defaultManager] URLsForDirectory:NSDocumentationDirectory inDomains:NSUserDomainMask] lastObject];
        url = [url URLByAppendingPathComponent:@"DemoDocument"];
        _sharedManagedDocument = [[JIPManagedDocument alloc] initWithFileURL:url];
    });
    
    return _sharedManagedDocument;
}

-(void)performWithDocument:(void (^)(JIPManagedDocument * managedDocument))block
{
    //if UIDocument doesnt exist yet, create the document
    if ( ! [[NSFileManager defaultManager] fileExistsAtPath:[self.fileURL path]] )
    {
        [self        saveToURL:self.fileURL
              forSaveOperation:UIDocumentSaveForCreating
             completionHandler:^(BOOL success)
         {
             if (success)
             {
                 block(self);
             }
             else
             {
                 NSLog(@"COULDNT CREATE NEW DOCUMENT");
             }
         }];
    }
    
    //if the document already exists but is closed, open it
    else if (self.documentState == UIDocumentStateClosed)
    {
        [self openWithCompletionHandler:^(BOOL success)
         {
             if (success)
             {
                 block(self);
             }
         }];
    }
    
    //otherwise, try to use it
    else if (self.documentState == UIDocumentStateNormal)
    {
        NSLog(@"ALREADY CREATED AND OPENED DOCUMENT");
        block(self);
    }
    
}

@end
