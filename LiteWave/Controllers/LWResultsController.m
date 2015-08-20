//
//  ResultsViewController.m
//  LiteWave
//
//  Created by mike draghici on 10/24/13.
//  Copyright (c) 2013 LiteWave. All rights reserved.
//

#import "LWResultsController.h"
#import "LWAppDelegate.h"

@interface LWResultsController ()

-(IBAction)returnToMenu:(id)sender;

@end

@implementation LWResultsController

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.

    [self.navigationItem setHidesBackButton:YES animated:NO];
    
    self.appDelegate = (LWAppDelegate *)[[UIApplication sharedApplication] delegate];
}

-(void)viewDidAppear:(BOOL)animated{
    
    [self.navigationItem setHidesBackButton:YES animated:NO];
    
//    
//    appDelegate.sectionID = nil;
//    appDelegate.rowID = nil;
//    appDelegate.seatID = nil;
//    appDelegate.userID = nil;
    self.appDelegate.liteShow = nil;
    
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
    [self.presentingViewController dismissViewControllerAnimated:YES completion:nil];
    [self.presentingViewController dismissViewControllerAnimated:YES completion:nil];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
