//
//  SeatController.m
//  LiteWave
//
//  Created by David Anderson on 7/26/15.
//  Copyright (c) 2015 LightWave. All rights reserved.
//

#import "CircleTableViewCell.h"
#import "SeatController.h"
#import "ReadyController.h"
#import "AFNetworking.h"
#import "AppDelegate.h"
#import "APIClient.h"

@implementation SeatController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.appDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    
    sectionTable.hidden = YES;
    rowTable.hidden = YES;
    seatTable.hidden = YES;
    
    selectedSectionIndex = 0;
    selectedRowIndex = 0;
    selectedSeatIndex = 0;
    
    [self loadSections];
    [self loadRows];
    [self loadSeats];
    
    [self prepareView];
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
    
    NSDictionary *data = [[self getTableData:tableView] objectAtIndex:indexPath.row];
    cell.nameLabel.text = [data valueForKeyPath:@"name"];
    
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
    
    if (indexPath.row == selected)
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
            
            selectedRowIndex = 0;
            [self loadRows];
            [self clearCells:rowTable selected:selectedRowIndex];
            
            selectedSeatIndex = 0;
            [self loadSeats];
            [self clearCells:seatTable selected:selectedSeatIndex];
            
            rowTable.hidden = NO;
            rowLabel.hidden = YES;
            
            seatTable.hidden = YES;
            seatLabel.hidden = NO;
            
            [self disableJoin];
        }
        if (tableView == rowTable) {
            selectedRowIndex = [index intValue];
            seatTable.hidden = NO;
            seatLabel.hidden = YES;
            
            selectedSeatIndex = 0;
            [self loadSeats];
            [self clearCells:seatTable selected:selectedSeatIndex];
            
            [self disableJoin];
        }
        if (tableView == seatTable) {
            selectedSeatIndex = [index intValue];
            
            [self enableJoin];
        }
        
        [self clearCells:tableView  selected:(int)index];
    }
}

- (void)clearCells:(UITableView*)tableView selected:(int)index
{
    NSArray *cells = [tableView visibleCells];
    for (CircleTableViewCell *cell in cells)
    {
        if ((int)cell.index == index)
            [cell select];
        else
            [cell clear];
    }
}

- (NSArray *)getTableData:(UITableView *)tableView
{
    if (tableView == sectionTable) {
        return sections;
    } else if (tableView == rowTable) {
        return rows;
    } else {
        return seats;
    }
}

- (void)loadSections
{
    sections = [[NSMutableArray alloc] initWithArray:[self.appDelegate.seatsArray objectForKey:@"sections"]];
    
    NSDictionary* obj = @{ @"id" : @"",
                            @"name" : @"Section"};
    [sections insertObject:obj atIndex:0];
}

- (void)loadRows
{
    sectionDictionary = [sections objectAtIndex:selectedSectionIndex];
    rows = [NSMutableArray arrayWithArray:[sectionDictionary objectForKey:@"rows"]];
    
    NSDictionary* obj = @{ @"id" : @"",
                           @"name" : @"Row"};
    [rows insertObject:obj atIndex:0];
    [rowTable reloadData];
}

- (void)loadSeats
{
    seatDictionary = [rows objectAtIndex:selectedRowIndex];
    seats = [NSMutableArray arrayWithArray:[seatDictionary objectForKey:@"seats"]];
    
    NSDictionary* obj = @{ @"id" : @"",
                           @"name" : @"Seat"};
    [seats insertObject:obj atIndex:0];
    [seatTable reloadData];
}

