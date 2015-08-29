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
    logoImageView.hidden = YES;
    poweredByLabel.hidden = YES;
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
    
    [self saveSettings:[event objectForKey:@"settings"]];
    
    [self updateNavigationColor:self.appDelegate.highlightColor];
    [self updateDefaults];
}

- (void)saveSettings:(id)settings {
    self.appDelegate.backgroundColor = [LWUtility getColorFromString:[settings objectForKey:@"backgroundColor"]];
    self.appDelegate.borderColor = [LWUtility getColorFromString:[settings objectForKey:@"borderColor"]];
    self.appDelegate.highlightColor = [LWUtility getColorFromString:[settings objectForKey:@"highlightColor"]];
    self.appDelegate.textColor = [LWUtility getColorFromString:[settings objectForKey:@"textColor"]];
    self.appDelegate.textSelectedColor = [LWUtility getColorFromString:[settings objectForKey:@"textSelectedColor"]];
    self.appDelegate.logoUrl = [settings valueForKey:@"logoUrl"];
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

    [defaults setObject:[LWUtility getStringFromColor:self.appDelegate.backgroundColor] forKey:@"backgroundColor"];
    [defaults setObject:[LWUtility getStringFromColor:self.appDelegate.borderColor] forKey:@"borderColor"];
    [defaults setObject:[LWUtility getStringFromColor:self.appDelegate.highlightColor] forKey:@"highlightColor"];
    [defaults setObject:[LWUtility getStringFromColor:self.appDelegate.textColor] forKey:@"textColor"];
    [defaults setObject:[LWUtility getStringFromColor:self.appDelegate.textSelectedColor] forKey:@"textSelectedColor"];
    
    [defaults setObject:self.appDelegate.logoUrl forKey:@"logoUrl"];
    
    
    [defaults synchronize];
}

- (void)beginEvent:(id)eventID {
    imageView.hidden = YES;
    unavailableLabel.hidden = YES;
    logoImageView.hidden = YES;
    poweredByLabel.hidden = YES;
    
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
    
    [[LWAPIClient instance] getClient:self.appDelegate.clientID
                            onSuccess:^(id data) {
                                NSError *error2;
                                NSData *jsonData = [NSJSONSerialization dataWithJSONObject:data options:kNilOptions error:&error2];
                                NSString *jsonArray = [[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding];
                                
                                NSDictionary *clientDict =
                                [NSJSONSerialization JSONObjectWithData: [jsonArray dataUsingEncoding:NSUTF8StringEncoding]
                                                                options: NSJSONReadingMutableContainers
                                                                  error: &error2];
                                
                                [self saveSettings:[clientDict objectForKey:@"settings"]];
                                
                                [self loadImage];
                                
                                logoImageView.frame = CGRectMake(logoImageView.frame.origin.x,
                                                                 self.view.frame.size.height - logoImageView.frame.size.height - 10,
                                                                 logoImageView.frame.size.width,
                                                                 logoImageView.frame.size.height);
                                logoImageView.hidden = NO;
                                
                                poweredByLabel.frame = CGRectMake(poweredByLabel.frame.origin.x,
                                                                 logoImageView.frame.origin.y - 20,
                                                                 poweredByLabel.frame.size.width,
                                                                 poweredByLabel.frame.size.height);
                                poweredByLabel.hidden = NO;
                                
                                unavailableLabel.hidden = NO;
                            }
                            onFailure:^(NSError *error) {
                                UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Network error"
                                                                                message: @"Need an internet connection to continue."delegate:self
                                                                      cancelButtonTitle:@"OK"
                                                                      otherButtonTitles:nil];
                                [alert show];
                            }];

    [self clearEvent];
}

- (void)loadImage
{
    NSURL *url = [NSURL URLWithString:self.appDelegate.logoUrl];
    NSData *imageData = [NSData dataWithContentsOfURL:url];
    UIImage *image = [[UIImage alloc] initWithData:imageData];
    
//    float height = 140;
//    float width = (image.size.width*height)/image.size.height;
//    imageView.frame = CGRectMake(self.view.frame.size.width/2 - width/2, 45, width, height);
//    imageView.image = image;
    
    float height = 700;
    float width = (image.size.width*height)/image.size.height;
    imageView.frame = CGRectMake(self.view.frame.size.width/2 - width/2, self.view.frame.size.height/2 - height/2, width, height);
    imageView.image = image;
    imageView.alpha = .05;
    imageView.hidden = NO;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
