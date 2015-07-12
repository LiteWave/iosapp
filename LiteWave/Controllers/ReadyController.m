//
//  ReadyViewController.m
//  LiteWave
//
//  Created by mike draghici on 10/24/13.
//  Copyright (c) 2013 LiteWave. All rights reserved.
//

#import "ReadyController.h"
#import "ShowController.h"
#import "AppDelegate.h"
#import "AFNetworking.h"
#import "APIClient.h"

@interface ReadyController ()

-(IBAction)withdrawUser:(id)sender;
-(IBAction)retryFetch:(id)sender;
-(IBAction)changeSeat:(id)sender;

@end

@implementation ReadyController

- (void)viewDidLoad
{
    [super viewDidLoad];
	
    [self.navigationItem setHidesBackButton:YES animated:NO];
    
    pressedChangeSeat = NO;
    
    [changeBtn addTarget: self
                  action: @selector(changeSeat:)
        forControlEvents: UIControlEventTouchUpInside];
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    
    if (pressedChangeSeat)
        return;
    
    if (self.isMovingFromParentViewController) {
        [self withdraw];
    }
}

- (void)viewDidAppear:(BOOL)animated{
    
    [self.navigationItem setHidesBackButton:NO animated:NO];

    AppDelegate *appDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];

    self.title = appDelegate.eventName;

    mySeat.text = [NSString stringWithFormat:@"%@-%@-%@",appDelegate.sectionID,appDelegate.rowID,appDelegate.seatID];
    
    [self fetchShow];
    self.timer = [NSTimer scheduledTimerWithTimeInterval: 2.0
                                                  target: self
                                                selector: @selector(retryFetch:)
                                                userInfo: nil
                                                 repeats: YES];
}

-(void)fetchShow {
    
    AppDelegate *appDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    
    if (appDelegate.liteShow){
        NSLog(@"saved liteshow = %@", appDelegate.liteShow);
    } else {
        
        if (appDelegate.isOnline){
            
            [[APIClient instance] getShows:appDelegate.eventID
                                 onSuccess:^(id data) {
                                     NSError *error2;
                                     NSData *jsonData = [NSJSONSerialization dataWithJSONObject:data options:kNilOptions error:&error2];
                                     NSString *jsonArray = [[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding];
                                     
                                     NSArray *showDict =
                                     [NSJSONSerialization JSONObjectWithData: [jsonArray dataUsingEncoding:NSUTF8StringEncoding]
                                                                     options: NSJSONReadingMutableContainers
                                                                       error: &error2];
                                     
                                     appDelegate.liteshowArray = [[NSArray alloc] initWithArray:showDict copyItems:YES];
                                     
                                     NSDictionary *liteShowDict = [appDelegate.liteshowArray objectAtIndex:0];
                                     
                                     NSString *liteShowID = [liteShowDict valueForKey:@"_id"];
                                     
                                     [[APIClient instance] getShow: liteShowID
                                                              user: appDelegate.userID
                                                         onSuccess:^(id data) {
                                                             NSError *error2;
                                                             NSData *jsonData = [NSJSONSerialization dataWithJSONObject:data options:kNilOptions error:&error2];
                                                             NSString *jsonArray = [[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding];
                                                             
                                                             NSDictionary *showDict =
                                                             [NSJSONSerialization JSONObjectWithData: [jsonArray dataUsingEncoding:NSUTF8StringEncoding]
                                                                                             options: NSJSONReadingMutableContainers
                                                                                               error: &error2];
                                                             
                                                             appDelegate.liteShow = [[NSDictionary alloc] initWithDictionary:showDict copyItems:YES];
                                                             
                                                             NSLog(@"new liteshow = %@", appDelegate.liteShow);
                                                             
                                                         }
                                                         onFailure:^(NSError *error) {
                                                             appDelegate.liteShow = nil;
                                                             
                                                             UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"No Show Available" message:@"There is no show available at this time for this event." delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil];
                                                             [alert show];
                                                         }];
                                 }
                                 onFailure:^(NSError *error) {
                                     appDelegate.liteShow = nil;
                                     
                                     UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"No Shows Available" message:@"There is no shows available at this time for this event." delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil];
                                     [alert show];
                                 }];
            
            
        }else{
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle: NSLocalizedString(@"Network error", @"Network error")
                                                            message: NSLocalizedString(@"No internet connection found, this application requires an internet connection.", @"Network error") delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil];
            [alert show];
        }
        
    }
    
}

-(IBAction)changeSeat:(id)sender {
    pressedChangeSeat = YES;
    [self withdraw];
    [self.navigationController popViewControllerAnimated:YES];
}

-(IBAction)withdrawUser:(id)sender{
    [self withdraw];
}

-(IBAction)retryFetch:(id)sender{
    
    [self joinLiteShow];
}

-(void) joinLiteShow{
    
    AppDelegate *appDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    
    NSDateFormatter *dateformat = [[NSDateFormatter alloc] init];
    [dateformat setDateFormat:@"yyyy-MM-dd'T'HH:mm:ss.SSS'Z'"];
    [dateformat setTimeZone:[NSTimeZone timeZoneWithName:@"GMT"]];
    
    NSString *mobile_start = [dateformat stringFromDate:[NSDate date]];

    NSDictionary *params = [NSDictionary dictionaryWithObjectsAndKeys:
                            mobile_start, @"mobile_time", nil];

    
    [[APIClient instance] joinShow: appDelegate.userID
                            params: params
                         onSuccess:^(id data) {
                             NSLog(@"EVENT JOIN RESPONSE: %@", data);
                             
                             [self.timer invalidate];
                             self.timer = nil;
                             
                             NSError *error2;
                             NSData *jsonData = [NSJSONSerialization dataWithJSONObject:data options:kNilOptions error:&error2];
                             NSString *jsonArray = [[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding];
                             
                             NSDictionary *joinDict =
                             [NSJSONSerialization JSONObjectWithData: [jsonArray dataUsingEncoding:NSUTF8StringEncoding]
                                                             options: NSJSONReadingMutableContainers
                                                               error: &error2];
                             
                             appDelegate.eventJoinData = [[NSDictionary alloc] initWithDictionary:joinDict copyItems:YES];
                             
                             NSString * storyboardName = @"Main";
                             UIStoryboard *storyboard = [UIStoryboard storyboardWithName:storyboardName bundle: nil];
                             UIViewController * vc = [storyboard instantiateViewControllerWithIdentifier:@"playing"];
                             [self presentViewController:vc animated:YES completion:nil];
                         }
                         onFailure:^(NSError *error) {
                             if (error) {
                                 NSLog(@"polling: no event found");
                             }
                         }];
    
}

- (void)withdraw
{
    if (self.timer) {
        [self.timer invalidate];
        self.timer = nil;
    }
    
    AppDelegate *appDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    
    // leave the event
    [[APIClient instance] leaveEvent: appDelegate.userID
                           onSuccess:^(id data) {
                               NSLog(@"Left event");
                           }
                           onFailure:^(NSError *error) {
                               NSLog(@"Error on leaving event");
                           }];
    
    // clear data
    appDelegate.sectionID = nil;
    appDelegate.rowID = nil;
    appDelegate.seatID = nil;
    appDelegate.userID = nil;
    appDelegate.liteShow = nil;
    
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    
    [defaults removeObjectForKey:@"sectionID"];
    [defaults removeObjectForKey:@"rowID"];
    [defaults removeObjectForKey:@"seatID"];
    [defaults removeObjectForKey:@"userID"];
    [defaults removeObjectForKey:@"liteShow"];
    
    [defaults synchronize];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
