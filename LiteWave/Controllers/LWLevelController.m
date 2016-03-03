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
#import "LWConfiguration.h"

@implementation LWLevelController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.appDelegate = (LWAppDelegate *)[[UIApplication sharedApplication] delegate];
    
    self.view.backgroundColor = [LWConfiguration instance].backgroundColor;
    self.navigationItem.hidesBackButton = YES;
    
    viewTable.hidden = YES;
    imageView.hidden = YES;
    
    selectedLevelIndex = -1;
    
    [self prepareView];
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
    
    [LWConfiguration instance].levelID = [[levels objectAtIndex:selectedLevelIndex] valueForKeyPath:@"name"];
    
    UIStoryboard* storyboard = [UIStoryboard storyboardWithName:@"LWMain"
                                                         bundle:[NSBundle bundleForClass:LWLevelController.class]];
    LWSeatController *seat = [storyboard instantiateViewControllerWithIdentifier:@"seat"];
    [self.navigationController pushViewController:seat animated:YES];
}


- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [levels count];
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return tableView.frame.size.width;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *cellIdentifier = @"CircleTableViewCell";
    
    LWCircleTableViewCell *cell = (LWCircleTableViewCell *)[viewTable dequeueReusableCellWithIdentifier:cellIdentifier];
    if (cell == nil) {
        cell = [[LWCircleTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellIdentifier];
    }
    
    NSDictionary *data = [levels objectAtIndex:indexPath.row];
    
    cell.tableView = tableView;
    cell.index = @(indexPath.row);
    if (!cell.width) {
        cell.width = @(tableView.frame.size.width);
        [cell draw];
    }
    
    cell.nameLabel.text = [data valueForKeyPath:@"name"];
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
    [[LWAPIClient instance] getStadium: [LWConfiguration instance].stadiumID
                           onSuccess:^(id data) {
                               NSError *error2;
                               NSData *jsonData = [NSJSONSerialization dataWithJSONObject:data options:kNilOptions error:&error2];
                               NSString *jsonArray = [[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding];
                               
                               NSDictionary *seatsDict =
                               [NSJSONSerialization JSONObjectWithData: [jsonArray dataUsingEncoding:NSUTF8StringEncoding]
                                                               options: NSJSONReadingMutableContainers
                                                                 error: &error2];
                               
                               [LWConfiguration instance].levels = [[NSDictionary alloc] initWithDictionary:seatsDict copyItems:YES];
                               
                               [self loadLevels];
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
    levels = [[NSMutableArray alloc] initWithArray:[[LWConfiguration instance].levels objectForKey:@"levels"]];
    [viewTable reloadData];
}

- (void)prepareView
{
    CGRect statusBarViewRect = [[UIApplication sharedApplication] statusBarFrame];
    float heightPadding = statusBarViewRect.size.height+self.navigationController.navigationBar.frame.size.height;
    
    [descriptionLabel setFont:[UIFont fontWithName:@"HelveticaNeue" size:self.view.frame.size.width*.06]];
    descriptionLabel.frame = CGRectMake(25,
                                        self.view.frame.size.height - 90 - heightPadding,
                                        self.view.frame.size.width - 50,
                                        100);
    
    viewTable.frame = CGRectMake(self.view.frame.size.width/2 - (self.view.frame.size.width/3)/2,
                                 0,
                                 self.view.frame.size.width/3.0,
                                 self.view.frame.size.height);
    viewTable.backgroundColor = [UIColor colorWithRed:0/255.0 green:0/255.0 blue:0/255.0 alpha:0];
    viewTable.separatorStyle = UITableViewCellSeparatorStyleNone;
    viewTable.hidden = NO;
    [viewTable setShowsVerticalScrollIndicator:NO];
    [viewTable setContentInset:UIEdgeInsetsMake(30,0,0,0)];
    [viewTable setDataSource:self];
    [viewTable setDelegate:self];
    
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

@end

