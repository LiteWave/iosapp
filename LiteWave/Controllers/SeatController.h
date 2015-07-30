//
//  SeatController.h
//  LiteWave
//
//  Created by David Anderson on 7/26/15.
//  Copyright (c) 2015 LightWave. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface SeatController : UIViewController <UITableViewDelegate, UITableViewDataSource> {
    
    IBOutlet UIButton *nextButton;
    
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
    
    BOOL pickedSection;
    BOOL pickedRow;
    BOOL pickedSeat;
    
    IBOutlet UITableView *viewTable;
    NSArray *seatArray;
    
    int selectedSectionIndex;
    int selectedRowIndex;
    int selectedSeatIndex;
    
}

@end
