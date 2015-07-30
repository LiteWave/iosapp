//
//  CircleTableCellTableViewCell.m
//  LiteWave
//
//  Created by David Anderson on 7/29/15.
//  Copyright (c) 2015 LightWave. All rights reserved.
//

#import "CircleTableViewCell.h"

#define ROUND_BUTTON_WIDTH_HEIGHT 75
#define CELL_HEIGHT 100

@implementation CircleTableViewCell

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        //reuseID = reuseIdentifier;
        
        UIView *bgColorView = [[UIView alloc] init];
        bgColorView.backgroundColor = [UIColor blackColor];
        [self setSelectedBackgroundView:bgColorView];
        
        self.contentView.backgroundColor = [UIColor blackColor];
        
        self.nameLabel = [[UILabel alloc]initWithFrame:CGRectMake(0, 0, self.contentView.frame.size.width, CELL_HEIGHT)];
        [self.nameLabel setTextColor:[UIColor whiteColor]];
        [self.nameLabel setFont:[UIFont fontWithName:@"HelveticaNeue" size:25.0f]];
        [self.nameLabel setTranslatesAutoresizingMaskIntoConstraints:NO];
        self.nameLabel.textAlignment = NSTextAlignmentCenter;
        [self.contentView addSubview:self.nameLabel];
        
        
        
        self.button = [UIButton buttonWithType:UIButtonTypeCustom];
        self.button.frame = CGRectMake(self.contentView.frame.size.width/2 - ROUND_BUTTON_WIDTH_HEIGHT/2,
                                  CELL_HEIGHT/2 - ROUND_BUTTON_WIDTH_HEIGHT/2,
                                  ROUND_BUTTON_WIDTH_HEIGHT,
                                  ROUND_BUTTON_WIDTH_HEIGHT);
        self.button.clipsToBounds = YES;
        self.button.layer.cornerRadius = ROUND_BUTTON_WIDTH_HEIGHT/2.0f;
        self.button.layer.borderColor=[UIColor colorWithRed:46.0/255.0 green:46.0/255.0 blue:46.0/255.0 alpha:1.0].CGColor;
        self.button.layer.borderWidth=2.0f;
        
        [self.button addTarget:self action:@selector(onTouchDown) forControlEvents:UIControlEventTouchDown];
        [self.button addTarget:self action:@selector(onTouchUp) forControlEvents:UIControlEventTouchUpOutside];
        [self.button addTarget:self action:@selector(onSelect) forControlEvents:UIControlEventTouchUpInside];
        
        [self.contentView addSubview:self.button];
    }
    return self;
}

-(void)onTouchDown {
    self.button.layer.borderColor=[UIColor colorWithRed:255.0/255.0 green:255.0/255.0 blue:255.0/255.0 alpha:1.0].CGColor;
}

-(void)onTouchUp {
    //self.button.layer.borderColor=[UIColor colorWithRed:46.0/255.0 green:46.0/255.0 blue:46.0/255.0 alpha:1.0].CGColor;
}


-(void)onSelect {
    //self.button.layer.borderColor=[UIColor colorWithRed:46.0/255.0 green:46.0/255.0 blue:46.0/255.0 alpha:1.0].CGColor;
    
    [[NSNotificationCenter defaultCenter] postNotificationName:@"selectRow" object:[NSNumber numberWithInt:1]];
    
    
}

@end
