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




//////////////////////////////////////////////////////////////////////////////
// First time it's called, create a UIManagedDoc and put it in the statis ivar
// Then returns always this ivar
//////////////////////////////////////////////////////////////////////////////
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






///////////////////////////////////////////////////////////////////////////////////////////////////////////////
// Called like that : [[JIPManagedDocument sharedManagedDocument] performBlockWithDocument:aBlock]
// This method make sure that we perform what's in the block only when the UIManagedDoc is opened and ready
// If the Doc doesn't exist yet it gets created
// If the Doc is already being opened at the same time, this method is called after a O.5 sec delay
///////////////////////////////////////////////////////////////////////////////////////////////////////////////
-(void)performBlockWithDocument:(void (^)(JIPManagedDocument * managedDocument))block
{
    ///////////////////////////////////////////////
    void (^completionBlock) (BOOL) = ^(BOOL success) {
        if (success)
        {
            block(self); //ici self sera l'instance _sharedManagedDocument retourneé par +(JIPManagedDocument *)sharedManagedDocument
            NSLog(@"COULD PERFORM BLOCK WITH ManagedDocument");
        }
        else
        {
            NSLog(@"COULDNT PERFORM BLOCK WITH ManagedDocument");
        }
        self.openingDocument = NO;
    };
    
    
    ///////////////////////////////////////////////
    //SOIT DOC PRET et ouvert --> on execute le completionBlock
    if (self.documentState == UIDocumentStateNormal)
    {
        completionBlock(YES);
    }
    
    
    
    //SOIT BESOIN DU DOC ET DOC PAS OUVERT NI EN TRAIN D'ETRE OUVERT DONC ON VA
    //SOIT LE CREER S'IL N'EXISTE PAS ENCORE
    //SOIT L'OUVRIR S'IL EXISTE DEJA
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
    
    
    
    //SOIT BESOIN du doc mais on est DEJA en train de l'ouvrir AU MEME MOMENT
    //donc wait 0.5 sec et rapelle cette même méthode
    else
    {
        [self performSelector:@selector(performBlockWithDocument:)
                   withObject:block
                   afterDelay:0.5];
    }
    
}

@end
