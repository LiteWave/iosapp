//
//  LiteWaveController.h
//  LiteWave
//
//  Copyright (c) 2013 LiteWave. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "AppDelegate.h"

@interface LiteWaveController : UIViewController {
    
}

@property (nonatomic, retain) AppDelegate *appDelegate;

- (void)getEvent;
- (void)clearEvent;
- (void)saveEvent:(id)event;
- (void)beginEvent:(NSString*)eventID;
- (void)showNoEvent;

@end
