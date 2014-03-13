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

////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////
-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [self createFakeEvents];
    [self createFetchResultsController];
}


////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////
-(void)createFetchResultsController
{
    [[JIPManagedDocument sharedManagedDocument] performBlockWithDocument:^(JIPManagedDocument *managedDocument) {
        
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
-(void)createFakeEvents
{
    [[JIPManagedDocument sharedManagedDocument] performBlockWithDocument:^(JIPManagedDocument *managedDocument) {
        
        // 1) Fetch the events from Songkick
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
        
        // 2) Put the events in ManagedObjectContext
        for (NSDictionary *upcomingEvent in upcomingEvents)
        {
            [JIPEvent eventWithSongkickInfo:upcomingEvent
                     inManagedObjectContext:managedDocument.managedObjectContext];
        }

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
