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

@end