//
//  UpcomingEventsCDTVC.m
//  JazzInParis
//
//  Created by Max on 10/03/14.
//  Copyright (c) 2014 Max. All rights reserved.
//

#import "JIPUpcomingEventsCDTVC.h"
#import "JIPEvent.h"
#import "JIPEvent+Create.h"
#import "JIPManagedDocument.h"

@interface JIPUpcomingEventsCDTVC ()

@end

@implementation JIPUpcomingEventsCDTVC

-(void)createFakeEvents
{
    
    [[JIPManagedDocument sharedManagedDocument] performWithDocument:^(JIPManagedDocument *managedDocument) {
        
        //fetch the events from Songkick
        NSArray *upcomingEvents = @[
                                    @{@"id"       :@1,
                                      @"name"     :@"Brad Mehldau",
                                      @"lat"      :@(-0.1150322),
                                      @"long"     :@51.4650846,
                                      @"date"     :@"22/12/2014",
                                      @"venue"    :@"Baiser Salé",
                                      @"artist"   :@"Brad Mehldau",
                                      @"type"     :@"concert",
                                      @"uriString":@"http://www.songkick.com/concerts/19267659-maxxximus-at-baiser-sale",
                                      @"ageRestriction" : @"14+",
                                      @"artist"   : @"Brad Mehldau",
                                      @"venue"    : @"Baiser Salé"}
                                    ];
        //put the events in Core Data
        //Database need to be accessed on the managedObjectContext Thread
        
        for (NSDictionary *upcomingEvent in upcomingEvents)
        {
            [JIPEvent eventWithSongkickInfo:upcomingEvent
                     inManagedObjectContext:managedDocument.managedObjectContext];
        }

    }];

}



////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////
-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [self  createFetchResultsController];
    [self createFakeEvents];
}

////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////
-(void)createFetchResultsController
{
    [[JIPManagedDocument sharedManagedDocument] performWithDocument:^(JIPManagedDocument *managedDocument) {
        
        NSFetchRequest *request = [NSFetchRequest fetchRequestWithEntityName:@"JIPEvent"];
        request.sortDescriptors = @[[NSSortDescriptor sortDescriptorWithKey:@"date" ascending:YES]];
        request.predicate = nil; //all JIPEvents
        self.fetchedResultsController = [[NSFetchedResultsController alloc] initWithFetchRequest:request
                                                                            managedObjectContext:managedDocument.managedObjectContext
                                                                              sectionNameKeyPath:nil
                                                                                       cacheName:nil];
    }];
    
}

////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////
-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"JIPEvent"];
    JIPEvent *event = [self.fetchedResultsController objectAtIndexPath:indexPath];
    cell.textLabel.text = event.name;
    return cell;
}


@end
