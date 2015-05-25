//
//  EventsViewController.h
//  LiteWave
//
//  Created by mike draghici on 10/24/13.
//  Copyright (c) 2013 LiteWave. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface EventsViewController : UIViewController <UIPickerViewDataSource, UIPickerViewDelegate> {
    
    NSMutableData *webData;
	NSMutableString *jsonResults;
	NSURLConnection *theConnection;
    IBOutlet UIPickerView *eventsPicker;
    IBOutlet UIButton *continueBtn;
    IBOutlet UIActivityIndicatorView *spinner;
    
}

@end
