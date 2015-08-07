//
//  SeatController.m
//  LiteWave
//
//  Created by David Anderson on 7/26/15.
//  Copyright (c) 2015 LightWave. All rights reserved.
//

#import "CircleTableViewCell.h"
#import "SeatController.h"
#import "SeatsController.h"
#import "AFNetworking.h"
#import "AppDelegate.h"
#import "APIClient.h"

@implementation SeatController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.appDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    
    sectionArray = [NSArray arrayWithObjects:@"Section", @"100", @"101", @"102", @"103", @"104", @"105", @"106", @"107", @"108", @"109", @"110", @"111", @"112", @"113", @"114", @"115", @"116", @"117", @"118", @"119", nil];
    
    sectionTable.frame = CGRectMake(0, 0, self.view.frame.size.width/3.0, self.view.frame.size.height);
    sectionTable.backgroundColor = [UIColor blackColor];
    sectionTable.separatorStyle = UITableViewCellSeparatorStyleNone;
    [sectionTable setContentInset:UIEdgeInsetsMake(0,0,10,0)];
    [sectionTable setDataSource:self];
    [sectionTable setDelegate:self];
    
    rowArray = [NSArray arrayWithObjects:@"Row", @"A", @"B", @"C", @"D", @"E", @"F", @"G", @"H", @"J", @"K", @"L", @"M", @"N", @"O", @"P", nil];
    
    rowTable.frame = CGRectMake(self.view.frame.size.width/3.0, 0, self.view.frame.size.width/3.0, self.view.frame.size.height);
    rowTable.backgroundColor = [UIColor blackColor];
    rowTable.separatorStyle = UITableViewCellSeparatorStyleNone;
    rowTable.hidden = YES;
    [rowTable setContentInset:UIEdgeInsetsMake(0,0,75,0)];
    [rowTable setDataSource:self];
    [rowTable setDelegate:self];
    
    seatArray = [NSArray arrayWithObjects:@"Seat", @"1", @"2", @"3", @"4", @"5", @"6", @"7", @"8", @"9", @"10", @"11", @"12", @"13", @"14", @"15", @"16", nil];
    
    seatTable.frame = CGRectMake(2.0*self.view.frame.size.width/3.0, 0, self.view.frame.size.width/3.0, self.view.frame.size.height);
    seatTable.backgroundColor = [UIColor blackColor];
    seatTable.separatorStyle = UITableViewCellSeparatorStyleNone;
    seatTable.hidden = YES;
    [seatTable setContentInset:UIEdgeInsetsMake(0,0,75,0)];
    [seatTable setDataSource:self];
    [seatTable setDelegate:self];
    
    rowLabel = [[UILabel alloc]initWithFrame:CGRectMake(rowTable.frame.origin.x,
                                                             rowTable.frame.origin.y,
                                                             rowTable.frame.size.width,
                                                             100)];
    [rowLabel setTextColor:[UIColor colorWithRed:46.0/255.0 green:46.0/255.0 blue:46.0/255.0 alpha:1.0]];
    [rowLabel setFont:[UIFont fontWithName:@"HelveticaNeue" size:25.0f]];
    [rowLabel setTranslatesAutoresizingMaskIntoConstraints:NO];
    rowLabel.textAlignment = NSTextAlignmentCenter;
    rowLabel.text = @"Row";
    [self.view addSubview:rowLabel];
    
    seatLabel = [[UILabel alloc]initWithFrame:CGRectMake(seatTable.frame.origin.x,
                                                        seatTable.frame.origin.y,
                                                        seatTable.frame.size.width,
                                                        100)];
    [seatLabel setTextColor:[UIColor colorWithRed:46.0/255.0 green:46.0/255.0 blue:46.0/255.0 alpha:1.0]];
    [seatLabel setFont:[UIFont fontWithName:@"HelveticaNeue" size:25.0f]];
    [seatLabel setTranslatesAutoresizingMaskIntoConstraints:NO];
    seatLabel.textAlignment = NSTextAlignmentCenter;
    seatLabel.text = @"Seat";
    [self.view addSubview:seatLabel];
}

- (void)viewDidAppear:(BOOL)animated {
    
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

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    NSArray *data = [self getTableData:tableView];
    return [data count];
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 100;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *cellIdentifier = @"CircleTableViewCell";
    
    CircleTableViewCell *cell = (CircleTableViewCell *)[tableView dequeueReusableCellWithIdentifier:cellIdentifier];
    if (cell == nil) {
        cell = [[CircleTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellIdentifier];
    }
    
    NSArray *data = [self getTableData:tableView];
    cell.nameLabel.text = [data objectAtIndex:indexPath.row];
    
    cell.tableView = tableView;
    cell.index = @(indexPath.row);

    if (indexPath.row == 0) {
        cell.button.hidden = YES;
    } else {
        cell.button.hidden = NO;
    }
    
    int selected;
    if (tableView == sectionTable) {
        selected = selectedSectionIndex;
    } else if (tableView == rowTable) {
        selected = selectedRowIndex;
    } else {
        selected = selectedSeatIndex;
    }
    
    if (indexPath.row == selectedSectionIndex)
        [cell select];
    else
        [cell clear];

    return cell;
}

- (void)selectRow:(NSNotification*)notification {
    if ([notification.object isKindOfClass:[NSDictionary class]])
    {
        NSDictionary *message = [notification object];
        UITableView *tableView = [message objectForKey:@"tableView"];
        NSNumber *index = [message objectForKey:@"index"];
        
        if (tableView == sectionTable) {
            selectedSectionIndex = [index intValue];
            rowTable.hidden = NO;
            rowLabel.hidden = YES;
        }
        if (tableView == rowTable) {
            selectedRowIndex = [index intValue];
            seatTable.hidden = NO;
            seatLabel.hidden = YES;
        }
        if (tableView == seatTable) {
            selectedSeatIndex = [index intValue];
            
            UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Main" bundle: nil];
            SeatsController *seats = [storyboard instantiateViewControllerWithIdentifier:@"seats"];
            [self.navigationController pushViewController:seats animated:YES];
        }
        
        NSArray *cells = [tableView visibleCells];
        for (CircleTableViewCell *cell in cells)
        {
            if (cell.index != index)
                [cell clear];
        }

    }
}



- (NSArray *)getTableData:(UITableView *)tableView
{
    if (tableView == sectionTable) {
        return sectionArray;
    } else if (tableView == rowTable) {
        return rowArray;
    } else {
        return seatArray;
    }
}



@end

