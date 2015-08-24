//
//  SeatController.m
//  LiteWave
//
//  Created by David Anderson on 7/26/15.
//  Copyright (c) 2015 LightWave. All rights reserved.
//

#import "LWCircleTableViewCell.h"
#import "LWSeatController.h"
#import "LWReadyController.h"
#import "LWAppDelegate.h"
#import "LWApiClient.h"

@implementation LWSeatController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.appDelegate = (LWAppDelegate *)[[UIApplication sharedApplication] delegate];
    
    self.view.backgroundColor = self.appDelegate.backgroundColor;
    
    sectionTable.hidden = YES;
    rowTable.hidden = YES;
    seatTable.hidden = YES;
    
    selectedSectionIndex = 0;
    selectedRowIndex = 0;
    selectedSeatIndex = 0;
    
    [self getSeats];
}

- (void)viewDidAppear:(BOOL)animated {
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(selectRow:)
                                                 name:@"selectRow" object:nil];
}

- (void)viewWillDisappear:(BOOL)animated{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    
    [joinButton removeTarget:nil
                        action:NULL
              forControlEvents:UIControlEventAllEvents];
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
    
    LWCircleTableViewCell *cell = (LWCircleTableViewCell *)[tableView dequeueReusableCellWithIdentifier:cellIdentifier];
    if (cell == nil) {
        cell = [[LWCircleTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellIdentifier];
    }
    
    NSDictionary *data = [[self getTableData:tableView] objectAtIndex:indexPath.row];
    cell.nameLabel.text = [data valueForKeyPath:@"name"];
    
    cell.tableView = tableView;
    cell.index = @(indexPath.row);
    
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
    
    if (indexPath.row == 0) {
        cell.button.hidden = YES;
        cell.nameLabel.frame = CGRectMake(0, 20, cell.nameLabel.frame.size.width, cell.nameLabel.frame.size.height);
        [cell.nameLabel setTextColor:self.appDelegate.textColor];
    } else {
        cell.button.hidden = NO;
    }

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
    for (LWCircleTableViewCell *cell in cells)
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

- (void)getSeats
{
    [[LWAPIClient instance] getStadium: self.appDelegate.stadiumID
                             //withLevel: self.appDelegate.levelID
                             onSuccess:^(id data) {
                                 NSError *error2;
                                 NSData *jsonData = [NSJSONSerialization dataWithJSONObject:data options:kNilOptions error:&error2];
                                 NSString *jsonArray = [[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding];
                                 
                                 NSDictionary *seatsDict =
                                 [NSJSONSerialization JSONObjectWithData: [jsonArray dataUsingEncoding:NSUTF8StringEncoding]
                                                                 options: NSJSONReadingMutableContainers
                                                                   error: &error2];
                                 
                                 self.appDelegate.seatsArray = [[NSDictionary alloc] initWithDictionary:seatsDict copyItems:YES];
                                 
                                 [self loadSections];
                                 [self loadRows];
                                 [self loadSeats];
                                  
                                 [self prepareView];
                             }
                             onFailure:^(NSError *error) {
                                 UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Network error"
                                                                                 message: @"Stadium seating could not be retrieved."delegate:self
                                                                       cancelButtonTitle:@"OK"
                                                                       otherButtonTitles:nil];
                                 [alert show];
                             }];
}

- (void)loadSections
{
    levels = [[NSMutableArray alloc] initWithArray:[self.appDelegate.seatsArray objectForKey:@"levels"]];
    int index = 0;
    for (NSDictionary *level in levels) {
        if ([level objectForKey:@"name"] == self.appDelegate.levelID) {
            selectedLevelIndex = index;
            break;
        }
        index++;
    }
    
    levelDictionary = [levels objectAtIndex:selectedLevelIndex];
    sections = [NSMutableArray arrayWithArray:[levelDictionary objectForKey:@"sections"]];
    
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
    joinButton.frame = CGRectMake(0,
                                  self.view.bounds.size.height - 50,
                                  self.view.bounds.size.width,
                                  50);
    [self disableJoin];
    
    sectionTable.hidden = NO;
    sectionTable.frame = CGRectMake(0,
                                    0,
                                    self.view.frame.size.width/3.0,
                                    self.view.frame.size.height - joinButton.frame.size.height);
    sectionTable.backgroundColor = self.appDelegate.backgroundColor;
    sectionTable.separatorStyle = UITableViewCellSeparatorStyleNone;
    [sectionTable setShowsVerticalScrollIndicator:NO];
    [sectionTable setContentInset:UIEdgeInsetsMake(-20,0,10,0)];
    [sectionTable setDataSource:self];
    [sectionTable setDelegate:self];
    
    rowTable.frame = CGRectMake(
                                self.view.frame.size.width/3.0,
                                0,
                                self.view.frame.size.width/3.0,
                                self.view.frame.size.height - joinButton.frame.size.height);
    rowTable.backgroundColor = self.appDelegate.backgroundColor;
    rowTable.separatorStyle = UITableViewCellSeparatorStyleNone;
    rowTable.hidden = YES;
    [rowTable setShowsVerticalScrollIndicator:NO];
    [rowTable setContentInset:UIEdgeInsetsMake(-20,0,10,0)];
    [rowTable setDataSource:self];
    [rowTable setDelegate:self];
    
    seatTable.frame = CGRectMake(
                                 2.0*self.view.frame.size.width/3.0,
                                 0,
                                 self.view.frame.size.width/3.0,
                                 self.view.frame.size.height - joinButton.frame.size.height);
    seatTable.backgroundColor = self.appDelegate.backgroundColor;
    seatTable.separatorStyle = UITableViewCellSeparatorStyleNone;
    seatTable.hidden = YES;
    [seatTable setShowsVerticalScrollIndicator:NO];
    [seatTable setContentInset:UIEdgeInsetsMake(-20,0,10,0)];
    [seatTable setDataSource:self];
    [seatTable setDelegate:self];
    
    rowLabel = [[UILabel alloc]initWithFrame:CGRectMake(rowTable.frame.origin.x,
                                                        rowTable.frame.origin.y,
                                                        rowTable.frame.size.width,
                                                        100)];
    [rowLabel setTextColor:self.appDelegate.textColor];
    [rowLabel setFont:[UIFont fontWithName:@"HelveticaNeue" size:24.0f]];
    [rowLabel setTranslatesAutoresizingMaskIntoConstraints:NO];
    rowLabel.textAlignment = NSTextAlignmentCenter;
    rowLabel.text = @"Row";
    [self.view addSubview:rowLabel];
    
    seatLabel = [[UILabel alloc]initWithFrame:CGRectMake(seatTable.frame.origin.x,
                                                         seatTable.frame.origin.y,
                                                         seatTable.frame.size.width,
                                                         100)];
    [seatLabel setTextColor:self.appDelegate.textColor];
    [seatLabel setFont:[UIFont fontWithName:@"HelveticaNeue" size:24.0f]];
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
    joinButton.layer.borderColor=self.appDelegate.highlightColor.CGColor;
    joinButton.layer.backgroundColor=self.appDelegate.highlightColor.CGColor;
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
    self.appDelegate.levelID = [[levels objectAtIndex:selectedLevelIndex] valueForKeyPath:@"name"];
    self.appDelegate.sectionID = [[sections objectAtIndex:selectedSectionIndex] valueForKeyPath:@"name"];
    self.appDelegate.rowID = [[rows objectAtIndex:selectedRowIndex] valueForKeyPath:@"name"];
    self.appDelegate.seatID = [[seats objectAtIndex:selectedSeatIndex] valueForKeyPath:@"name"];
    
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    [defaults setValue:self.appDelegate.levelID forKey:@"leveID"];
    [defaults setValue:self.appDelegate.sectionID forKey:@"sectionID"];
    [defaults setValue:self.appDelegate.rowID forKey:@"rowID"];
    [defaults setValue:self.appDelegate.seatID forKey:@"seatID"];
    
    [defaults synchronize];
    
    NSDictionary *userSeat = [NSDictionary dictionaryWithObjectsAndKeys:
                                self.appDelegate.levelID, @"level",
                                self.appDelegate.sectionID, @"section",
                                self.appDelegate.rowID, @"row",
                                self.appDelegate.seatID, @"seat_number", nil];
    
    NSDictionary *params = [NSDictionary dictionaryWithObjectsAndKeys:
                                //[NSString stringWithFormat:@"%@%@", self.appDelegate.uniqueID, @"F"],
                                self.appDelegate.uniqueID,
                                @"user_key",
                                userSeat,
                                @"user_seat",
                                nil];
    
    [[LWAPIClient instance] joinEvent: self.appDelegate.eventID
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
                              LWReadyController *ready = [storyboard instantiateViewControllerWithIdentifier:@"ready"];
                              [self.navigationController pushViewController:ready animated:YES];
                              
                          }
                          onFailure:^(NSError *error) {
                              if (error) {
                                  
                                  UIAlertView *alert = [[UIAlertView alloc] initWithTitle: @"Join error"
                                                                                  message: @"Sorry, an error occurred when joining the event."
                                                                                 delegate:self
                                                                        cancelButtonTitle:@"OK"
                                                                        otherButtonTitles:nil];
                                  [alert show];
                                  
                              }
                          }];

}


@end

