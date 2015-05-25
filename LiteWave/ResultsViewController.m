//
//  ResultsViewController.m
//  LiteWave
//
//  Created by mike draghici on 10/24/13.
//  Copyright (c) 2013 LiteWave. All rights reserved.
//

#import "ResultsViewController.h"
#import "LiteWaveAppDelegate.h"

@interface ResultsViewController ()

-(IBAction)returnToMenu:(id)sender;

@end

@implementation ResultsViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.

    [self.navigationItem setHidesBackButton:YES animated:NO];
}

-(void)viewDidAppear:(BOOL)animated{
    
    [self.navigationItem setHidesBackButton:YES animated:NO];
    
    LiteWaveAppDelegate *appDelegate = (LiteWaveAppDelegate *)[[UIApplication sharedApplication] delegate];
//    
//    appDelegate.sectionID = nil;
//    appDelegate.rowID = nil;
//    appDelegate.seatID = nil;
//    appDelegate.userID = nil;
    appDelegate.liteShow = nil;
    
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
//    
//    [defaults removeObjectForKey:@"sectionID"];
//    [defaults removeObjectForKey:@"rowID"];
//    [defaults removeObjectForKey:@"seatID"];
//    [defaults removeObjectForKey:@"userID"];
    [defaults removeObjectForKey:@"liteShow"];
    
    [defaults synchronize];
    
}

-(IBAction)returnToMenu:(id)sender{
    [self.navigationController popToRootViewControllerAnimated:NO];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
