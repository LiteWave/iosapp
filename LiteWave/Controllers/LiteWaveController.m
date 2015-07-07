//
//  LiteWaveViewController.m
//  LiteWave
//
//  Created by mike draghici on 10/24/13.
//  Copyright (c) 2013 LiteWave. All rights reserved.
//

#import "LiteWaveController.h"
#import "LiteWaveAppDelegate.h"
#import "ReadyController.h"
#import "EventsController.h"

#import "Configuration.h"
#import "APIClient.h"

@interface LiteWaveController ()

@end

@implementation LiteWaveController

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.
    
}

- (void)viewDidAppear:(BOOL)animated{
        
    LiteWaveAppDelegate *appDelegate = (LiteWaveAppDelegate *)[[UIApplication sharedApplication] delegate];
    
    if(appDelegate.userID != nil){
        
        UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Main" bundle: nil];
        ReadyController *ready = [storyboard instantiateViewControllerWithIdentifier:@"ready"];
        [self.navigationController pushViewController:ready animated:NO];
        
    } else {
        
        UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Main" bundle: nil];
        EventsController *events = [storyboard instantiateViewControllerWithIdentifier:@"events"];
        [self.navigationController pushViewController:events animated:NO];
        
    }
    
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
