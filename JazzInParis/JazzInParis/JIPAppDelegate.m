//
//  JIPAppDelegate.m
//  JazzInParis
//
//  Created by Max on 02/02/14.
//  Copyright (c) 2014 Max. All rights reserved.
//

#import "JIPAppDelegate.h"
#import "JIPUpComingEventsViewController.h"
#import "JIPUpcomingEventsCDTVC.h"
#import "JIPFavoriteArtistTableViewController.h"
#import "JIPSearchArtistsViewController.h"
#import "JIPUpdateManager.h"
#import "JIPManagedDocument.h"
#import "JIPVenue+Create.h"

@implementation JIPAppDelegate

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleLightContent];
    
    //Configure PageController
    UIPageControl *pageControl = [UIPageControl appearance];
    pageControl.pageIndicatorTintColor = [UIColor whiteColor];
    pageControl.currentPageIndicatorTintColor = [UIColor orangeColor];
    pageControl.backgroundColor = [UIColor blackColor];
    
    //Is it first launch ??
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    if (![userDefaults objectForKey:@"firstLaunch"])
    {
        [userDefaults setBool:YES forKey:@"firstLaunch"];
    }
    
    
    [[JIPUpdateManager sharedUpdateManager] clearOldEvents];
    [[JIPUpdateManager sharedUpdateManager] updateUpcomingEvents];
    
    //Insert all jazz clubs in Paris into Core Data
    [[JIPManagedDocument sharedManagedDocument] performBlockWithDocument:^(JIPManagedDocument *managedDocument) {
        
        NSDictionary *baiserSaleDict = [[NSDictionary alloc] initWithObjectsAndKeys:
                                        @(-1)                         ,  @"id",
                                        @"Baiser Salé"                ,  @"name",
                                        @"Paris"                      ,  @"city",
                                        @"58, rue des Lombards"       ,  @"street",
                                        @"+33 1 42 33 37 71"          ,  @"phone",
                                        @"http://www.lebaisersale.com",  @"websiteString",
                                        @"48.859722222222224"         ,  @"lat",
                                        @"2.348055555555556"          ,  @"long",
                                        nil];
        NSDictionary *newMorningDict = [[NSDictionary alloc] initWithObjectsAndKeys:
                                        @(-2)                           ,  @"id",
                                        @"New Morning"                  ,  @"name",
                                        @"Paris"                        ,  @"city",
                                        @"7 & 9 Rue des Petites Ecuries",  @"street",
                                        @"+33 (0)1 45 23 51 41"         ,  @"phone",
                                        @"http://www.newmorning.com"    ,  @"websiteString",
                                        @"48.87305555555555"            ,  @"lat",
                                        @"2.3525"                       ,  @"long",
                                        nil];
        
        NSDictionary *ducDesLombards = [[NSDictionary alloc] initWithObjectsAndKeys:
                                        @(-3)                           ,  @"id",
                                        @"Duc des Lombards"             ,  @"name",
                                        @"Paris"                        ,  @"city",
                                        @"42 rue des Lombards"          ,  @"street",
                                        @"+33 (0)1 42 33 22 88"         ,  @"phone",
                                        @"http://www.ducdeslombards.com",  @"websiteString",
                                        @"48.859722222222224"           ,  @"lat",
                                        @"2.348611111111111"            ,  @"long",
                                        nil];
        NSDictionary *sunsetSunside = [[NSDictionary alloc] initWithObjectsAndKeys:
                                        @(-4)                           ,  @"id",
                                        @"Sunset/Sunside"               ,  @"name",
                                        @"Paris"                        ,  @"city",
                                        @"60, rue des Lombards"         ,  @"street",
                                        @"+33 (0)1 40 26 46 60"         ,  @"phone",
                                        @"http://www.sunset-sunside.com",  @"websiteString",
                                        @"48.859722222222224"           ,  @"lat",
                                        @"2.347777777777778"            ,  @"long",
                                        nil];
        NSDictionary *jazzClubEtoile = [[NSDictionary alloc] initWithObjectsAndKeys:
                                       @(-5)                            ,  @"id",
                                       @"Jazz Club Etoile"              ,  @"name",
                                       @"Paris"                         ,  @"city",
                                       @"81 Boulevard Gouvion-Saint-Cyr",  @"street",
                                       @"+33 (0)1 40 68 30 42"          ,  @"phone",
                                       @"http://www.jazzclub-paris.com" ,  @"websiteString",
                                       @"48.87973683333333"             ,  @"lat",
                                       @"2.285047"                      ,  @"long",
                                       nil];
        NSDictionary *Le38Riv = [[NSDictionary alloc] initWithObjectsAndKeys:
                                        @(-6)                            ,  @"id",
                                        @"Le 38 Riv'"                    ,  @"name",
                                        @"Paris"                         ,  @"city",
                                        @"38 Rue de Rivoli"              ,  @"street",
                                        @"+33 (0)1 48 87 56 30"          ,  @"phone",
                                        @"http://www.38riv.com"          ,  @"websiteString",
                                        @"48.85666666666667"             ,  @"lat",
                                        @"2.3565"                        ,  @"long",
                                        nil];
        NSDictionary *hotelLutetia = [[NSDictionary alloc] initWithObjectsAndKeys:
                                         @(-7)                            ,  @"id",
                                         @"Hôtel Lutetia"                 ,  @"name",
                                         @"Paris"                         ,  @"city",
                                         @"45, boulevard Raspail"         ,  @"street",
                                         @"+33 (0)1 49 54 46 46"          ,  @"phone",
                                         @"http://www.lutetia.concorde-hotels.fr",  @"websiteString",
                                         @"48.85122222222222"             ,  @"lat",
                                         @"2.3271944444444443"            ,  @"long",
                                         nil];
        NSDictionary *caveauHuch = [[NSDictionary alloc] initWithObjectsAndKeys:
                                      @(-8)                            ,  @"id",
                                      @"Caveau de la Huchette"         ,  @"name",
                                      @"Paris"                         ,  @"city",
                                      @"5 Rue de la Huchette"          ,  @"street",
                                      @"+33 (0)1 43 26 65 05"          ,  @"phone",
                                      @"http://www.caveaudelahuchette.fr",  @"websiteString",
                                      @"48.852777777777774"            ,  @"lat",
                                      @"2.346388888888889"             ,  @"long",
                                      nil];
        NSDictionary *caveauOubl = [[NSDictionary alloc] initWithObjectsAndKeys:
                                    @(-9)                            ,  @"id",
                                    @"Caveau des Oubliettes"         ,  @"name",
                                    @"Paris"                         ,  @"city",
                                    @"52 rue Galande"          ,  @"street",
                                    @"+33 (0)1 46 34 23 09"          ,  @"phone",
                                    @"http://www.caveaudesoubliettes.fr",  @"websiteString",
                                    @"48.852222222222224"            ,  @"lat",
                                    @"2.34675"             ,  @"long",
                                    nil];
        NSDictionary *cafeLaurent = [[NSDictionary alloc] initWithObjectsAndKeys:
                                    @(-10)                            ,  @"id",
                                    @"Cafe Laurent"         ,  @"name",
                                    @"Paris"                         ,  @"city",
                                    @"33 Rue Dauphine"          ,  @"street",
                                    @"+33 (0)1 43 29 43 43"          ,  @"phone",
                                    @"http://www.hoteldaubusson.com/services/concert-jazz",  @"websiteString",
                                    @"48.855"                     ,  @"lat",
                                    @"2.3395277777777777"             ,  @"long",
                                    nil];
        NSDictionary *petitJournalStMich = [[NSDictionary alloc] initWithObjectsAndKeys:
                                     @(-11)                            ,  @"id",
                                     @"Le Petit Journal St Michel"         ,  @"name",
                                     @"Paris"                         ,  @"city",
                                     @"71, boulevard Saint-Michel"          ,  @"street",
                                     @"+33 (0)1 43 26 28 59"          ,  @"phone",
                                     @"http://claude.philips.pagesperso-orange.fr/index.htm",  @"websiteString",
                                     @"48.84661111111111"                     ,  @"lat",
                                     @"2.3405555555555555"             ,  @"long",
                                     nil];
        NSDictionary *autourDeMidi = [[NSDictionary alloc] initWithObjectsAndKeys:
                                    @(-12)                            ,  @"id",
                                    @"Autour de Midi"         ,  @"name",
                                    @"Paris"                         ,  @"city",
                                    @"11 Rue Lepic"          ,  @"street",
                                    @"+33 (0)1 55 79 16 48"          ,  @"phone",
                                    @"http://www.autourdemidi.fr",  @"websiteString",
                                    @"48.88483333333333"                     ,  @"lat",
                                    @"2.3335"             ,  @"long",
                                    nil];
        NSDictionary *limproviste = [[NSDictionary alloc] initWithObjectsAndKeys:
                                      @(-13)                            ,  @"id",
                                      @"Péniche l'Improviste"         ,  @"name",
                                      @"Paris"                         ,  @"city",
                                      @"Place Paul Delouvrier"          ,  @"street",
                                      @"+33 (0)6 86 46 60 89"          ,  @"phone",
                                      @"http://www.improviste.fr",  @"websiteString",
                                      @"48.89213888888889"                     ,  @"lat",
                                      @"2.3850555555555557"             ,  @"long",
                                      nil];
        NSDictionary *babilo = [[NSDictionary alloc] initWithObjectsAndKeys:
                                     @(-14)                            ,  @"id",
                                     @"Bab-ilo"         ,  @"name",
                                     @"Paris"                         ,  @"city",
                                     @"9 Rue du Baigneur"          ,  @"street",
                                     @"+33 (0)1 42 23 99 19"          ,  @"phone",
                                     @"http://www.babilo.lautre.net",  @"websiteString",
                                     @"48.89030555555556"                     ,  @"lat",
                                     @"2.34475"             ,  @"long",
                                     nil];
        NSDictionary *les3arts = [[NSDictionary alloc] initWithObjectsAndKeys:
                                @(-15)                            ,  @"id",
                                @"Les 3 arts"         ,  @"name",
                                @"Paris"                         ,  @"city",
                                @"21 Rue des Rigoles"          ,  @"street",
                                @"+33 (0)1 43 49 36 27"          ,  @"phone",
                                @"http://www.les3arts.free.fr",  @"websiteString",
                                @"48.87188888888889"                     ,  @"lat",
                                @"2.3939166666666667"             ,  @"long",
                                nil];
        NSDictionary *leBoeufSurLeToit = [[NSDictionary alloc] initWithObjectsAndKeys:
                                  @(-16)                            ,  @"id",
                                  @"Le Boeuf sur le toit"         ,  @"name",
                                  @"Paris"                         ,  @"city",
                                  @"34 rue du Colisée"          ,  @"street",
                                  @"+33 (0)1 45 23 51 41"          ,  @"phone",
                                  @"http://www.boeufsurletoit.com"     ,  @"websiteString",
                                  @"48.87161111111111"                     ,  @"lat",
                                  @"2.3105"             ,  @"long",
                                  nil];
        NSDictionary *lePetitJournalMtPar = [[NSDictionary alloc] initWithObjectsAndKeys:
                                          @(-17)                            ,  @"id",
                                          @"Le Petit Journal Montparnasse"         ,  @"name",
                                          @"Paris"                         ,  @"city",
                                          @"13 Rue du Commandant René Mouchotte"          ,  @"street",
                                          @"+33 (0)1 43 21 56 70"          ,  @"phone",
                                          @"http://www.petitjournalmontparnasse.com"     ,  @"websiteString",
                                          @"48.839305555555555"                     ,  @"lat",
                                          @"2.320972222222222"             ,  @"long",
                                          nil];
        NSDictionary *caféUniversel = [[NSDictionary alloc] initWithObjectsAndKeys:
                                             @(-18)                            ,  @"id",
                                             @"Le Café Universel"         ,  @"name",
                                             @"Paris"                         ,  @"city",
                                             @"267 rue Saint Jacques"          ,  @"street",
                                             @"+33 (0)1 43 25 74 20"          ,  @"phone",
                                             @"http://www.cafeuniversel.com"     ,  @"websiteString",
                                             @"48.84186111111111"                     ,  @"lat",
                                             @"2.3414722222222224"             ,  @"long",
                                             nil];
        NSDictionary *atelierCharonne = [[NSDictionary alloc] initWithObjectsAndKeys:
                                       @(-19)                            ,  @"id",
                                       @"L'Atelier Charonne"         ,  @"name",
                                       @"Paris"                         ,  @"city",
                                       @"21 Rue de Charonne"          ,  @"street",
                                       @"+33 (0)1 40 21 83 35"          ,  @"phone",
                                       @"http://www.ateliercharonne.com"     ,  @"websiteString",
                                       @"48.85336111111111"                     ,  @"lat",
                                       @"2.374888888888889"             ,  @"long",
                                       nil];
        NSDictionary *chezPapa = [[NSDictionary alloc] initWithObjectsAndKeys:
                                         @(-20)                            ,  @"id",
                                         @"Chez Papa Jazz Club"         ,  @"name",
                                         @"Paris"                         ,  @"city",
                                         @"3 rue Saint Benoit"          ,  @"street",
                                         @"+33 (0)1 42 86 99 63"          ,  @"phone",
                                         @"http://www.papajazzclub.fr"     ,  @"websiteString",
                                         @"48.855583333333335"                     ,  @"lat",
                                         @"2.3334166666666665"             ,  @"long",
                                         nil];
        NSDictionary *leRagueneau = [[NSDictionary alloc] initWithObjectsAndKeys:
                                  @(-21)                            ,  @"id",
                                  @"Le Ragueneau"         ,  @"name",
                                  @"Paris"                         ,  @"city",
                                  @"202 Rue Saint-Honoré"          ,  @"street",
                                  @"+33 (0)1 42 60 29 20"          ,  @"phone",
                                  @"http://www.ragueneau.fr"     ,  @"websiteString",
                                  @"48.86277777777778"                     ,  @"lat",
                                  @"2.3375833333333333"             ,  @"long",
                                  nil];
        NSDictionary *leSpeakEasy = [[NSDictionary alloc] initWithObjectsAndKeys:
                                     @(-22)                            ,  @"id",
                                     @"Le Speakeasy"         ,  @"name",
                                     @"Paris"                         ,  @"city",
                                     @"25 Rue Jean Giraudoux"          ,  @"street",
                                     @"+33 (0)1 47 23 47 22"          ,  @"phone",
                                     @"http://www.lespeakeasy.com/"     ,  @"websiteString",
                                     @"48.86969444444444"                     ,  @"lat",
                                     @"2.296638888888889"             ,  @"long",
                                     nil];
        
        NSArray *allJazzClubsInParis = [NSArray arrayWithObjects:baiserSaleDict, newMorningDict, ducDesLombards, sunsetSunside, jazzClubEtoile, Le38Riv, hotelLutetia, caveauHuch, caveauOubl, cafeLaurent, petitJournalStMich, autourDeMidi, limproviste, babilo, les3arts, leBoeufSurLeToit, lePetitJournalMtPar, caféUniversel, atelierCharonne, chezPapa, leRagueneau, leSpeakEasy, nil];
        
        for (NSMutableDictionary * jazzClubDict in allJazzClubsInParis)
        {
            [JIPVenue venueWithDict:jazzClubDict inManagedObjectContext:managedDocument.managedObjectContext];
        }
    }];

    
    return YES;
}



@end
