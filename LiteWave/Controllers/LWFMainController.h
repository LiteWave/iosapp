//
//  LiteWaveController.h
//  LiteWave
//
//  Copyright (c) 2013 LiteWave. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "LWFAppDelegate.h"

@interface LWFMainController : UIViewController {
    IBOutlet UILabel *unavailableLabel;
    IBOutlet UILabel *poweredByLabel;
    IBOutlet UIImageView *logoImageView;
    IBOutlet UIImageView *imageView;
    
    CGSize appSize;
    BOOL created;
}

@property (nonatomic, retain) LWFAppDelegate *appDelegate;

- (void)getEvent;
- (void)clearEvent;
- (void)saveEvent:(id)event;
- (void)updateDefaults;
- (void)beginEvent:(NSString*)eventID;
- (void)handleNoEvent;
- (void)onBecomeActive;

@end
