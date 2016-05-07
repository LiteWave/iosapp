//
//  ResultsViewController.h
//  LiteWave
//
//  Copyright (c) 2013 LiteWave. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "LWFAppDelegate.h"

@interface LWFResultsController : UIViewController {
    BOOL isWinner;  // device is a winner!
    CGSize appSize;
    
    IBOutlet UIButton *returnButton;
    IBOutlet UIImageView *imageView;
    IBOutlet UILabel *participationLabel;
    IBOutlet UILabel *poweredByLabel;
    IBOutlet UIImageView *logoImageView;
}

@property (nonatomic, retain) LWFAppDelegate *appDelegate;

@end

