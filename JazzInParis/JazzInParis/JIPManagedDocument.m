//
//  JIPManagedDocument.m
//  JazzInParis
//
//  Created by Max on 13/03/14.
//  Copyright (c) 2014 Max. All rights reserved.
//

#import "JIPManagedDocument.h"

static JIPManagedDocument * _sharedManagedDocument;

@interface JIPManagedDocument ()

@property (nonatomic, getter = isOpeningDocument) BOOL openingDocument;

@end

@implementation JIPManagedDocument

+(JIPManagedDocument *)sharedManagedDocument
{
    
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        NSURL *url = [[[NSFileManager defaultManager] URLsForDirectory:NSDocumentDirectory inDomains:NSUserDomainMask] lastObject];
        url = [url URLByAppendingPathComponent:@"DemoDocument"];
        _sharedManagedDocument = [[JIPManagedDocument alloc] initWithFileURL:url];
    });
    
    return _sharedManagedDocument;
}

-(void)performWithDocument:(void (^)(JIPManagedDocument * managedDocument))block
{
    
    void (^completionBlock) (BOOL) = ^(BOOL success) {
        if (success)
        {
            block(self);
        }
        else
        {
            NSLog(@"COULDNT CREATE NEW DOCUMENT");
        }
        self.openingDocument = NO;
    };
    
    //SOIT DOC PRET et ouvert --> on execute
    if (self.documentState == UIDocumentStateNormal)
    {
        completionBlock(YES);
    }
    
    
    //SOIT ON EST PAS EN TRAIN DE L4OUVRIR MAIS ON ABESOIN DONC ON VA L4OUVRIR OU LE CR2ER
    else if (! self.openingDocument)
    {
        self.openingDocument = YES;
        
        //if UIDocument doesnt exist yet, create the document
        if ( ! [[NSFileManager defaultManager] fileExistsAtPath:[self.fileURL path]] )
        {
            [self        saveToURL:self.fileURL
                  forSaveOperation:UIDocumentSaveForCreating
                 completionHandler:completionBlock];
        }
        
        //if the document already exists but is closed, open it
        else if (self.documentState == UIDocumentStateClosed)
        {
            [self openWithCompletionHandler:completionBlock];
        }
    }
    
    //SOIT BESOIN du doc mais on est déjà en train de l'ouvrir/le crée donc wait 0.5 sec
    else
    {
        [self performSelector:@selector(performWithDocument:)
                   withObject:block
                   afterDelay:0.5];
    }
    
}

@end
