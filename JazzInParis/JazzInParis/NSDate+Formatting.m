//
//  NSDate+NSDate_Formatting.m
//  JazzInParis
//
//  Created by Max on 12/02/14.
//  Copyright (c) 2014 Max. All rights reserved.
//

#import "NSDate+Formatting.h"

@implementation NSDate (Formatting)

////////////////////////////////////////////
//////////// DATE FORMAT METHOD ////////////
///////////////////////////////////////////
+(NSString *)stringFromDate:(NSDate *)date
{
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    dateFormatter.dateStyle = NSDateFormatterLongStyle;
    NSString *string = [dateFormatter stringFromDate:date];
    return string;
}

+(NSDate *)dateFromString:(NSString *)stringDate
{
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    dateFormatter.dateFormat = @"EE, d LLLL yyyy HH:mm:ss Z";
    NSDate *date = [dateFormatter dateFromString:stringDate];
    return date;
}

+(NSDate *)dateFromAPIString:(NSString *)stringDate
{
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    dateFormatter.dateFormat = @"yyyy-MM-dd";
    NSDate *date = [dateFormatter dateFromString:stringDate];
    return date;
}

@end
