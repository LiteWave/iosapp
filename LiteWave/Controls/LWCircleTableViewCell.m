//
//  CircleTableCellTableViewCell.m
//  LiteWave
//
//  Created by David Anderson on 7/29/15.
//  Copyright (c) 2015 LightWave. All rights reserved.
//

#import "LWCircleTableViewCell.h"
#import "LWConfiguration.h"

@implementation LWCircleTableViewCell

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    
    return self;
}

-(void)draw {
    if (self) {
        int cellWidth = [self.width intValue];
        double cellCircleHeight = cellWidth *.85;
        double cellHeight = cellWidth;
        
        self.contentView.backgroundColor = [UIColor colorWithRed:0/255.0 green:0/255.0 blue:0/255.0 alpha:0];
        self.backgroundColor = [UIColor colorWithRed:0/255.0 green:0/255.0 blue:0/255.0 alpha:0];
        self.selectedBackgroundView.backgroundColor = [UIColor colorWithRed:0/255.0 green:0/255.0 blue:0/255.0 alpha:0];
        
        UIView *bgColorView = [[UIView alloc] init];
        bgColorView.backgroundColor = [UIColor colorWithRed:0/255.0 green:0/255.0 blue:0/255.0 alpha:0];
        [self setSelectedBackgroundView:bgColorView];
        
        
        self.button = [UIButton buttonWithType:UIButtonTypeCustom];
        self.button.frame = CGRectMake(cellWidth/2 - cellCircleHeight/2,
                                       cellHeight/2 - cellCircleHeight/2,
                                       cellCircleHeight,
                                       cellCircleHeight);
        self.button.clipsToBounds = YES;
        self.button.layer.cornerRadius = cellCircleHeight/2.0f;
        self.button.layer.borderColor = [LWConfiguration instance].borderColor.CGColor;
        self.button.layer.borderWidth = 2.0f;
        [self.contentView addSubview:self.button];
        
        
        UITapGestureRecognizer *singleFingerTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleSingleTap:)];
        [self.button addGestureRecognizer:singleFingerTap];
        [self.button addTarget:self action:@selector(onTouchDown) forControlEvents:UIControlEventTouchDown];
        
        self.nameLabel = [[UILabel alloc]initWithFrame:CGRectMake(0, 0, cellWidth, cellHeight)];
        self.nameLabel.textAlignment = NSTextAlignmentCenter;
        [self.nameLabel setTextColor:[UIColor blackColor]];
        [self.nameLabel setFont:[UIFont fontWithName:@"HelveticaNeue" size:cellWidth*.22]];
        [self.nameLabel setTranslatesAutoresizingMaskIntoConstraints:NO];
        [self.contentView addSubview:self.nameLabel];
    }
}

-(void)select {
    self.button.layer.borderColor=[LWConfiguration instance].highlightColor.CGColor;
    self.button.layer.backgroundColor=[LWConfiguration instance].highlightColor.CGColor;
    
    [self.nameLabel setTextColor:[LWConfiguration instance].textSelectedColor];
}

-(void)clear {
    self.button.layer.borderColor=[LWConfiguration instance].borderColor.CGColor;
    self.button.layer.backgroundColor=[LWConfiguration instance].backgroundColor.CGColor;
    
    [self.nameLabel setTextColor:[LWConfiguration instance].textColor];
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
