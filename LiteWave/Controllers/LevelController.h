//
//  LevelController.h
//  LiteWave
//
//  Created by David Anderson on 7/26/15.
//  Copyright (c) 2015 LightWave. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "AppDelegate.h"

@interface LevelController : UIViewController <UITableViewDelegate, UITableViewDataSource> {
    
    IBOutlet UIActivityIndicatorView *spinner;
    IBOutlet UILabel *descriptionLabel;
    IBOutlet UITableView *viewTable;
    
    NSMutableArray *levels;
    NSDictionary *levelDictionary;
    
    int selectedLevelIndex;
}

@property (nonatomic, retain) AppDelegate *appDelegate;

@end
