//
//  ReadyViewController.m
//  LiteWave
//
//  Created by mike draghici on 10/24/13.
//  Copyright (c) 2013 LiteWave. All rights reserved.
//

#import "LWReadyController.h"
#import "LWShowController.h"
#import "LWAppDelegate.h"
#import "AFNetworking.h"
#import "LWApiClient.h"

@interface LWReadyController ()

-(IBAction)withdrawUser:(id)sender;
-(IBAction)retryFetch:(id)sender;
-(IBAction)changeSeat:(id)sender;

@end

@implementation LWReadyController

- (void)viewDidLoad
{
    [super viewDidLoad];
	
    [self.navigationItem setHidesBackButton:YES animated:NO];
    
    self.appDelegate = (LWAppDelegate *)[[UIApplication sharedApplication] delegate];
    
    pressedChangeSeat = NO;
    
    [changeButton addTarget: self
                  action: @selector(changeSeat:)
        forControlEvents: UIControlEventTouchUpInside];
    
    // add observer for when app becomes active
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(onBecomeActive) name:UIApplicationDidBecomeActiveNotification object:[UIApplication sharedApplication]];
    
    [self prepareView];
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    
    // remove observers
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    
    if (pressedChangeSeat)
        return;
    
    if (self.isMovingFromParentViewController) {
        [self withdraw];
    }
}

- (void)viewDidAppear:(BOOL)animated{
    
    [self.navigationItem setHidesBackButton:NO animated:NO];

    self.title = self.appDelegate.eventName;

    mySeat.text = [NSString stringWithFormat:@"%@-%@-%@", self.appDelegate.sectionID, self.appDelegate.rowID, self.appDelegate.seatID];
    
    [self fetchShow];
}

