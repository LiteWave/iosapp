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
    
    self.appDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    
    CGRect statusBarViewRect = [[UIApplication sharedApplication] statusBarFrame];
    float heightPadding = statusBarViewRect.size.height+self.navigationController.navigationBar.frame.size.height;
    
    descriptionLabel.frame = CGRectMake(
                                        50/2,
                                        self.view.frame.size.height - heightPadding - 110,
                                        self.view.frame.size.width - 50,
                                        110);
    
    
    levelArray = [NSArray arrayWithObjects:@"100", @"200", @"300", nil];
    
    viewTable.frame = CGRectMake(
                                 self.view.frame.size.width/3.0,
                                 0,
                                 self.view.frame.size.width/3.0,
                                 self.view.frame.size.height - descriptionLabel.frame.size.height);
    viewTable.backgroundColor = [UIColor blackColor];
    viewTable.separatorStyle = UITableViewCellSeparatorStyleNone;
    [viewTable setContentInset:UIEdgeInsetsMake(70,0,0,0)];
    [viewTable setDataSource:self];
    [viewTable setDelegate:self];
    
    [self getSeats];
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

- (void)getSeats
{
    [[APIClient instance] getStadium: self.appDelegate.stadiumID
                           onSuccess:^(id data) {
                               NSError *error2;
                               NSData *jsonData = [NSJSONSerialization dataWithJSONObject:data options:kNilOptions error:&error2];
                               NSString *jsonArray = [[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding];
                               NSDictionary *seatsDict =
                               [NSJSONSerialization JSONObjectWithData: [jsonArray dataUsingEncoding:NSUTF8StringEncoding]
                                                               options: NSJSONReadingMutableContainers
                                                                 error: &error2];
                               
                               self.appDelegate.seatsArray = [[NSDictionary alloc] initWithDictionary:seatsDict copyItems:YES];
                               
                           }
                           onFailure:^(NSError *error) {
                               UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Network Error" message:error.localizedDescription delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil];
                               [alert show];
                               
                               [spinner stopAnimating];
                               [self.navigationController popViewControllerAnimated:YES];
                           }];
    
}

@end

