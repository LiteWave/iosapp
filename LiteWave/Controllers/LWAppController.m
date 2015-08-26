//
//  LiteWaveController.m
//  LiteWave
//
//  Copyright (c) 2013 LiteWave. All rights reserved.
//

#import "LWAppController.h"
#import "LWAppDelegate.h"
#import "LWLevelController.h"
#import "LWReadyController.h"

#import "LWConfiguration.h"
#import "LWApiClient.h"
#import "LWUtility.h"

@interface LWAppController ()

@end

@implementation LWAppController

- (void)viewDidLoad
{
    [super viewDidLoad];
//    [self clearEvent];
//    return;
	// Do any additional setup after loading the view, typically from a nib.
    self.appDelegate = (LWAppDelegate *)[[UIApplication sharedApplication] delegate];
    
    [self updateNavigationColor: self.appDelegate.defaultColor];
    
    imageView.hidden = YES;
    unavailableLabel.hidden = YES;
}

- (void)viewDidAppear:(BOOL)animated {
    if (self.appDelegate.eventID != nil) {
        // if the day is no longer the same, show no event
        if ([LWUtility isToday:self.appDelegate.eventDate]) {
            [self beginEvent:self.appDelegate.eventID];
        } else {
            [self handleNoEvent];
        }
    } else {
        [self getEvent];
    }
}

- (void)onBecomeActive
{
    [self getEvent];
}

- (void)updateNavigationColor:(UIColor*)color
{
    self.navigationController.navigationBar.barTintColor = color;
    self.navigationController.navigationBar.tintColor = [UIColor whiteColor];
    [self.navigationController.navigationBar setTitleTextAttributes:@{NSForegroundColorAttributeName : [UIColor whiteColor]}];
    self.navigationController.navigationBar.translucent = NO;
}

- (void)getEvent {
    [[LWAPIClient instance] getEvents:self.appDelegate.clientID
                            onSuccess:^(id data) {
                                NSArray *eventsArray = [[NSArray alloc] initWithArray:data copyItems:YES];
                                NSDictionary *todayEvent;

                                NSDateFormatter *dayformat = [[NSDateFormatter alloc] init];
                                [dayformat setDateFormat:@"dd"];
                                [dayformat setTimeZone:[NSTimeZone timeZoneWithName:@"GMT"]];
                                
                                NSDateFormatter *dateformat = [[NSDateFormatter alloc] init];
                                [dateformat setDateFormat:@"yyyy-MM-dd'T'HH:mm:ss'.000Z'"];
                                [dateformat setTimeZone:[NSTimeZone timeZoneWithName:@"GMT"]];

                                for (NSDictionary *event in eventsArray) {
                                    NSDate *eventDate = [dateformat dateFromString:[event valueForKey:@"date"]];

                                    if ([LWUtility isToday:eventDate]) {
                                      todayEvent = event;
                                      break;
                                    }
                                }

                                // if there is an event today, save and begin
                                if (todayEvent) {
                                  [self saveEvent:todayEvent];
                                  [self beginEvent:[todayEvent valueForKey:@"_id"]];
                                } else {
                                  [self handleNoEvent];
                                }
                            }
                            onFailure:^(NSError *error) {
                                [self handleNoEvent];
                            }];

}

