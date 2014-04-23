//
//  JIPEvent.m
//  JazzInParis
//
//  Created by Max on 02/02/14.
//  Copyright (c) 2014 Max. All rights reserved.
//

#import "JIPEvent.h"

@interface JIPEvent ()

@property (nonatomic) NSString *primitiveSectionIdentifier;

@end

@implementation JIPEvent

//@dynamic : dit au compilateur = pas de getter pas de setter pas de ivar but don't freak out
@dynamic id;
@dynamic type;
@dynamic uriString;
@dynamic ageRestriction;
@dynamic latitude;
@dynamic longitude;
@dynamic date;
@dynamic startTime;
@dynamic venue;
@dynamic artist;
@dynamic name;
@dynamic sectionIdentifier;
@dynamic primitiveSectionIdentifier;

@synthesize location = _location;
//@synthesize name = _name;
@synthesize distanceFromUserToEvent = _distanceFromUserToEvent;
@synthesize shouldDisplayDistanceFromUserToEvent = _shouldDisplayDistanceFromUserToEvent;




#pragma mark - Transient properties

- (NSString *)sectionIdentifier
{
    // Create and cache the section identifier on demand.
    
    [self willAccessValueForKey:@"sectionIdentifier"];
    NSString *tmp = [self primitiveSectionIdentifier];
    [self didAccessValueForKey:@"sectionIdentifier"];
    
    if (!tmp)
    {
        /*
         Sections are organized by month and year. 
         Create the section identifier as a string representing the number (year * 1000) + month;
         This way they will be correctly ordered chronologically regardless of the actual name of the month.
         */
        NSCalendar *calendar = [NSCalendar currentCalendar];
        NSDateComponents *components = [calendar components:(NSYearCalendarUnit | NSMonthCalendarUnit| NSDayCalendarUnit ) fromDate:[self date]];
        tmp = [NSString stringWithFormat:@"%d", ([components year] * 10000) + [components month] * 100 +[components day]];
        [self setPrimitiveSectionIdentifier:tmp];
    }
    return tmp;
}


////////////////////////////////////////
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
//- (NSString *)name
//{
//    if (!_name && [_name isEqualToString:@""]) {
//        _name = [NSString stringWithFormat:@"%@ at %@", self.artist.name, self.venue.name];
//    }
//    return _name;
//}
//
//-(void)setName:(NSString *)name
//{
//    [self willChangeValueForKey:@"title"];
//    [self willChangeValueForKey:@"name"];
//    _name = name;
//    [self didChangeValueForKey:@"title"];
//    [self didChangeValueForKey:@"name"];
//}








///////////////////////////////////////////////////////////////////////////
//lat and long are stored in CoreData as double/NSNumbers
//we just put them together as a CLLocationCoordinate2D
///////////////////////////////////////////////////////////////////////////
-(CLLocationCoordinate2D)location
{
    return CLLocationCoordinate2DMake([self.latitude doubleValue], [self.longitude doubleValue]);
}

-(void)setLocation:(CLLocationCoordinate2D)location
{
    _location = location;
    self.latitude  = [NSNumber numberWithDouble:location.latitude];
    self.longitude = [NSNumber numberWithDouble:location.longitude];
}







///////////////////////////////////////////////////////////////////////////////////////////
//@property latitude et longitude sont remplies lors de l'appel à l'API
//@property coordinate est juste required par <MKAnnotation> mais readonly donc il suffit d'implémenter le getter
//Dans JIPConcertDetailsVC (conforme à <MKMapViewDelegate>), c'est -viewForAnnotation qui réclame un object conforme à <MKAnnotation>
//et qui va donc chercher la @property "coordinate", on lui renvoie @property location qui est du même type
-(CLLocationCoordinate2D)coordinate
{
    return self.location;
}

-(NSString *)title
{
    return self.venue.name;
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

//////////////////////////////////////////
//////////////////////////////////////////
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


@end
