//
//  SeatController.h
//  LiteWave
//
//  Created by David Anderson on 7/26/15.
//  Copyright (c) 2015 LightWave. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "LWAppDelegate.h"

@interface LWSeatController : UIViewController <UITableViewDelegate, UITableViewDataSource> {
    
    IBOutlet UIButton *joinButton;
    IBOutlet UITableView *sectionTable;
    IBOutlet UITableView *rowTable;
    IBOutlet UITableView *seatTable;
    
    UILabel *sectionLabel;
    UILabel *rowLabel;
    UILabel *seatLabel;
    
    IBOutlet UIImageView *imageView;
    
    NSMutableArray *levels;
    NSDictionary *levelDictionary;
    
    NSMutableArray *sections;
    NSDictionary *sectionDictionary;
    NSArray *sectionArray;

    NSMutableArray *rows;
    NSDictionary *rowDictionary;
    NSArray *rowArray;
    
    NSMutableArray *seats;
    NSDictionary *seatDictionary;
    NSArray *seatArray;
    
    int selectedLevelIndex;
    int selectedSectionIndex;
    int selectedRowIndex;
    int selectedSeatIndex;
}

@property (nonatomic, retain) LWAppDelegate *appDelegate;

@end
