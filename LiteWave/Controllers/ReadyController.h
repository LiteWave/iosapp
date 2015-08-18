//
//  ReadyViewController.h
//  LiteWave
//
//  Created by mike draghici on 10/24/13.
//  Copyright (c) 2013 LiteWave. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "AppDelegate.h"

@interface ReadyController : UIViewController <UIAlertViewDelegate> {
    
    IBOutlet UILabel *eventName;
    IBOutlet UILabel *eventDate;
    IBOutlet UILabel *mySeat;    
    IBOutlet UIButton *changeButton;
    IBOutlet UIButton *joinButton;
    
    BOOL pressedChangeSeat;
}

@property (nonatomic, retain) AppDelegate *appDelegate;

-(void)updateSettings;
-(void)withdraw;

@end
