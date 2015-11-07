//
//  Configuration.h
//  LiteWave
//
//  Created by David Anderson on 5/25/15.
//  Copyright (c) 2015 LightWave. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface LWConfiguration : NSObject {
}

@property (nonatomic, retain) NSMutableDictionary *properties;

@property (nonatomic, assign) BOOL isOnline;
@property (nonatomic, strong) NSString *apiURL;
@property (nonatomic, strong) NSString *clientID;
@property (nonatomic, strong) NSString *eventID;
@property (nonatomic, strong) NSString *eventName;
@property (nonatomic, strong) NSDate *eventDate;
@property (nonatomic, strong) NSString *stadiumID;
@property (nonatomic, strong) NSString *levelID;
@property (nonatomic, strong) NSString *sectionID;
@property (nonatomic, strong) NSString *rowID;
@property (nonatomic, strong) NSString *seatID;
@property (nonatomic, strong) NSString *userID;
@property (nonatomic, strong) NSString *userLocationID;
@property (nonatomic, strong) NSDictionary *levels;
@property (nonatomic, strong) NSDictionary *seats;
@property (nonatomic, strong) NSDictionary *show;
@property (nonatomic, strong) NSDictionary *showData;

@property (nonatomic, strong) UIColor *defaultColor; // if no event returned, will use this color
@property (nonatomic, strong) UIColor *backgroundColor;
@property (nonatomic, strong) UIColor *highlightColor;
@property (nonatomic, strong) UIColor *borderColor;
@property (nonatomic, strong) UIColor *textColor;
@property (nonatomic, strong) UIColor *textSelectedColor;

@property (nonatomic, strong) NSString *logoUrl;
@property (nonatomic, strong) UIImage *logoImage;

+ (LWConfiguration*)instance;

- (id)get:(NSString*)property;
- (void)set:(NSString*)property value:(id)value;

@end
