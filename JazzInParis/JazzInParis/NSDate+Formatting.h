//
//  NSDate+NSDate_Formatting.h
//  JazzInParis
//
//  Created by Max on 12/02/14.
//  Copyright (c) 2014 Max. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSDate (Formatting)

+(NSString *)stringFromDate:(NSDate *)date;
+(NSDate *)dateFromString:(NSString *)stringDate;

@end