-(void)fetchShow {
    
    if (self.appDelegate.liteShow) {
        NSLog(@"saved liteshow = %@", self.appDelegate.liteShow);
    } else {
        [[LWAPIClient instance] getShows: self.appDelegate.eventID
                             onSuccess: ^(id data) {
                                 NSError *error2;
                                 NSData *jsonData = [NSJSONSerialization dataWithJSONObject:data options:kNilOptions error:&error2];
                                 NSString *jsonArray = [[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding];
                                 
                                 NSArray *showDict =
                                 [NSJSONSerialization JSONObjectWithData: [jsonArray dataUsingEncoding:NSUTF8StringEncoding]
                                                                 options: NSJSONReadingMutableContainers
                                                                   error: &error2];
                                 
                                 self.appDelegate.liteshowArray = [[NSArray alloc] initWithArray:showDict copyItems:YES];
                                 
                                 if (self.appDelegate.liteshowArray.count == 0) {
                                     [self disableJoin];
                                 } else {
                                     NSDictionary *liteShowDict = [self.appDelegate.liteshowArray objectAtIndex:0];
                                     
                                     NSString *liteShowID = [liteShowDict valueForKey:@"_id"];
                                     
                                     [[LWAPIClient instance] getShow: self.appDelegate.eventID
                                                              show: liteShowID
                                                         onSuccess:^(id data) {
                                                             NSError *error2;
                                                             NSData *jsonData = [NSJSONSerialization dataWithJSONObject:data options:kNilOptions error:&error2];
                                                             NSString *jsonArray = [[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding];
                                                             
                                                             NSDictionary *showDict =
                                                             [NSJSONSerialization JSONObjectWithData: [jsonArray dataUsingEncoding:NSUTF8StringEncoding]
                                                                                             options: NSJSONReadingMutableContainers
                                                                                               error: &error2];
                                                             
                                                             self.appDelegate.liteShow = [[NSDictionary alloc] initWithDictionary:showDict copyItems:YES];
                                                             
                                                             NSLog(@"new liteshow = %@", self.appDelegate.liteShow);
                                                             
                                                             [self enableJoin];   
                                                         }
                                                         onFailure:^(NSError *error) {
                                                             self.appDelegate.liteShow = nil;
                                                         }];
                                     
                                 }
                             }
                             onFailure:^(NSError *error) {
                                 // no shows available
                                 [self disableJoin];
                                 
                                 self.appDelegate.liteShow = nil;
                             }];
    }
}

-(IBAction)changeSeat:(id)sender {
    pressedChangeSeat = YES;
    [self withdraw];
}

-(IBAction)withdrawUser:(id)sender {
    [self withdraw];
}

-(void)joinShow {
    
    NSDateFormatter *dateformat = [[NSDateFormatter alloc] init];
    [dateformat setDateFormat:@"yyyy-MM-dd'T'HH:mm:ss.SSS'Z'"];
    [dateformat setTimeZone:[NSTimeZone timeZoneWithName:@"GMT"]];
    
    NSString *mobile_start = [dateformat stringFromDate:[NSDate date]];

    NSDictionary *params = [NSDictionary dictionaryWithObjectsAndKeys:
                            mobile_start, @"mobile_time", nil];

    
    [[LWAPIClient instance] joinShow: self.appDelegate.userID
                            params: params
                         onSuccess:^(id data) {
                             NSLog(@"EVENT JOIN RESPONSE: %@", data);
                             
                             NSError *error2;
                             NSData *jsonData = [NSJSONSerialization dataWithJSONObject:data options:kNilOptions error:&error2];
                             NSString *jsonArray = [[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding];
                             
                             NSDictionary *joinDict =
                             [NSJSONSerialization JSONObjectWithData: [jsonArray dataUsingEncoding:NSUTF8StringEncoding]
                                                             options: NSJSONReadingMutableContainers
                                                               error: &error2];
                             
                             self.appDelegate.eventJoinData = [[NSDictionary alloc] initWithDictionary:joinDict copyItems:YES];
                             
                             NSString * storyboardName = @"Main";
                             UIStoryboard *storyboard = [UIStoryboard storyboardWithName:storyboardName bundle: nil];
                             UIViewController * vc = [storyboard instantiateViewControllerWithIdentifier:@"playing"];
                             [self presentViewController:vc animated:YES completion:nil];
                         }
                         onFailure:^(NSError *error) {
                             UIAlertView *alert = [[UIAlertView alloc] initWithTitle: @"Join failed"
                                                                             message: @"Sorry, this show has expired."
                                                                            delegate:self
                                                                   cancelButtonTitle:@"OK"
                                                                   otherButtonTitles:nil];
                             [alert show];
                         }];
    
}

- (void)withdraw
{
    // leave the event
    [[LWAPIClient instance] leaveEvent: self.appDelegate.userID
                             onSuccess:^(id data) {
                               if (!pressedChangeSeat)
                                   [self.navigationController popViewControllerAnimated:YES];
                               
                               NSLog(@"Left event");
                           }
                           onFailure:^(NSError *error) {
                               UIAlertView *alert = [[UIAlertView alloc] initWithTitle: @"Leave error"
                                                                               message: @"Sorry, an error occurred when leaving the event."
                                                                              delegate:self
                                                                     cancelButtonTitle:@"OK"
                                                                     otherButtonTitles:nil];
                               [alert show];
                           }];
    
    // clear data
    self.appDelegate.levelID = nil;
    self.appDelegate.sectionID = nil;
    self.appDelegate.rowID = nil;
    self.appDelegate.seatID = nil;
    self.appDelegate.userID = nil;
    self.appDelegate.liteShow = nil;
    
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    
    [defaults removeObjectForKey:@"levelID"];
    [defaults removeObjectForKey:@"sectionID"];
    [defaults removeObjectForKey:@"rowID"];
    [defaults removeObjectForKey:@"seatID"];
    [defaults removeObjectForKey:@"userID"];
    [defaults removeObjectForKey:@"liteShow"];
    
    [defaults synchronize];
}

- (void)prepareView
{
    CGRect statusBarViewRect = [[UIApplication sharedApplication] statusBarFrame];
    float heightPadding = statusBarViewRect.size.height+self.navigationController.navigationBar.frame.size.height;
    
    joinButton.frame = CGRectMake(0,
                                  self.view.bounds.size.height - heightPadding - 50,
                                  self.view.bounds.size.width,
                                  50);
    [self disableJoin];
}

- (void)disableJoin
{
    joinButton.layer.borderColor=[UIColor colorWithRed:46.0/255.0 green:46.0/255.0 blue:46.0/255.0 alpha:1.0].CGColor;
    joinButton.layer.backgroundColor=[UIColor colorWithRed:46.0/255.0 green:46.0/255.0 blue:46.0/255.0 alpha:1.0].CGColor;
    joinButton.layer.borderWidth=2.0f;
    
    [joinButton setTitleColor:[UIColor colorWithRed:100.0/255.0 green:100.0/255.0 blue:100.0/255.0 alpha:1.0] forState:UIControlStateNormal];
    
    [joinButton removeTarget:self action:@selector(onJoinSelect) forControlEvents:UIControlEventTouchUpInside];
}

- (void)enableJoin
{
    joinButton.layer.borderColor=[UIColor colorWithRed:222.0/255.0 green:32.0/255 blue:50.0/255 alpha:1.0].CGColor;
    joinButton.layer.backgroundColor=[UIColor colorWithRed:222.0/255.0 green:32.0/255 blue:50.0/255 alpha:1.0].CGColor;
    joinButton.layer.borderWidth=2.0f;
    
    [joinButton setTitleColor:[UIColor colorWithRed:255.0/255.0 green:255.0/255.0 blue:255.0/255.0 alpha:1.0] forState:UIControlStateNormal];
    
    [joinButton addTarget:self action:@selector(onJoinSelect) forControlEvents:UIControlEventTouchUpInside];
}

-(void)onJoinSelect
{
    [self joinShow];
}

- (void)onBecomeActive
{
    [self fetchShow];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
