//
//  JIPEvent.m
//  JazzInParis
//
//  Created by Max on 02/02/14.
//  Copyright (c) 2014 Max. All rights reserved.
//

#import "JIPEvent.h"

@implementation JIPEvent
//@dynamic : dit au compilateur = pas de getter pas de setter pas de ivar
//@dynamic id;
//@dynamic type;
//
//@dynamic uri;
//@dynamic ageRestriction;
//@dynamic location;
//@dynamic venue;
//@dynamic artist;
//@dynamic date;
@synthesize name = _name;
@synthesize distanceFromUserToEvent = _distanceFromUserToEvent;
@synthesize shouldDisplayDistanceFromUserToEvent = _shouldDisplayDistanceFromUserToEvent;

//////////////////////////////////////// ici il f
-(id)init
{
    return [self initWithID:@0
                       name:NSLocalizedString(@"event", @"Default event title")
                   location:CLLocationCoordinate2DMake(0, 0)
                       date:[NSDate date]
                      venue:[[JIPVenue alloc]init]
                     artist:[[JIPArtist alloc]init]    ];
}

////////////////////////////////////////
- (instancetype)initWithID:(NSNumber *)id
                      name:(NSString *)name
                  location:(CLLocationCoordinate2D)location
                      date:(NSDate *)date
                     venue:(JIPVenue *)venue
                    artist:(JIPArtist *)artist
{
    self = [super init];
    if (self)
    {
        self.id = id;
        self.name = name;
        self.location = location;
        self.date = date;
        self.venue = venue;
        self.artist = artist;
    }
    return self;
}

////////////////////////////////////////
// Check if we have a custom display name for the event.
// If not, set and use the artist's name as the display name.
- (NSString *)name
{
    if (!_name && [_name isEqualToString:@""]) {
        _name = [NSString stringWithFormat:@"%@ at %@", self.artist.name, self.venue.name];
    }
    return _name;
}

//@property location est remplie lors de l'appel à l'API
//@property coordinate est juste required par <MKAnnotation> mais readonly donc il suffit d'implémenter le getter
//Dans JIPConcertDetailsVC (conforme à <MKMapViewDelegate>), c'est -viewForAnnotation qui réclame un object conforme à <MKAnnotation>
//et qui va donc chercher la @property "coordinate", on lui renvoie @property location qui est du même type
-(CLLocationCoordinate2D)coordinate
{
    return self.location;
}

-(NSString *)title
{
    return self.name;
}

-(void)setName:(NSString *)name
{
    [self willChangeValueForKey:@"title"];
    [self willChangeValueForKey:@"name"];
    _name = name;
    [self didChangeValueForKey:@"title"];
    [self didChangeValueForKey:@"name"];
}

-(void)setShouldDisplayDistanceFromUserToEvent:(BOOL)shouldDisplayDistanceFromUserToEvent
{
    [self willChangeValueForKey:@"subtitle"];
    [self willChangeValueForKey:@"shouldDisplayDistanceFromUserToEvent"];
    _shouldDisplayDistanceFromUserToEvent = shouldDisplayDistanceFromUserToEvent;
    [self didChangeValueForKey:@"shouldDisplayDistanceFromUserToEvent"];
    [self didChangeValueForKey:@"subtitle"];
}

-(void)setDistanceFromUserToEvent:(double)distanceFromUserToEvent
{
    [self willChangeValueForKey:@"subtitle"];
    _distanceFromUserToEvent = distanceFromUserToEvent;
    [self didChangeValueForKey:@"subtitle"];
}

-(NSString *)subtitle
{
    if (!self.shouldDisplayDistanceFromUserToEvent)
    {
        return nil;
    }
    else
    {
        return [NSString stringWithFormat:@"%ld meters away", lroundf(self.distanceFromUserToEvent)];
    }
}

@end
