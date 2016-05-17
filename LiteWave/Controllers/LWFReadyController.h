//
//  ReadyViewController.h
//  LiteWave
//
//  Copyright (c) 2013 LiteWave. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "LWFAppDelegate.h"

@interface LWFReadyController : UIViewController <UIAlertViewDelegate> {
    
    IBOutlet UIButton *joinButton;
    IBOutlet UILabel *waitLabel;
    IBOutlet UIActivityIndicatorView *spinner;
    IBOutlet UIImageView *imageView;
    
    BOOL pressedChangeSeat;
    BOOL created;
    CGSize appSize;
}

@property (nonatomic, retain) LWFAppDelegate *appDelegate;
@property (nonatomic, assign) NSTimer* timer;

-(void)withdraw;

@end
