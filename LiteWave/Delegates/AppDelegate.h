//
//  LiteWaveAppDelegate.h
//  LiteWave
//
//  Created by mike draghici on 10/24/13.
//  Copyright (c) 2013 LiteWave. All rights reserved.
//

#import <UIKit/UIKit.h>

@class Reachability;

@interface AppDelegate : UIResponder <UIApplicationDelegate> {
    
    Reachability* hostReach;
    Reachability* internetReach;
    Reachability* wifiReach;
    UIAlertView *errorView;
    
}

@property (strong, nonatomic) UIWindow *window;
@property (nonatomic, assign) BOOL isOnline;
@property (nonatomic, assign) BOOL invalidShowAlert;
@property (nonatomic, strong) NSString *uniqueID;
@property (nonatomic, strong) NSString *clientID;
@property (nonatomic, strong) NSString *eventID;
@property (nonatomic, strong) NSString *eventName;
@property (nonatomic, strong) NSDate *eventDate;
@property (nonatomic, strong) NSString *stadiumID;
@property (nonatomic, strong) NSString *sectionID;
@property (nonatomic, strong) NSString *rowID;
@property (nonatomic, strong) NSString *seatID;
@property (nonatomic, strong) NSString *winnerID;
@property (nonatomic, strong) NSArray *liteshowArray;
@property (nonatomic, strong) NSString *userID;
@property (nonatomic, strong) NSArray *eventsArray;
@property (nonatomic, strong) NSDictionary *seatsArray;
@property (nonatomic, strong) NSDictionary *liteShow;
@property (nonatomic, strong) NSDictionary *eventJoinData;

@end
