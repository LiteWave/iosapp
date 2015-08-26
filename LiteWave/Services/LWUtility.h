//
//  LWUtility.h
//  LiteWave
//
//  Created by David Anderson on 8/22/15.
//  Copyright (c) 2015 LightWave. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface LWUtility : NSObject

+(BOOL)isToday:(NSDate*)date;
+(BOOL)isTodayGreaterThanDate:(NSDate*)date;
+(UIColor*)getColorFromString:(NSString*)color;
+(NSString*)getStringFromColor:(UIColor*)color;

@end
