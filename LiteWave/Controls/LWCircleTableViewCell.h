//
//  CircleTableCellTableViewCell.h
//  LiteWave
//
//  Created by David Anderson on 7/29/15.
//  Copyright (c) 2015 LightWave. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "LWAppDelegate.h"

@interface LWCircleTableViewCell : UITableViewCell

@property (nonatomic, strong) UILabel *nameLabel;
@property (nonatomic, strong) UIButton *button;

@property (nonatomic, strong) NSNumber *index;
@property (nonatomic, strong) UITableView *tableView;

@property (nonatomic, retain) LWAppDelegate *appDelegate;

-(void)select;
-(void)clear;

@end
