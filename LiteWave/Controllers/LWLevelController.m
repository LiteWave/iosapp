//
//  LevelController.m
//  LiteWave
//
//  Created by David Anderson on 7/26/15.
//  Copyright (c) 2015 LightWave. All rights reserved.
//

#import "LWCircleTableViewCell.h"
#import "LWLevelController.h"
#import "LWSeatController.h"
#import "AFNetworking.h"
#import "LWAppDelegate.h"
#import "LWApiClient.h"


@implementation LWLevelController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.appDelegate = (LWAppDelegate *)[[UIApplication sharedApplication] delegate];
    
    self.view.backgroundColor = self.appDelegate.backgroundColor;
    self.navigationItem.hidesBackButton = YES;
    
    viewTable.hidden = YES;
    
    selectedLevelIndex = -1;
    
    [self getLevels];
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

- (void) selectRow:(NSNotification*)notification {
    
    NSDictionary *message = [notification object];
    NSNumber *index = [message objectForKey:@"index"];
    
    selectedLevelIndex = [index intValue];
    [self clearCells:viewTable  selected:(int)index];
    
    self.appDelegate.levelID = [[levels objectAtIndex:selectedLevelIndex] valueForKeyPath:@"nm"];
    
    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Main" bundle: nil];
    LWSeatController *seat = [storyboard instantiateViewControllerWithIdentifier:@"seat"];
    [self.navigationController pushViewController:seat animated:YES];
}


- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [levels count];
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 100;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *cellIdentifier = @"CircleTableViewCell";
    
    LWCircleTableViewCell *cell = (LWCircleTableViewCell *)[viewTable dequeueReusableCellWithIdentifier:cellIdentifier];
    if (cell == nil) {
        cell = [[LWCircleTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellIdentifier];
    }
    
    NSDictionary *data = [levels objectAtIndex:indexPath.row];
    
    cell.nameLabel.text = [data valueForKeyPath:@"nm"];
    cell.tableView = tableView;
    cell.index = @(indexPath.row);

    if (indexPath.row == selectedLevelIndex)
        [cell select];
    else
        [cell clear];
    
    return cell;
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

- (void)getLevels
{
    [[LWAPIClient instance] getStadium: self.appDelegate.stadiumID
                           onSuccess:^(id data) {
                               NSError *error2;
                               NSData *jsonData = [NSJSONSerialization dataWithJSONObject:data options:kNilOptions error:&error2];
                               NSString *jsonArray = [[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding];
                               
                               NSDictionary *seatsDict =
                               [NSJSONSerialization JSONObjectWithData: [jsonArray dataUsingEncoding:NSUTF8StringEncoding]
                                                               options: NSJSONReadingMutableContainers
                                                                 error: &error2];
                               
                               self.appDelegate.levels = [[NSDictionary alloc] initWithDictionary:seatsDict copyItems:YES];
                               
                               [self loadLevels];
                               [self prepareView];
                           }
                           onFailure:^(NSError *error) {
                               UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Network error"
                                                                               message: @"Stadium seating could not be retrieved."delegate:self
                                                                     cancelButtonTitle:@"OK"
                                                                     otherButtonTitles:nil];
                               [alert show];
                               
                               [spinner stopAnimating];
                           }];
}

- (void)loadLevels
{
    levels = [[NSMutableArray alloc] initWithArray:[self.appDelegate.levels objectForKey:@"levels"]];
}

- (void)prepareView
{
    descriptionLabel.frame = CGRectMake(0,
                                        self.view.frame.size.height - 100,
                                        self.view.frame.size.width,
                                        100);
    
    viewTable.frame = CGRectMake(
                                 self.view.frame.size.width/3.0,
                                 0,
                                 self.view.frame.size.width/3.0,
                                 self.view.frame.size.height);
    viewTable.backgroundColor = self.appDelegate.backgroundColor;
    viewTable.separatorStyle = UITableViewCellSeparatorStyleNone;
    viewTable.hidden = NO;
    [viewTable setShowsVerticalScrollIndicator:NO];
    [viewTable setContentInset:UIEdgeInsetsMake(10,0,0,0)];
    [viewTable setDataSource:self];
    [viewTable setDelegate:self];
}


@end

