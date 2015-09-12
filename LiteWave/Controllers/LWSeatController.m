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
#import "LWConfiguration.h"

@implementation LWSeatController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.appDelegate = (LWAppDelegate *)[[UIApplication sharedApplication] delegate];
    
    self.view.backgroundColor = [LWConfiguration instance].backgroundColor;
    
    sectionTable.hidden = YES;
    rowTable.hidden = YES;
    seatTable.hidden = YES;
    
    imageView.hidden = YES;
    
    selectedSectionIndex = 0;
    selectedRowIndex = 0;
    selectedSeatIndex = 0;
    
    [self prepareView];
    [self getSeats];
}

- (void)viewDidAppear:(BOOL)animated {
    
    //imageView.hidden = NO;
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(selectRow:)
                                                 name:@"selectRow" object:nil];
}

- (void)viewWillDisappear:(BOOL)animated{
    [super viewWillDisappear:animated];
    
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    
    //imageView.hidden = YES;
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
        [cell.nameLabel setTextColor:[LWConfiguration instance].textColor];
    } else {
        cell.button.hidden = NO;
        cell.nameLabel.frame = CGRectMake(0, 0, cell.nameLabel.frame.size.width, cell.nameLabel.frame.size.height);
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
    [[LWAPIClient instance] getStadium: [LWConfiguration instance].stadiumID
                             withLevel: [LWConfiguration instance].levelID
                             onSuccess:^(id data) {
                                 NSError *error2;
                                 NSData *jsonData = [NSJSONSerialization dataWithJSONObject:data options:kNilOptions error:&error2];
                                 NSString *jsonArray = [[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding];
                                 
                                 NSDictionary *seatsDict =
                                 [NSJSONSerialization JSONObjectWithData: [jsonArray dataUsingEncoding:NSUTF8StringEncoding]
                                                                 options: NSJSONReadingMutableContainers
                                                                   error: &error2];
                                 
                                 [LWConfiguration instance].seats = [[NSDictionary alloc] initWithDictionary:seatsDict copyItems:YES];
                                 
                                 [self loadSections];
                                 [self loadRows];
                                 [self loadSeats];
                                 
                                 sectionLabel.hidden = YES;
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
    sections = [[NSMutableArray alloc] initWithArray:[[LWConfiguration instance].seats objectForKey:@"sections"]];
    
    NSDictionary* obj = @{@"name" : @"Section"};
    [sections insertObject:obj atIndex:0];
    [sectionTable reloadData];
    
}

- (void)loadRows
{
    sectionDictionary = [sections objectAtIndex:selectedSectionIndex];
    rows = [NSMutableArray arrayWithArray:[sectionDictionary objectForKey:@"rows"]];
    
    NSDictionary* obj = @{@"name" : @"Row"};
    [rows insertObject:obj atIndex:0];
    [rowTable reloadData];
}

- (void)loadSeats
{
    rowDictionary = [rows objectAtIndex:selectedRowIndex];
    NSArray *seatsAsArray = [NSArray arrayWithArray:[rowDictionary objectForKey:@"seats"]];
    seats = [[NSMutableArray alloc] init];
    for (NSString *seat in seatsAsArray) {
        [seats addObject:@{@"name" : seat}];
    }
    
    NSDictionary* obj = @{@"name" : @"Seat"};
    [seats insertObject:obj atIndex:0];
    [seatTable reloadData];
}

- (void)prepareView
{
    CGRect statusBarViewRect = [[UIApplication sharedApplication] statusBarFrame];
    float heightPadding = statusBarViewRect.size.height+self.navigationController.navigationBar.frame.size.height;
    
    joinButton.frame = CGRectMake(0,
                                  self.view.bounds.size.height - 50 - heightPadding,
                                  self.view.bounds.size.width,
                                  50);
    [self disableJoin];
    
    sectionTable.hidden = NO;
    sectionTable.frame = CGRectMake(0,
                                    0,
                                    self.view.frame.size.width/3.0,
                                    self.view.frame.size.height - joinButton.frame.size.height);
    sectionTable.backgroundColor = [UIColor colorWithRed:0/255.0 green:0/255.0 blue:0/255.0 alpha:0];
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
    rowTable.backgroundColor = [UIColor colorWithRed:0/255.0 green:0/255.0 blue:0/255.0 alpha:0];
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
    seatTable.backgroundColor = [UIColor colorWithRed:0/255.0 green:0/255.0 blue:0/255.0 alpha:0];
    seatTable.separatorStyle = UITableViewCellSeparatorStyleNone;
    seatTable.hidden = YES;
    [seatTable setShowsVerticalScrollIndicator:NO];
    [seatTable setContentInset:UIEdgeInsetsMake(-20,0,10,0)];
    [seatTable setDataSource:self];
    [seatTable setDelegate:self];
    
    sectionLabel = [[UILabel alloc]initWithFrame:CGRectMake(sectionTable.frame.origin.x,
                                                        sectionTable.frame.origin.y,
                                                        sectionTable.frame.size.width,
                                                        100)];
    [sectionLabel setTextColor:[LWConfiguration instance].textColor];
    [sectionLabel setFont:[UIFont fontWithName:@"HelveticaNeue" size:24.0f]];
    [sectionLabel setTranslatesAutoresizingMaskIntoConstraints:NO];
    sectionLabel.textAlignment = NSTextAlignmentCenter;
    sectionLabel.text = @"Section";
    [self.view addSubview:sectionLabel];
    
    rowLabel = [[UILabel alloc]initWithFrame:CGRectMake(rowTable.frame.origin.x,
                                                        rowTable.frame.origin.y,
                                                        rowTable.frame.size.width,
                                                        100)];
    [rowLabel setTextColor:[LWConfiguration instance].textColor];
    [rowLabel setFont:[UIFont fontWithName:@"HelveticaNeue" size:24.0f]];
    [rowLabel setTranslatesAutoresizingMaskIntoConstraints:NO];
    rowLabel.textAlignment = NSTextAlignmentCenter;
    rowLabel.text = @"Row";
    [self.view addSubview:rowLabel];
    
    seatLabel = [[UILabel alloc]initWithFrame:CGRectMake(seatTable.frame.origin.x,
                                                         seatTable.frame.origin.y,
                                                         seatTable.frame.size.width,
                                                         100)];
    [seatLabel setTextColor:[LWConfiguration instance].textColor];
    [seatLabel setFont:[UIFont fontWithName:@"HelveticaNeue" size:24.0f]];
    [seatLabel setTranslatesAutoresizingMaskIntoConstraints:NO];
    seatLabel.textAlignment = NSTextAlignmentCenter;
    seatLabel.text = @"Seat";
    [self.view addSubview:seatLabel];
    
    [self loadImage];
}

- (void)loadImage
{
    if (![LWConfiguration instance].logoUrl || ![LWConfiguration instance].logoImage)
        return;
    
    CGRect statusBarViewRect = [[UIApplication sharedApplication] statusBarFrame];
    float heightPadding = statusBarViewRect.size.height+self.navigationController.navigationBar.frame.size.height;
    
    float height = 700;
    float width = ([LWConfiguration instance].logoImage.size.width*height)/[LWConfiguration instance].logoImage.size.height;
    imageView.frame = CGRectMake(self.view.frame.size.width/2 - width/2, self.view.frame.size.height/2 - height/2 - heightPadding, width, height);
    imageView.image = [LWConfiguration instance].logoImage;
    imageView.alpha = .05;
    imageView.hidden = NO;
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
    joinButton.layer.borderColor=[LWConfiguration instance].highlightColor.CGColor;
    joinButton.layer.backgroundColor=[LWConfiguration instance].highlightColor.CGColor;
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
    [LWConfiguration instance].sectionID = [[sections objectAtIndex:selectedSectionIndex] valueForKeyPath:@"name"];
    [LWConfiguration instance].rowID = [[rows objectAtIndex:selectedRowIndex] valueForKeyPath:@"name"];
    [LWConfiguration instance].seatID = [[seats objectAtIndex:selectedSeatIndex] valueForKeyPath:@"name"];
    
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    [defaults setValue:[LWConfiguration instance].levelID forKey:@"levelID"];
    [defaults setValue:[LWConfiguration instance].sectionID forKey:@"sectionID"];
    [defaults setValue:[LWConfiguration instance].rowID forKey:@"rowID"];
    [defaults setValue:[LWConfiguration instance].seatID forKey:@"seatID"];
    
    [defaults synchronize];
    
    NSDictionary *userSeat = [NSDictionary dictionaryWithObjectsAndKeys:
                                [LWConfiguration instance].levelID, @"level",
                                [LWConfiguration instance].sectionID, @"section",
                                [LWConfiguration instance].rowID, @"row",
                                [LWConfiguration instance].seatID, @"seat", nil];
    
    NSDictionary *params = [NSDictionary dictionaryWithObjectsAndKeys:
                                //[NSString stringWithFormat:@"%@%@", [LWConfiguration instance].uniqueID, @"F"],
                                [LWConfiguration instance].uniqueID,
                                @"userKey",
                                userSeat,
                                @"userSeat",
                                nil];
    
    NSLog(@"USER ADDED REQUEST: %@", params);
    
    [[LWAPIClient instance] joinEvent: [LWConfiguration instance].eventID
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
                              
                              [LWConfiguration instance].userID = [userDict objectForKey:@"_id"];
                              
                              NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
                              
                              [defaults setValue:[LWConfiguration instance].userID forKey:@"userID"];
                              
                              [defaults synchronize];
                              
                              UIStoryboard* storyboard = [UIStoryboard storyboardWithName:@"Main"
                                                                                   bundle:[NSBundle bundleForClass:LWSeatController.class]];
                              LWReadyController *ready = [storyboard instantiateViewControllerWithIdentifier:@"ready"];
                              [self.navigationController pushViewController:ready animated:YES];
                              
                          }
                          onFailure:^(NSError *error) {
                              if (error) {
                                  
                                  UIAlertView *alert = [[UIAlertView alloc] initWithTitle: @"Seat"
                                                                                  message: @"Sorry, this seat has been taken."
                                                                                 delegate:self
                                                                        cancelButtonTitle:@"OK"
                                                                        otherButtonTitles:nil];
                                  [alert show];
                                  
                              }
                          }];

}


@end

