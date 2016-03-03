//
//  SeatController.m
//  LiteWave
//
//  Copyright (c) 2015 LightWave. All rights reserved.
//

#import "LWFCircleTableViewCell.h"
#import "LWFSeatController.h"
#import "LWFReadyController.h"
#import "LWFAppDelegate.h"
#import "LWFApiClient.h"
#import "LWFUtility.h"
#import "LWFConfiguration.h"

@implementation LWFSeatController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.appDelegate = (LWFAppDelegate *)[[UIApplication sharedApplication] delegate];
    
    self.view.backgroundColor = [LWFConfiguration instance].backgroundColor;
    
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
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(selectRow:)
                                                 name:@"selectRow" object:nil];
}

- (void)viewWillDisappear:(BOOL)animated{
    [super viewWillDisappear:animated];
    
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
    return tableView.frame.size.width;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *cellIdentifier = @"CircleTableViewCell";
    
    LWFCircleTableViewCell *cell = (LWFCircleTableViewCell *)[tableView dequeueReusableCellWithIdentifier:cellIdentifier];
    if (cell == nil) {
        cell = [[LWFCircleTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellIdentifier];
    }
    
    NSDictionary *data = [[self getTableData:tableView] objectAtIndex:indexPath.row];
    
    cell.tableView = tableView;
    cell.index = @(indexPath.row);
    if (!cell.width) {
        cell.width = @(tableView.frame.size.width);
        [cell draw];
    }

    cell.nameLabel.text = [data valueForKeyPath:@"name"];
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
        [cell.nameLabel setTextColor:[LWFConfiguration instance].textColor];
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
    for (LWFCircleTableViewCell *cell in cells)
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
    [[LWFAPIClient instance] getStadium: [LWFConfiguration instance].stadiumID
                             withLevel: [LWFConfiguration instance].levelID
                             onSuccess:^(id data) {
                                 NSError *error2;
                                 NSData *jsonData = [NSJSONSerialization dataWithJSONObject:data options:kNilOptions error:&error2];
                                 NSString *jsonArray = [[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding];
                                 
                                 NSDictionary *seatsDict =
                                 [NSJSONSerialization JSONObjectWithData: [jsonArray dataUsingEncoding:NSUTF8StringEncoding]
                                                                 options: NSJSONReadingMutableContainers
                                                                   error: &error2];
                                 
                                 [LWFConfiguration instance].seats = [[NSDictionary alloc] initWithDictionary:seatsDict copyItems:YES];
                                 
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
    sections = [[NSMutableArray alloc] initWithArray:[[LWFConfiguration instance].seats objectForKey:@"sections"]];
    
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
    [sectionTable setContentInset:UIEdgeInsetsMake(-sectionTable.frame.size.width*.3,0,joinButton.frame.size.height+25,0)];
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
    [rowTable setContentInset:UIEdgeInsetsMake(-rowTable.frame.size.width*.3,0,joinButton.frame.size.height+25,0)];
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
    [seatTable setContentInset:UIEdgeInsetsMake(-seatTable.frame.size.width*.3,0,joinButton.frame.size.height+25,0)];
    [seatTable setDataSource:self];
    [seatTable setDelegate:self];
    
    sectionLabel = [[UILabel alloc]initWithFrame:CGRectMake(sectionTable.frame.origin.x,
                                                        sectionTable.frame.origin.y-(int)(sectionTable.frame.size.width*.3)/2,
                                                        sectionTable.frame.size.width,
                                                        sectionTable.frame.size.width)];
    [sectionLabel setTextColor:[LWFConfiguration instance].textColor];
    [sectionLabel setFont:[UIFont fontWithName:@"HelveticaNeue" size:sectionLabel.frame.size.width*.22]];
    [sectionLabel setTranslatesAutoresizingMaskIntoConstraints:NO];
    sectionLabel.textAlignment = NSTextAlignmentCenter;
    sectionLabel.text = @"Section";
    [self.view addSubview:sectionLabel];
    
    rowLabel = [[UILabel alloc]initWithFrame:CGRectMake(rowTable.frame.origin.x,
                                                        rowTable.frame.origin.y-(int)(rowTable.frame.size.width*.3)/2,
                                                        rowTable.frame.size.width,
                                                        rowTable.frame.size.width)];
    [rowLabel setTextColor:[LWFConfiguration instance].textColor];
    [rowLabel setFont:[UIFont fontWithName:@"HelveticaNeue" size: rowTable.frame.size.width*.22]];
    [rowLabel setTranslatesAutoresizingMaskIntoConstraints:NO];
    rowLabel.textAlignment = NSTextAlignmentCenter;
    rowLabel.text = @"Row";
    [self.view addSubview:rowLabel];
    
    seatLabel = [[UILabel alloc]initWithFrame:CGRectMake(seatTable.frame.origin.x,
                                                         seatTable.frame.origin.y-(int)(seatTable.frame.size.width*.3)/2,
                                                         seatTable.frame.size.width,
                                                         seatTable.frame.size.width)];
    [seatLabel setTextColor:[LWFConfiguration instance].textColor];
    [seatLabel setFont:[UIFont fontWithName:@"HelveticaNeue" size:seatTable.frame.size.width*.22]];
    [seatLabel setTranslatesAutoresizingMaskIntoConstraints:NO];
    seatLabel.textAlignment = NSTextAlignmentCenter;
    seatLabel.text = @"Seat";
    [self.view addSubview:seatLabel];
    
    [self loadImage];
}

- (void)loadImage
{
    if (![LWFConfiguration instance].logoUrl || ![LWFConfiguration instance].logoImage)
        return;
    
    CGRect statusBarViewRect = [[UIApplication sharedApplication] statusBarFrame];
    float heightPadding = statusBarViewRect.size.height+self.navigationController.navigationBar.frame.size.height;
    
    float height = 700;
    float width = ([LWFConfiguration instance].logoImage.size.width*height)/[LWFConfiguration instance].logoImage.size.height;
    imageView.frame = CGRectMake(self.view.frame.size.width/2 - width/2, self.view.frame.size.height/2 - height/2 - heightPadding, width, height);
    imageView.image = [LWFConfiguration instance].logoImage;
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
    joinButton.layer.borderColor=[LWFConfiguration instance].highlightColor.CGColor;
    joinButton.layer.backgroundColor=[LWFConfiguration instance].highlightColor.CGColor;
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
    [LWFConfiguration instance].sectionID = [[sections objectAtIndex:selectedSectionIndex] valueForKeyPath:@"name"];
    [LWFConfiguration instance].rowID = [[rows objectAtIndex:selectedRowIndex] valueForKeyPath:@"name"];
    [LWFConfiguration instance].seatID = [[seats objectAtIndex:selectedSeatIndex] valueForKeyPath:@"name"];
    
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    [defaults setValue:[LWFConfiguration instance].levelID forKey:@"levelID"];
    [defaults setValue:[LWFConfiguration instance].sectionID forKey:@"sectionID"];
    [defaults setValue:[LWFConfiguration instance].rowID forKey:@"rowID"];
    [defaults setValue:[LWFConfiguration instance].seatID forKey:@"seatID"];
    
    [defaults synchronize];
    
    NSString *mobileTime = [LWFUtility getTodayInGMT];
    
    NSDictionary *userSeat = [NSDictionary dictionaryWithObjectsAndKeys:
                                [LWFConfiguration instance].levelID, @"level",
                                [LWFConfiguration instance].sectionID, @"section",
                                [LWFConfiguration instance].rowID, @"row",
                                [LWFConfiguration instance].seatID, @"seat", nil];
    
    NSDictionary *params = [NSDictionary dictionaryWithObjectsAndKeys:
                                [LWFConfiguration instance].userID,
                                @"userKey",
                                userSeat,
                                @"userSeat",
                                mobileTime,
                                @"mobileTime",
                                @"ios",
                                @"device",
                                nil];
    
    NSLog(@"USER ADDED REQUEST: %@", params);
    
    [[LWFAPIClient instance] joinEvent: [LWFConfiguration instance].eventID
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
                              
                              [LWFConfiguration instance].userLocationID = [userDict objectForKey:@"_id"];
                              [LWFConfiguration instance].mobileOffset = [userDict objectForKey:@"mobileTimeOffset"];
                              
                              NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
                              [defaults setValue:[LWFConfiguration instance].userLocationID forKey:@"userLocationID"];
                              [defaults setValue:[LWFConfiguration instance].mobileOffset forKey:@"mobileOffset"];
                              [defaults synchronize];
                              
                              UIStoryboard* storyboard = [UIStoryboard storyboardWithName:@"LWFMain"
                                                                                   bundle:[NSBundle bundleForClass:LWFSeatController.class]];
                              LWFReadyController *ready = [storyboard instantiateViewControllerWithIdentifier:@"ready"];
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