- (void)saveEvent:(id)event {
    self.view.backgroundColor = self.appDelegate.backgroundColor;
    
    self.appDelegate.eventID = [event valueForKey:@"_id"];
    self.appDelegate.eventName = [event valueForKey:@"name"];
    
    NSDateFormatter *dateformat = [[NSDateFormatter alloc] init];
    [dateformat setDateFormat:@"yyyy-MM-dd'T'HH:mm:ss'.000Z'"];
    [dateformat setTimeZone:[NSTimeZone timeZoneWithName:@"GMT"]];
    self.appDelegate.eventDate = [dateformat dateFromString:[event valueForKey:@"date"]];
    
    self.appDelegate.stadiumID = [event valueForKey:@"_stadiumId"];
    
    NSDictionary *settings = [event objectForKey:@"settings"];
    
    // colors
    self.appDelegate.backgroundColor = [LWUtility getColorFromString:[settings objectForKey:@"backgroundColor"]];
    self.appDelegate.borderColor = [LWUtility getColorFromString:[settings objectForKey:@"borderColor"]];
    self.appDelegate.highlightColor = [LWUtility getColorFromString:[settings objectForKey:@"highlightColor"]];
    self.appDelegate.textColor = [LWUtility getColorFromString:[settings objectForKey:@"textColor"]];
    self.appDelegate.textSelectedColor = [LWUtility getColorFromString:[settings objectForKey:@"textSelectedColor"]];
    
    [self updateNavigationColor:self.appDelegate.highlightColor];
    [self updateDefaults];
}

- (void)clearEvent {
    self.appDelegate.eventID = nil;
    self.appDelegate.eventName = nil;
    self.appDelegate.eventDate = nil;
    
    self.appDelegate.stadiumID = nil;
    self.appDelegate.seatID = nil;
    self.appDelegate.rowID = nil;
    self.appDelegate.sectionID = nil;
    self.appDelegate.levelID = nil;
    
    // colors
    self.appDelegate.backgroundColor = nil;
    self.appDelegate.borderColor = nil;
    self.appDelegate.highlightColor = nil;
    self.appDelegate.textColor = nil;
    self.appDelegate.textSelectedColor = nil;
    
    [self updateDefaults];
}

- (void)updateDefaults {
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    
    [defaults setValue:self.appDelegate.eventID forKey:@"eventID"];
    [defaults setValue:self.appDelegate.eventName forKey:@"eventName"];
    [defaults setObject:self.appDelegate.eventDate forKey:@"eventDate"];
    
    [defaults setObject:self.appDelegate.stadiumID forKey:@"stadiumID"];
    [defaults setObject:self.appDelegate.seatID forKey:@"seatID"];
    [defaults setObject:self.appDelegate.rowID forKey:@"rowID"];
    [defaults setObject:self.appDelegate.sectionID forKey:@"sectionID"];
    [defaults setObject:self.appDelegate.levelID forKey:@"levelID"];
    NSLog(@"%@", [self.appDelegate.backgroundColor description]);
    // colors
    [defaults setObject:[LWUtility getStringFromColor:self.appDelegate.backgroundColor] forKey:@"backgroundColor"];
    [defaults setObject:[LWUtility getStringFromColor:self.appDelegate.borderColor] forKey:@"borderColor"];
    [defaults setObject:[LWUtility getStringFromColor:self.appDelegate.highlightColor] forKey:@"highlightColor"];
    [defaults setObject:[LWUtility getStringFromColor:self.appDelegate.textColor] forKey:@"textColor"];
    [defaults setObject:[LWUtility getStringFromColor:self.appDelegate.textSelectedColor] forKey:@"textSelectedColor"];
    
    [defaults synchronize];
}

- (void)beginEvent:(id)eventID {
    imageView.hidden = YES;
    unavailableLabel.hidden = YES;
    
    // remove observers
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    
    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Main" bundle: nil];
    
    LWLevelController *level = [storyboard instantiateViewControllerWithIdentifier:@"level"];
    [self.navigationController pushViewController:level animated:NO];
    
    if (self.appDelegate.seatID != nil) {
        LWReadyController *ready = [storyboard instantiateViewControllerWithIdentifier:@"ready"];
        [self.navigationController pushViewController:ready animated:NO];
    }
}

- (void)handleNoEvent {
    
    // add observer for when app becomes active
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(onBecomeActive) name:UIApplicationDidBecomeActiveNotification object:[UIApplication sharedApplication]];

    unavailableLabel.hidden = NO;
    imageView.hidden = NO;
    
    [self clearEvent];
}


- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
