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

@end
