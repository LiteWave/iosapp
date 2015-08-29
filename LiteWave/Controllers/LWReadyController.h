//
//  ReadyViewController.h
//  LiteWave
//
//  Created by mike draghici on 10/24/13.
//  Copyright (c) 2013 LiteWave. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "LWAppDelegate.h"

@interface LWReadyController : UIViewController <UIAlertViewDelegate> {
    
    IBOutlet UIButton *changeButton;
    IBOutlet UIButton *joinButton;
    IBOutlet UILabel *waitLabel;
    IBOutlet UIActivityIndicatorView *spinner;
    
    BOOL pressedChangeSeat;
}

@property (nonatomic, retain) LWAppDelegate *appDelegate;

-(void)withdraw;

@end