- (void)prepareView
{
    CGRect statusBarViewRect = [[UIApplication sharedApplication] statusBarFrame];
    float heightPadding = statusBarViewRect.size.height+self.navigationController.navigationBar.frame.size.height;
    
    joinButton.frame = CGRectMake(0,
                                   self.view.bounds.size.height - heightPadding - 60,
                                   self.view.bounds.size.width,
                                   60);
    [self disableJoin];
    
    sectionTable.hidden = NO;
    sectionTable.frame = CGRectMake(0,
                                    0,
                                    self.view.frame.size.width/3.0,
                                    self.view.frame.size.height - joinButton.frame.size.height);
    sectionTable.backgroundColor = [UIColor blackColor];
    sectionTable.separatorStyle = UITableViewCellSeparatorStyleNone;
    [sectionTable setContentInset:UIEdgeInsetsMake(0,0,10,0)];
    [sectionTable setDataSource:self];
    [sectionTable setDelegate:self];
    
    rowTable.frame = CGRectMake(
                                self.view.frame.size.width/3.0,
                                0,
                                self.view.frame.size.width/3.0,
                                self.view.frame.size.height - joinButton.frame.size.height);
    rowTable.backgroundColor = [UIColor blackColor];
    rowTable.separatorStyle = UITableViewCellSeparatorStyleNone;
    rowTable.hidden = YES;
    [rowTable setContentInset:UIEdgeInsetsMake(0,0,10,0)];
    [rowTable setDataSource:self];
    [rowTable setDelegate:self];
    
    seatTable.frame = CGRectMake(
                                 2.0*self.view.frame.size.width/3.0,
                                 0,
                                 self.view.frame.size.width/3.0,
                                 self.view.frame.size.height - joinButton.frame.size.height);
    seatTable.backgroundColor = [UIColor blackColor];
    seatTable.separatorStyle = UITableViewCellSeparatorStyleNone;
    seatTable.hidden = YES;
    [seatTable setContentInset:UIEdgeInsetsMake(0,0,10,0)];
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

- (void)disableJoin
{
    joinButton.layer.borderColor=[UIColor colorWithRed:46.0/255.0 green:46.0/255.0 blue:46.0/255.0 alpha:1.0].CGColor;
    joinButton.layer.backgroundColor=[UIColor colorWithRed:46.0/255.0 green:46.0/255.0 blue:46.0/255.0 alpha:1.0].CGColor;
    joinButton.layer.borderWidth=2.0f;
    
    [joinButton setTitleColor:[UIColor colorWithRed:100.0/255.0 green:100.0/255.0 blue:100.0/255.0 alpha:1.0] forState:UIControlStateNormal];

    [joinButton removeTarget:self action:@selector(onJoinSelect) forControlEvents:UIControlEventTouchUpInside];
}

- (void)enableJoin
{
    joinButton.layer.borderColor=[UIColor colorWithRed:222.0/255.0 green:32.0/255 blue:50.0/255 alpha:1.0].CGColor;
    joinButton.layer.backgroundColor=[UIColor colorWithRed:222.0/255.0 green:32.0/255 blue:50.0/255 alpha:1.0].CGColor;
    joinButton.layer.borderWidth=2.0f;
    
    [joinButton setTitleColor:[UIColor colorWithRed:255.0/255.0 green:255.0/255.0 blue:255.0/255.0 alpha:1.0] forState:UIControlStateNormal];

    [joinButton addTarget:self action:@selector(onJoinSelect) forControlEvents:UIControlEventTouchUpInside];
}

-(void)onJoinSelect
{
    [self saveSeat];
}

- (void)saveSeat
{
    self.appDelegate.sectionID = [[sections objectAtIndex:selectedSectionIndex] valueForKeyPath:@"name"];
    self.appDelegate.rowID = [[rows objectAtIndex:selectedRowIndex] valueForKeyPath:@"name"];
    self.appDelegate.seatID = [[seats objectAtIndex:selectedSeatIndex] valueForKeyPath:@"name"];
    
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    
    [defaults setValue:self.appDelegate.sectionID forKey:@"sectionID"];
    [defaults setValue:self.appDelegate.rowID forKey:@"rowID"];
    [defaults setValue:self.appDelegate.seatID forKey:@"seatID"];
    
    [defaults synchronize];
    
    NSDictionary *userSeat = [NSDictionary dictionaryWithObjectsAndKeys:
                                self.appDelegate.sectionID, @"section",
                                self.appDelegate.rowID, @"row",
                                self.appDelegate.seatID, @"seat_number", nil];
    
    NSDictionary *params = [NSDictionary dictionaryWithObjectsAndKeys:
                                self.appDelegate.uniqueID,
                                @"user_key",
                                userSeat,
                                @"user_seat",
                                nil];
    
    
    [[APIClient instance] joinEvent: self.appDelegate.eventID
                             params: params
                          onSuccess:^(id data) {
                              NSLog(@"USER ADDED RESPONSE: %@", data);
                              
                              NSError *error2;
                              NSData *jsonData = [NSJSONSerialization dataWithJSONObject:data options:kNilOptions error:&error2];
                              NSString *jsonArray = [[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding];
                              
                              NSDictionary *userDict =
                              [NSJSONSerialization JSONObjectWithData: [jsonArray dataUsingEncoding:NSUTF8StringEncoding]
                                                              options: NSJSONReadingMutableContainers
                                                                error: &error2];
                              
                              self.appDelegate.userID = [userDict objectForKey:@"_id"];
                              
                              NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
                              
                              [defaults setValue:self.appDelegate.userID forKey:@"userID"];
                              
                              [defaults synchronize];
                              
                              UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Main" bundle: nil];
                              ReadyController *ready = [storyboard instantiateViewControllerWithIdentifier:@"ready"];
                              [self.navigationController pushViewController:ready animated:YES];
                              
                          }
                          onFailure:^(NSError *error) {
                              if (error) {
                                  
                                  UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Register Error" message:error.localizedDescription delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil];
                                  [alert show];
                                  
                              }
                          }];

}


@end

