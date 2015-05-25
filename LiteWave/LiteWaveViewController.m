//
//  LiteWaveViewController.m
//  LiteWave
//
//  Created by mike draghici on 10/24/13.
//  Copyright (c) 2013 LiteWave. All rights reserved.
//

#import "LiteWaveViewController.h"
#import "LiteWaveAppDelegate.h"
#import "ReadyViewController.h"
#import "EventsViewController.h"

#import "Configuration.h"

@interface LiteWaveViewController ()

@end

@implementation LiteWaveViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.
    
}

- (void)viewDidAppear:(BOOL)animated{
    
    NSLog(@"API URL: %@", [[Configuration instance] get: @"apiURL"]);
    
    LiteWaveAppDelegate *appDelegate = (LiteWaveAppDelegate *)[[UIApplication sharedApplication] delegate];
    
    if(appDelegate.userID != nil){
        
        UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Main" bundle: nil];
        ReadyViewController *ready = [storyboard instantiateViewControllerWithIdentifier:@"ready"];
        [self.navigationController pushViewController:ready animated:NO];
        
    } else {
        
        UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Main" bundle: nil];
        EventsViewController *events = [storyboard instantiateViewControllerWithIdentifier:@"events"];
        [self.navigationController pushViewController:events animated:NO];
        
    }
    
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
