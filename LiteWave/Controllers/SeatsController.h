//
//  SeatsViewController.h
//  LiteWave
//
//  Created by mike draghici on 10/24/13.
//  Copyright (c) 2013 LiteWave. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface SeatsController : UIViewController <UIPickerViewDataSource, UIPickerViewDelegate> {
    
    NSMutableData *webData;
	NSMutableString *jsonResults;
	NSURLConnection *theConnection;
    IBOutlet UIPickerView *seatsPicker;
    IBOutlet UIButton *registerButton;
    IBOutlet UIActivityIndicatorView *spinner;
    IBOutlet UILabel *actionTitle;
    
    NSMutableArray *sections;
    NSDictionary *sectionDictionary;
    NSArray *sectionArray;
    NSMutableArray *rows;
    NSDictionary *rowDictionary;
    NSArray *rowArray;
    NSMutableArray *seats;
    NSDictionary *seatDictionary;
    NSArray *seatArray;
    
    BOOL pickedSection;
    BOOL pickedRow;
    BOOL pickedSeat;
    
    int selectedSectionIndex;
    int selectedRowIndex;
    int selectedSeatIndex;
    
}

@end
