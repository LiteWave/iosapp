//
//  LWUtility.m
//  LiteWave
//
//  Created by David Anderson on 8/22/15.
//  Copyright (c) 2015 LightWave. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "LWFUtility.h"

@implementation LWFUtility

+(BOOL)isToday:(NSDate*)date {
    NSDate *today = [NSDate date];
    NSTimeZone *myTimeZone = [NSTimeZone localTimeZone];
    
    // Set up dates and zone, then do this
    NSCalendar *calendar = [[NSCalendar alloc] initWithCalendarIdentifier:NSCalendarIdentifierGregorian];
    [calendar setTimeZone:myTimeZone];
    return [calendar isDate:today inSameDayAsDate:date];
}

+(BOOL)isTodayLessThanDate:(NSDate*)date todayOffsetInMilliseconds:(int)offset {
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
    interval = destinationGMTOffset - sourceGMTOffset - offset/1000;
    
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

+(NSString*)getTodayInGMT {
    NSDateFormatter *dateformat = [[NSDateFormatter alloc] init];
    [dateformat setDateFormat:@"yyyy-MM-dd'T'HH:mm:ss.SSS'Z'"];
    [dateformat setTimeZone:[NSTimeZone timeZoneWithName:@"GMT"]];
    
    return [dateformat stringFromDate:[NSDate date]];
}

+(UIColor*)getColorFromString:(NSString*)color {
    NSArray *colorItems = [color componentsSeparatedByString:@","];
    
    float red = [[colorItems objectAtIndex:0] doubleValue];
    float green = [[colorItems objectAtIndex:1] doubleValue];
    float blue = [[colorItems objectAtIndex:2] doubleValue];
    
    return [UIColor colorWithRed:red/255.0 green:green/255.0 blue:blue/255.0 alpha:1];
}

+(NSString*)getStringFromColor:(UIColor*)color {
    if (color) {
        const CGFloat *components = CGColorGetComponents(color.CGColor);
        NSLog(@"%@", [NSString stringWithFormat:@"%i,%i,%i", (int)(components[0]*255), (int)(components[1]*255), (int)(components[2]*255)]);
        return [NSString stringWithFormat:@"%i,%i,%i", (int)(components[0]*255), (int)(components[1]*255), (int)(components[2]*255)];
    } else {
        return @"255,255,255";
    }
}

+(CGSize)determineAppSize:(UIViewController*)controller {
    CGSize appSize = controller.view.frame.size;
    
    if (controller.tabBarController != nil) {
        CGSize tsize = controller.tabBarController.tabBar.frame.size;
        appSize.height -= MIN(tsize.width, tsize.height);
    }
    return appSize;
}

+(UIStoryboard*)getStoryboard:(UIViewController*)controller {
    NSBundle* bundle;
    @try {
        bundle = [NSBundle bundleWithURL:[[NSBundle mainBundle]URLForResource:@"LiteWave"
                                                                withExtension:@"bundle"]];
    } @catch (NSException *e) {
        NSLog(@"Litewave bundle not available");
        bundle = [NSBundle bundleForClass:controller.class];
    } @finally {
        return [UIStoryboard storyboardWithName:@"LWFMain"
                                         bundle:bundle];
    }
}




@end