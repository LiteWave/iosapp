//
//  ReadyViewController.h
//  LiteWave
//
//  Created by mike draghici on 10/24/13.
//  Copyright (c) 2013 LiteWave. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ReadyViewController : UIViewController <UIAlertViewDelegate> {
    
    IBOutlet UILabel *eventName;
    IBOutlet UILabel *eventDate;
    IBOutlet UILabel *mySeat;
    IBOutlet UIButton *playBtn;
    IBOutlet UIButton *retryBtn;
}

@property (nonatomic, assign) NSTimer* timer;

-(void)withdraw;

@end
