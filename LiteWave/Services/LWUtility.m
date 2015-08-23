//
//  LWUtility.m
//  LiteWave
//
//  Created by David Anderson on 8/22/15.
//  Copyright (c) 2015 LightWave. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "LWUtility.h"

@implementation LWUtility

+ (NSString*)getToday {
    NSTimeZone *currentTimeZone = [NSTimeZone localTimeZone];
    NSDate *todayDate = [NSDate date];
    NSDateFormatter *dayformat = [[NSDateFormatter alloc] init];
    [dayformat setDateFormat:@"dd"];
    [dayformat setTimeZone:[NSTimeZone timeZoneWithName:currentTimeZone.abbreviation]];
    
    return [dayformat stringFromDate:todayDate];
}

+(BOOL)isToday:(NSDate*)date {
    NSDate *today = [NSDate date];
    NSTimeZone *myTimeZone = [NSTimeZone localTimeZone];
    
    // Set up dates and zone, then do this
    NSCalendar *calendar = [[NSCalendar alloc] initWithCalendarIdentifier:NSCalendarIdentifierGregorian];
    [calendar setTimeZone:myTimeZone];
    return [calendar isDate:today inSameDayAsDate:date];
}

+(BOOL)isTodayGreaterThanDate:(NSDate*)date {
    NSTimeZone* sourceTimeZone = [NSTimeZone timeZoneWithName:@"GMT"];
    NSTimeZone* destinationTimeZone = [NSTimeZone systemTimeZone];
    
    //calc time difference
    NSInteger sourceGMTOffset = [sourceTimeZone secondsFromGMTForDate:date];
    NSInteger destinationGMTOffset = [destinationTimeZone secondsFromGMTForDate:date];
    NSTimeInterval interval = destinationGMTOffset - sourceGMTOffset;
    
    //set current real date
    NSDate* checkDate = [[NSDate alloc] initWithTimeInterval:interval sinceDate:date];
    
    //
    NSDate *today = [NSDate date];
    sourceTimeZone = [NSTimeZone systemTimeZone];
    destinationTimeZone = [NSTimeZone timeZoneWithName:@"GMT"];
    
    sourceGMTOffset = [destinationTimeZone secondsFromGMTForDate:today];
    destinationGMTOffset = [sourceTimeZone secondsFromGMTForDate:today];
    interval = destinationGMTOffset - sourceGMTOffset;
    
    NSDate* todayDate = [[NSDate alloc] initWithTimeInterval:interval sinceDate:today];

    NSComparisonResult result = [checkDate compare:todayDate];
    switch (result)
    {
        case NSOrderedAscending:
            return NO;
            break;
        case NSOrderedDescending:
            return YES;
            break;
        case NSOrderedSame:
            return NO;
            break;
        default:
            return NO;
    }
}

@end