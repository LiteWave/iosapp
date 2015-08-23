//
//  ResultsViewController.h
//  LiteWave
//
//  Created by mike draghici on 10/24/13.
//  Copyright (c) 2013 LiteWave. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "LWAppDelegate.h"

@interface LWResultsController : UIViewController {
    BOOL isWinner;  // device is a winner!
    
    IBOutlet UIButton *returnButton;
    IBOutlet UIImageView *imageView;
    IBOutlet UILabel *participationLabel;
}

@property (nonatomic, retain) LWAppDelegate *appDelegate;

@end

