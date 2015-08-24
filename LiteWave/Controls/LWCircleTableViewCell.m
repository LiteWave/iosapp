//
//  CircleTableCellTableViewCell.m
//  LiteWave
//
//  Created by David Anderson on 7/29/15.
//  Copyright (c) 2015 LightWave. All rights reserved.
//

#import "LWCircleTableViewCell.h"

#define ROUND_BUTTON_WIDTH_HEIGHT 75
#define CELL_HEIGHT 100

@implementation LWCircleTableViewCell

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    
    self.appDelegate = (LWAppDelegate *)[[UIApplication sharedApplication] delegate];
    
    if (self) {
        //reuseID = reuseIdentifier;
        
        NSInteger tableWidth = self.contentView.frame.size.width/3.0;
        
        UIView *bgColorView = [[UIView alloc] init];
        bgColorView.backgroundColor = self.appDelegate.backgroundColor;
        [self setSelectedBackgroundView:bgColorView];
        
        self.contentView.backgroundColor = self.appDelegate.backgroundColor;
        
        
        self.button = [UIButton buttonWithType:UIButtonTypeCustom];
        self.button.frame = CGRectMake(tableWidth/2 - ROUND_BUTTON_WIDTH_HEIGHT/2,
                                  CELL_HEIGHT/2 - ROUND_BUTTON_WIDTH_HEIGHT/2,
                                  ROUND_BUTTON_WIDTH_HEIGHT,
                                  ROUND_BUTTON_WIDTH_HEIGHT);
        self.button.clipsToBounds = YES;
        self.button.layer.cornerRadius = ROUND_BUTTON_WIDTH_HEIGHT/2.0f;
        self.button.layer.borderColor = self.appDelegate.borderColor.CGColor;
        self.button.layer.borderWidth = 2.0f;
        [self.contentView addSubview:self.button];
        
        UITapGestureRecognizer *singleFingerTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleSingleTap:)];
        [self.button addGestureRecognizer:singleFingerTap];
        [self.button addTarget:self action:@selector(onTouchDown) forControlEvents:UIControlEventTouchDown];
        
        self.nameLabel = [[UILabel alloc]initWithFrame:CGRectMake(0, 0, tableWidth, CELL_HEIGHT)];
        self.nameLabel.textAlignment = NSTextAlignmentCenter;
        [self.nameLabel setTextColor:self.appDelegate.textColor];
        [self.nameLabel setFont:[UIFont fontWithName:@"HelveticaNeue" size:24.0f]];
        [self.nameLabel setTranslatesAutoresizingMaskIntoConstraints:NO];
        [self.contentView addSubview:self.nameLabel];
    }
    return self;
}

-(void)select {
    self.button.layer.borderColor=self.appDelegate.highlightColor.CGColor;
    self.button.layer.backgroundColor=self.appDelegate.highlightColor.CGColor;
    
    [self.nameLabel setTextColor:self.appDelegate.textSelectedColor];
}

-(void)clear {
    self.button.layer.borderColor=self.appDelegate.borderColor.CGColor;
    self.button.layer.backgroundColor=self.appDelegate.backgroundColor.CGColor;
    
    [self.nameLabel setTextColor:self.appDelegate.textColor];
}

- (void)handleSingleTap:(UITapGestureRecognizer *)recognizer {
    [self select];
    [self.button removeTarget:self action:@selector(onTouch) forControlEvents:UIControlEventAllTouchEvents];
    
    NSDictionary* message = @{ @"index" : self.index,
                            @"tableView" : self.tableView};
    
    [[NSNotificationCenter defaultCenter] postNotificationName:@"selectRow" object:message ];
}

-(void)onTouchDown {

    [self select];
    [self.button addTarget:self action:@selector(onTouch) forControlEvents:UIControlEventAllTouchEvents];
}


-(void)onTouch {
    
    if ([self.button isTracking])
    {
        [self select];
    }
    else
    {
        [self clear];
    }
}



@end
