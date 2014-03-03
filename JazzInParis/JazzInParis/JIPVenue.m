//
//  JIPVenue.m
//  JazzInParis
//
//  Created by Max on 11/02/14.
//  Copyright (c) 2014 Max. All rights reserved.
//

#import "JIPVenue.h"

@implementation JIPVenue

@dynamic id;
@dynamic name;
@dynamic desc;
@dynamic city;
@dynamic street;
@dynamic phone;
@dynamic location;
@dynamic websiteString;
@dynamic capacity;
@dynamic events;
@dynamic distanceFromUserToVenue;

////////////////////////////////////////
-(id)init
{
    return [self initWithID:@1
                       name:@"Default Description"
                description:@"Default Description"
                       city:@"Default Description"
                     street:@"Default Description"
                      phone:@"Default Description"
                    website:[NSURL URLWithString:@"www.defaultURL.com"]
                   capacity:@2000];
}

////////////////////////////////////////
- (instancetype)initWithID:(NSNumber *)id
                       name:(NSString *)name
                description:(NSString *)desc
                       city:(NSString *)city
                     street:(NSString *)street
                      phone:(NSString *)phone
                    website:(NSURL *)website
                   capacity:(NSNumber *)capacity
{
    self = [super init];
    if (self)
    {
        self.id = id;
        self.name = name;
        self.desc = desc;
        self.city = city;
        self.street = street;
        self.phone = phone;
        self.websiteString = website;
        self.capacity = capacity;
    }
    return self;
}

///////////////////////////////////////////////////////////////////////
#pragma mark - MKAnotation
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

-(NSString *)subtitle
{
    return [NSString stringWithFormat:@"%ld meters away", lroundf(self.distanceFromUserToVenue)];
}

@end
