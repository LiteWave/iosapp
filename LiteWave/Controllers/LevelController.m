//
//  LevelController.m
//  LiteWave
//
//  Created by David Anderson on 7/26/15.
//  Copyright (c) 2015 LightWave. All rights reserved.
//

#import "CircleTableViewCell.h"
#import "LevelController.h"
#import "SeatController.h"
#import "AFNetworking.h"
#import "AppDelegate.h"
#import "APIClient.h"


@implementation LevelController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    levelArray = [NSArray arrayWithObjects:@"0", @"1", @"2", @"3", nil];
    
    viewTable.frame = CGRectMake(self.view.frame.size.width/3.0, 50, self.view.frame.size.width/3.0, self.view.frame.size.height);
    viewTable.backgroundColor = [UIColor blackColor];
    viewTable.separatorStyle = UITableViewCellSeparatorStyleNone;
    [viewTable setDataSource:self];
    [viewTable setDelegate:self];
}

- (void)viewDidAppear:(BOOL)animated {

    self.navigationItem.hidesBackButton = YES;
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(selectRow:)
                                                 name:@"selectRow" object:nil];
}

- (void)viewWillDisappear:(BOOL)animated{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}


- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void) selectRow:(NSNotification*)notification {
    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Main" bundle: nil];
    SeatController *seat = [storyboard instantiateViewControllerWithIdentifier:@"seat"];
    [self.navigationController pushViewController:seat animated:YES];
}


- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [levelArray count];
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 100;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *cellIdentifier = @"CircleTableViewCell";
    
    CircleTableViewCell *cell = (CircleTableViewCell *)[viewTable dequeueReusableCellWithIdentifier:cellIdentifier];
    if (cell == nil) {
        cell = [[CircleTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellIdentifier];
    }
    cell.nameLabel.text = [levelArray objectAtIndex:indexPath.row];
    
    cell.index = @(indexPath.row);
    cell.tableView = tableView;
    
    return cell;
}


@end

