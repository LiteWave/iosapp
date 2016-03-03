//
//  LiteWaveController.m
//  LiteWave
//
//  Copyright (c) 2013 LiteWave. All rights reserved.
//

#import "LWMainController.h"
#import "LWAppDelegate.h"
#import "LWLevelController.h"
#import "LWReadyController.h"

#import "LWConfiguration.h"
#import "LWApiClient.h"
#import "LWUtility.h"

@interface LWMainController ()

@end

@implementation LWMainController

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.
    self.appDelegate = (LWAppDelegate *)[[UIApplication sharedApplication] delegate];
    
    [self updateNavigationColor: [LWConfiguration instance].defaultColor];
    
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
    [[LWAPIClient instance] getEvents:[LWConfiguration instance].clientID
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
    self.view.backgroundColor = [LWConfiguration instance].backgroundColor;
    
    [LWConfiguration instance].eventID = [event valueForKey:@"_id"];
    [LWConfiguration instance].eventName = [event valueForKey:@"name"];
    
    NSDateFormatter *dateformat = [[NSDateFormatter alloc] init];
    [dateformat setDateFormat:@"yyyy-MM-dd'T'HH:mm:ss'.000Z'"];
    [dateformat setTimeZone:[NSTimeZone timeZoneWithName:@"GMT"]];
    [LWConfiguration instance].eventDate = [dateformat dateFromString:[event valueForKey:@"date"]];
    
    [LWConfiguration instance].stadiumID = [event valueForKey:@"_stadiumId"];
    
    [self saveSettings:[event objectForKey:@"settings"]];
    
    [self updateNavigationColor:[LWConfiguration instance].highlightColor];
    [self updateDefaults];
}

- (void)saveSettings:(id)settings {
    [LWConfiguration instance].backgroundColor = [LWUtility getColorFromString:[settings objectForKey:@"backgroundColor"]];
    [LWConfiguration instance].borderColor = [LWUtility getColorFromString:[settings objectForKey:@"borderColor"]];
    [LWConfiguration instance].highlightColor = [LWUtility getColorFromString:[settings objectForKey:@"highlightColor"]];
    [LWConfiguration instance].textColor = [LWUtility getColorFromString:[settings objectForKey:@"textColor"]];
    [LWConfiguration instance].textSelectedColor = [LWUtility getColorFromString:[settings objectForKey:@"textSelectedColor"]];
    [LWConfiguration instance].logoUrl = [settings valueForKey:@"logoUrl"];
    if ([LWConfiguration instance].logoUrl) {
        NSURL *url = [NSURL URLWithString:[LWConfiguration instance].logoUrl];
        NSData *imageData = [NSData dataWithContentsOfURL:url];
        [LWConfiguration instance].logoImage = [[UIImage alloc] initWithData:imageData];
    }
    if ([settings objectForKey:@"pollInterval"]) {
        [LWConfiguration instance].pollInterval = [settings valueForKey:@"pollInterval"];
    }
}

- (void)clearEvent {
    [LWConfiguration instance].eventID = nil;
    [LWConfiguration instance].eventName = nil;
    [LWConfiguration instance].eventDate = nil;

    [LWConfiguration instance].stadiumID = nil;
    [LWConfiguration instance].userLocationID = nil;
    [LWConfiguration instance].seatID = nil;
    [LWConfiguration instance].rowID = nil;
    [LWConfiguration instance].sectionID = nil;
    [LWConfiguration instance].levelID = nil;
    
    [self updateDefaults];
}

- (void)updateDefaults {
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    
    [defaults setObject:[LWConfiguration instance].stadiumID forKey:@"stadiumID"];
    [defaults setObject:[LWConfiguration instance].seatID forKey:@"seatID"];
    [defaults setObject:[LWConfiguration instance].rowID forKey:@"rowID"];
    [defaults setObject:[LWConfiguration instance].sectionID forKey:@"sectionID"];
    [defaults setObject:[LWConfiguration instance].levelID forKey:@"levelID"];

    [defaults setObject:[LWUtility getStringFromColor:[LWConfiguration instance].backgroundColor] forKey:@"backgroundColor"];
    [defaults setObject:[LWUtility getStringFromColor:[LWConfiguration instance].borderColor] forKey:@"borderColor"];
    [defaults setObject:[LWUtility getStringFromColor:[LWConfiguration instance].highlightColor] forKey:@"highlightColor"];
    [defaults setObject:[LWUtility getStringFromColor:[LWConfiguration instance].textColor] forKey:@"textColor"];
    [defaults setObject:[LWUtility getStringFromColor:[LWConfiguration instance].textSelectedColor] forKey:@"textSelectedColor"];
    
    [defaults setObject:[LWConfiguration instance].pollInterval forKey:@"pollInterval"];
    [defaults setObject:[LWConfiguration instance].logoUrl forKey:@"logoUrl"];
    
    
    [defaults synchronize];
}

- (void)beginEvent:(id)eventID {
    imageView.hidden = YES;
    unavailableLabel.hidden = YES;
    logoImageView.hidden = YES;
    poweredByLabel.hidden = YES;
    
    // remove observers
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    
    UIStoryboard* storyboard = [UIStoryboard storyboardWithName:@"LWMain"
                                                         bundle:[NSBundle bundleForClass:LWMainController.class]];
    
    LWLevelController *level = [storyboard instantiateViewControllerWithIdentifier:@"level"];
    [self.navigationController pushViewController:level animated:NO];
    
    if ([LWConfiguration instance].userLocationID != nil) {
        LWReadyController *ready = [storyboard instantiateViewControllerWithIdentifier:@"ready"];
        [self.navigationController pushViewController:ready animated:NO];
    }
}

- (void)handleNoEvent {
    // add observer for when app becomes active
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(onBecomeActive) name:UIApplicationDidBecomeActiveNotification object:[UIApplication sharedApplication]];
    
    [[LWAPIClient instance] getClient:[LWConfiguration instance].clientID
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
                                
                                logoImageView.frame = CGRectMake(self.view.frame.size.width/2 - logoImageView.frame.size.width/2,
                                                                 self.view.frame.size.height - logoImageView.frame.size.height - 10,
                                                                 logoImageView.frame.size.width,
                                                                 logoImageView.frame.size.height);
                                logoImageView.hidden = NO;
                                

                                poweredByLabel.hidden = NO;
                                poweredByLabel.frame = CGRectMake(self.view.frame.size.width/2 - (self.view.frame.size.width*.85)/2,
                                                                  logoImageView.frame.origin.y - 20,
                                                                  self.view.frame.size.width*.85,
                                                                  poweredByLabel.frame.size.height);

                                [unavailableLabel setFont:[UIFont fontWithName:@"HelveticaNeue" size:self.view.frame.size.width*.065]];
                                unavailableLabel.hidden = NO;
                                unavailableLabel.frame = CGRectMake(self.view.frame.size.width/2 - (self.view.frame.size.width*.85)/2,
                                                                  self.view.frame.size.height*.03,
                                                                  self.view.frame.size.width*.85,
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
    if (![LWConfiguration instance].logoUrl || ![LWConfiguration instance].logoImage)
        return;
    
    float height = 700;
    float width = ([LWConfiguration instance].logoImage.size.width*height)/[LWConfiguration instance].logoImage.size.height;
    imageView.frame = CGRectMake(self.view.frame.size.width/2 - width/2, self.view.frame.size.height/2 - height/2, width, height);
    imageView.image = [LWConfiguration instance].logoImage;
    imageView.alpha = .05;
    imageView.hidden = NO;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
