//
//  LWUtility.h
//  LiteWave
//
//  Created by David Anderson on 8/22/15.
//  Copyright (c) 2015 LightWave. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

@interface LWFUtility : NSObject

+(BOOL)isToday:(NSDate*)date;
+(BOOL)isTodayLessThanDate:(NSDate*)date todayOffsetInMilliseconds:(int)offset;
+(NSString*)getTodayInGMT;
+(UIColor*)getColorFromString:(NSString*)color;
+(NSString*)getStringFromColor:(UIColor*)color;

@end
