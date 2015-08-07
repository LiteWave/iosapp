//
//  SectionController.m
//  LiteWave
//
//  Created by David Anderson on 7/26/15.
//  Copyright (c) 2015 LightWave. All rights reserved.
//

#import "CircleTableViewCell.h"
#import "SectionController.h"
#import "RowController.h"
#import "AFNetworking.h"
#import "AppDelegate.h"
#import "APIClient.h"

@implementation SectionController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    sectionArray = [NSArray arrayWithObjects:@"Section", @"100", @"101", @"102", @"103", @"104", @"105", @"106", @"107", @"108", @"109", @"110", @"111", @"112", @"113", @"114", @"115", @"116", @"117", @"118", @"119", nil];
    
    viewTable.frame = CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height);
    viewTable.backgroundColor = [UIColor blackColor];
    viewTable.separatorStyle = UITableViewCellSeparatorStyleNone;
    [viewTable setDataSource:self];
    [viewTable setDelegate:self];

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

- (void)selectRow:(NSNotification*)index {    
    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Main" bundle: nil];
    RowController *row = [storyboard instantiateViewControllerWithIdentifier:@"row"];
    [self.navigationController pushViewController:row animated:YES];
}


- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [sectionArray count];
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
    cell.nameLabel.text = [sectionArray objectAtIndex:indexPath.row];
    
    return cell;
}



@end

