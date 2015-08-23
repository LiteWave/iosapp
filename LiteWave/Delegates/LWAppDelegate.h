//
//  LiteWaveAppDelegate.h
//  LiteWave
//
//  Created by mike draghici on 10/24/13.
//  Copyright (c) 2013 LiteWave. All rights reserved.
//

#import <UIKit/UIKit.h>

@class Reachability;

@interface LWAppDelegate : UIResponder <UIApplicationDelegate> {
    
    Reachability* hostReach;
    Reachability* internetReach;
    Reachability* wifiReach;
}

@property (strong, nonatomic) UIWindow *window;
@property (nonatomic, assign) BOOL isOnline;
@property (nonatomic, strong) NSString *apiURL;
@property (nonatomic, strong) NSString *uniqueID;
@property (nonatomic, strong) NSString *clientID;
@property (nonatomic, strong) NSString *eventID;
@property (nonatomic, strong) NSString *eventName;
@property (nonatomic, strong) NSDate *eventDate;
@property (nonatomic, strong) NSString *stadiumID;
@property (nonatomic, strong) NSString *levelID;
@property (nonatomic, strong) NSString *sectionID;
@property (nonatomic, strong) NSString *rowID;
@property (nonatomic, strong) NSString *seatID;
@property (nonatomic, strong) NSString *winnerID;
@property (nonatomic, strong) NSString *userID;
@property (nonatomic, strong) NSDictionary *seatsArray;
@property (nonatomic, strong) NSDictionary *show;
@property (nonatomic, strong) NSDictionary *showData;

@property (nonatomic, strong) UIColor *backgroundColor;
@property (nonatomic, strong) UIColor *highlightColor;
@property (nonatomic, strong) UIColor *borderColor;
@property (nonatomic, strong) UIColor *textColor;
@property (nonatomic, strong) UIColor *textSelectedColor;

@end
