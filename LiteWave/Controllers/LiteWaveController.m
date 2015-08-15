//
//  LiteWaveController.m
//  LiteWave
//
//  Copyright (c) 2013 LiteWave. All rights reserved.
//

#import "LiteWaveController.h"
#import "AppDelegate.h"
#import "LevelController.h"
#import "ReadyController.h"

#import "Configuration.h"
#import "APIClient.h"

@interface LiteWaveController ()

@end

@implementation LiteWaveController

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.
    self.appDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    
    self.navigationController.navigationBar.barTintColor = self.appDelegate.highlightColor;

    self.navigationController.navigationBar.tintColor = [UIColor whiteColor];
    [self.navigationController.navigationBar
     setTitleTextAttributes:@{NSForegroundColorAttributeName : [UIColor whiteColor]}];
    self.navigationController.navigationBar.translucent = NO;
}

- (void)viewDidAppear:(BOOL)animated{

    if (self.appDelegate.eventID != nil) {
        [self beginEvent:self.appDelegate.eventID];
    } else {
        [self getEvent];
    }
    
}

- (void)getEvent {
    [[APIClient instance] getEvents:self.appDelegate.clientID
                          onSuccess:^(id data) {
                              NSArray *eventsArray = [[NSArray alloc] initWithArray:data copyItems:YES];
                              if ([eventsArray count] > 0) {
                                  NSDictionary *event = [eventsArray objectAtIndex:0];
                                  [self saveEvent:event];
                                  [self beginEvent:[event valueForKey:@"_id"]];
                              } else {
                                  [self showNoEvent];
                              }
                          }
                          onFailure:^(NSError *error) {
                              [self showNoEvent];
                          }];

}

- (void)saveEvent:(id)event {
    self.appDelegate.eventID = [event valueForKey:@"_id"];
    self.appDelegate.eventName = [event valueForKey:@"name"];
    
    NSDateFormatter *dateformat = [[NSDateFormatter alloc] init];
    [dateformat setDateFormat:@"yyyy-MM-dd'T'HH:mm:ss'.000Z'"];
    [dateformat setTimeZone:[NSTimeZone timeZoneWithName:@"GMT"]];
    self.appDelegate.eventDate = [dateformat dateFromString:[event valueForKey:@"eventAt"]];
    
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    
    [defaults setValue:self.appDelegate.eventID forKey:@"eventID"];
    [defaults setValue:self.appDelegate.stadiumID forKey:@"stadiumID"];
    [defaults setValue:self.appDelegate.eventName forKey:@"eventName"];
    [defaults setObject:self.appDelegate.eventDate forKey:@"eventDate"];
    
    [defaults synchronize];
}

- (void)clearEvent {
    self.appDelegate.eventID = nil;
    self.appDelegate.eventName = nil;
    self.appDelegate.eventDate = nil;
    
    self.appDelegate.seatID = nil;
    self.appDelegate.rowID = nil;
    self.appDelegate.sectionID = nil;
    
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    
    [defaults setValue:self.appDelegate.eventID forKey:@"eventID"];
    [defaults setValue:self.appDelegate.eventName forKey:@"eventName"];
    [defaults setObject:self.appDelegate.eventDate forKey:@"eventDate"];
    
    [defaults setObject:self.appDelegate.eventDate forKey:@"seatID"];
    [defaults setObject:self.appDelegate.eventDate forKey:@"rowID"];
    [defaults setObject:self.appDelegate.eventDate forKey:@"sectionID"];
    
    [defaults synchronize];
}

- (void)beginEvent:(id)eventID {
    
    // if the day is no longer the same, show no event
    NSDate *todayDate = [NSDate date];
    NSDateFormatter *dateformat = [[NSDateFormatter alloc] init];
    [dateformat setDateFormat:@"dd"];
    [dateformat setTimeZone:[NSTimeZone timeZoneWithName:@"GMT"]];
    
    NSString *today = [dateformat stringFromDate:todayDate];
    NSString *eventDay = [dateformat stringFromDate:self.appDelegate.eventDate];
    
    /*
    if (![today isEqualToString: eventDay]) {
        [self showNoEvent];
        return;
    }
     */
    
    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Main" bundle: nil];
    
    LevelController *level = [storyboard instantiateViewControllerWithIdentifier:@"level"];
    [self.navigationController pushViewController:level animated:NO];
    
    if (self.appDelegate.seatID != nil) {
        ReadyController *ready = [storyboard instantiateViewControllerWithIdentifier:@"ready"];
        [self.navigationController pushViewController:ready animated:NO];
    } else {
        LevelController *level = [storyboard instantiateViewControllerWithIdentifier:@"level"];
        [self.navigationController pushViewController:level animated:NO];
    }
}

- (void)showNoEvent {
    [self clearEvent];
}


- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
