//
//  LiteWaveController.h
//  LiteWave
//
//  Copyright (c) 2013 LiteWave. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "LWAppDelegate.h"

@interface LWAppController : UIViewController {
    
}

@property (nonatomic, retain) LWAppDelegate *appDelegate;

- (void)getEvent;
- (void)clearEvent;
- (void)saveEvent:(id)event;
- (void)beginEvent:(NSString*)eventID;
- (void)showNoEvent;

@end
