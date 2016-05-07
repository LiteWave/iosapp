//
//  LiteWaveController.m
//  LiteWave
//
//  Copyright (c) 2013 LiteWave. All rights reserved.
//

#import "LWFMainController.h"
#import "LWFAppDelegate.h"
#import "LWFLevelController.h"
#import "LWFReadyController.h"

#import "LWFConfiguration.h"
#import "LWFApiClient.h"
#import "LWFUtility.h"

@interface LWFMainController ()

@end

@implementation LWFMainController

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.
    self.appDelegate = (LWFAppDelegate *)[[UIApplication sharedApplication] delegate];
    appSize = [LWFUtility determineAppSize:self];
    
    [self updateNavigationColor: [LWFConfiguration instance].defaultColor];

    imageView.hidden = YES;
    unavailableLabel.hidden = YES;
    logoImageView.hidden = YES;
    poweredByLabel.hidden = YES;
}

- (void)viewDidAppear:(BOOL)animated {
    [self getEvent];
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
    [[LWFAPIClient instance] getEvents:[LWFConfiguration instance].clientID
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

                                    if ([LWFUtility isToday:eventDate]) {
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
    self.view.backgroundColor = [LWFConfiguration instance].backgroundColor;
    
    // if the event changed, clear the seat info
    if (![[LWFConfiguration instance].eventID isEqualToString:[event valueForKey:@"_id"]]) {
        [LWFConfiguration instance].userLocationID = nil;
    }
    
    [LWFConfiguration instance].eventID = [event valueForKey:@"_id"];
    [LWFConfiguration instance].eventName = [event valueForKey:@"name"];
    
    NSDateFormatter *dateformat = [[NSDateFormatter alloc] init];
    [dateformat setDateFormat:@"yyyy-MM-dd'T'HH:mm:ss'.000Z'"];
    [dateformat setTimeZone:[NSTimeZone timeZoneWithName:@"GMT"]];
    [LWFConfiguration instance].eventDate = [dateformat dateFromString:[event valueForKey:@"date"]];
    
    [LWFConfiguration instance].stadiumID = [event valueForKey:@"_stadiumId"];
    
    [self saveSettings:[event objectForKey:@"settings"]];
    
    [self updateNavigationColor:[LWFConfiguration instance].highlightColor];
    [self updateDefaults];
}

- (void)saveSettings:(id)settings {
    [LWFConfiguration instance].backgroundColor = [LWFUtility getColorFromString:[settings objectForKey:@"backgroundColor"]];
    [LWFConfiguration instance].borderColor = [LWFUtility getColorFromString:[settings objectForKey:@"borderColor"]];
    [LWFConfiguration instance].highlightColor = [LWFUtility getColorFromString:[settings objectForKey:@"highlightColor"]];
    [LWFConfiguration instance].textColor = [LWFUtility getColorFromString:[settings objectForKey:@"textColor"]];
    [LWFConfiguration instance].textSelectedColor = [LWFUtility getColorFromString:[settings objectForKey:@"textSelectedColor"]];
    [LWFConfiguration instance].logoUrl = [settings valueForKey:@"logoUrl"];
    if ([LWFConfiguration instance].logoUrl) {
        NSURL *url = [NSURL URLWithString:[LWFConfiguration instance].logoUrl];
        NSData *imageData = [NSData dataWithContentsOfURL:url];
        [LWFConfiguration instance].logoImage = [[UIImage alloc] initWithData:imageData];
    }
    if ([settings objectForKey:@"pollInterval"]) {
        [LWFConfiguration instance].pollInterval = [settings valueForKey:@"pollInterval"];
    }
}

- (void)clearEvent {
    [LWFConfiguration instance].eventID = nil;
    [LWFConfiguration instance].eventName = nil;
    [LWFConfiguration instance].eventDate = nil;

    [LWFConfiguration instance].stadiumID = nil;
    [LWFConfiguration instance].userLocationID = nil;
    [LWFConfiguration instance].seatID = nil;
    [LWFConfiguration instance].rowID = nil;
    [LWFConfiguration instance].sectionID = nil;
    [LWFConfiguration instance].levelID = nil;
    
    [self updateDefaults];
}

- (void)updateDefaults {
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    
    [defaults setObject:[LWFConfiguration instance].eventID forKey:@"eventID"];
    [defaults setObject:[LWFConfiguration instance].stadiumID forKey:@"stadiumID"];
    [defaults setObject:[LWFConfiguration instance].seatID forKey:@"seatID"];
    [defaults setObject:[LWFConfiguration instance].rowID forKey:@"rowID"];
    [defaults setObject:[LWFConfiguration instance].sectionID forKey:@"sectionID"];
    [defaults setObject:[LWFConfiguration instance].levelID forKey:@"levelID"];

    [defaults setObject:[LWFUtility getStringFromColor:[LWFConfiguration instance].backgroundColor] forKey:@"backgroundColor"];
    [defaults setObject:[LWFUtility getStringFromColor:[LWFConfiguration instance].borderColor] forKey:@"borderColor"];
    [defaults setObject:[LWFUtility getStringFromColor:[LWFConfiguration instance].highlightColor] forKey:@"highlightColor"];
    [defaults setObject:[LWFUtility getStringFromColor:[LWFConfiguration instance].textColor] forKey:@"textColor"];
    [defaults setObject:[LWFUtility getStringFromColor:[LWFConfiguration instance].textSelectedColor] forKey:@"textSelectedColor"];
    
    [defaults setObject:[LWFConfiguration instance].pollInterval forKey:@"pollInterval"];
    [defaults setObject:[LWFConfiguration instance].logoUrl forKey:@"logoUrl"];
    
    
    [defaults synchronize];
}

- (void)beginEvent:(id)eventID {
    imageView.hidden = YES;
    unavailableLabel.hidden = YES;
    logoImageView.hidden = YES;
    poweredByLabel.hidden = YES;
    
    // remove observers
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    
    UIStoryboard* storyboard = [LWFUtility getStoryboard:self];
    LWFLevelController *level = [storyboard instantiateViewControllerWithIdentifier:@"level"];
    [self.navigationController pushViewController:level animated:NO];
    
    if ([LWFConfiguration instance].userLocationID != nil) {
        LWFReadyController *ready = [storyboard instantiateViewControllerWithIdentifier:@"ready"];
        [self.navigationController pushViewController:ready animated:NO];
    }
}

- (void)handleNoEvent {
    // add observer for when app becomes active
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(onBecomeActive) name:UIApplicationDidBecomeActiveNotification object:[UIApplication sharedApplication]];
    
    [[LWFAPIClient instance] getClient:[LWFConfiguration instance].clientID
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
                                
                                logoImageView.frame = CGRectMake(appSize.width/2 - logoImageView.frame.size.width/2,
                                                                 appSize.height - logoImageView.frame.size.height - 10,
                                                                 logoImageView.frame.size.width,
                                                                 logoImageView.frame.size.height);
                                logoImageView.hidden = NO;
                                
                                poweredByLabel.hidden = NO;
                                poweredByLabel.frame = CGRectMake(appSize.width/2 - (appSize.width*.85)/2,
                                                                  logoImageView.frame.origin.y - 20,
                                                                  appSize.width*.85,
                                                                  poweredByLabel.frame.size.height);

                                [unavailableLabel setFont:[UIFont fontWithName:@"HelveticaNeue" size:appSize.width*.065]];
                                unavailableLabel.hidden = NO;
                                unavailableLabel.frame = CGRectMake(appSize.width/2 - (appSize.width*.85)/2,
                                                                  appSize.height*.03,
                                                                  appSize.width*.85,
                                                                  unavailableLabel.frame.size.height);
                            }
                            onFailure:^(NSError *error) {
                                // no event
                                NSLog(@"No internet connection");
                            }];

    [self clearEvent];
}

- (void)loadImage
{
    if (![LWFConfiguration instance].logoUrl || ![LWFConfiguration instance].logoImage)
        return;
    
    float height = appSize.height*1.18; // make image 118% of view
    float width = ([LWFConfiguration instance].logoImage.size.width*height)/[LWFConfiguration instance].logoImage.size.height;
    imageView.frame = CGRectMake(appSize.width/2 - width/2, appSize.height/2 - height/2, width, height);
    imageView.image = [LWFConfiguration instance].logoImage;
    imageView.alpha = .05;
    imageView.hidden = NO;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
