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
#import "LWUtility.h"
#import "AFNetworking.h"
#import "LWApiClient.h"

@interface LWReadyController ()

-(IBAction)changeSeat:(id)sender;

@end

@implementation LWReadyController

- (void)viewDidLoad
{
    [super viewDidLoad];
	
    [self.navigationItem setHidesBackButton:YES animated:NO];
    
    self.appDelegate = (LWAppDelegate *)[[UIApplication sharedApplication] delegate];
    
    self.view.backgroundColor = self.appDelegate.backgroundColor;
    
    pressedChangeSeat = NO;
    
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
    
    // add observer for when app becomes active
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(onBecomeActive) name:UIApplicationDidBecomeActiveNotification object:[UIApplication sharedApplication]];
    
    [self.navigationItem setHidesBackButton:NO animated:NO];

    self.title = self.appDelegate.eventName;

    [self getShow];
}

-(void)getShow {
    
    [[LWAPIClient instance] getShows: self.appDelegate.eventID
                         onSuccess: ^(id data) {
                             NSError *error2;
                             NSData *jsonData = [NSJSONSerialization dataWithJSONObject:data options:kNilOptions error:&error2];
                             NSString *jsonArray = [[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding];
                             
                             NSDictionary *currentShow;
                             NSDateFormatter *dateformat = [[NSDateFormatter alloc] init];
                             [dateformat setDateFormat:@"yyyy-MM-dd'T'HH:mm:ss.SSS'Z'"];
                             [dateformat setTimeZone:[NSTimeZone timeZoneWithName:@"GMT"]];
                             
                             NSArray *showDict = [NSJSONSerialization JSONObjectWithData: [jsonArray dataUsingEncoding:NSUTF8StringEncoding]
                                                                                 options: NSJSONReadingMutableContainers
                                                                                   error: &error2];
                             
                             NSArray *showsArray = [[NSArray alloc] initWithArray:showDict copyItems:YES];
                             for (NSDictionary *show in showsArray) {
                                 if ([show valueForKey:@"startAt"] != (id)[NSNull null]) {
                                     NSDate *showDate = [dateformat dateFromString:[show valueForKey:@"startAt"]];
                                     if (showDate && [LWUtility isTodayGreaterThanDate:showDate]) {
                                         currentShow = show;
                                         break;
                                     }
                                 }
                             }

                             if (currentShow) {
                                 NSLog(@"new liteshow = %@", self.appDelegate.show);
                                 
                                 self.appDelegate.show = [[NSDictionary alloc] initWithDictionary:currentShow copyItems:YES];
                                 [self enableJoin];
                             } else {
                                 // no shows available
                                 self.appDelegate.show = nil;

                                 [self disableJoin];
                             }
                         }
                         onFailure:^(NSError *error) {
                             // no shows available
                             [self disableJoin];
                             
                             self.appDelegate.show = nil;
                         }];
}

-(IBAction)changeSeat:(id)sender {
    [self withdraw];
    
    pressedChangeSeat = YES;
    [self.navigationController popViewControllerAnimated:YES];
}

-(void)joinShow {
    NSDateFormatter *dateformat = [[NSDateFormatter alloc] init];
    [dateformat setDateFormat:@"yyyy-MM-dd'T'HH:mm:ss.SSS'Z'"];
    [dateformat setTimeZone:[NSTimeZone timeZoneWithName:@"GMT"]];
    
    NSString *mobileStart = [dateformat stringFromDate:[NSDate date]];

    NSDictionary *params = [NSDictionary dictionaryWithObjectsAndKeys:
                            mobileStart, @"mobileTime", nil];

    NSLog(@"EVENT JOIN REQUEST: %@", params);
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
                             
                             self.appDelegate.showData = [[NSDictionary alloc] initWithDictionary:joinDict copyItems:YES];
                             
                             NSString * storyboardName = @"Main";
                             UIStoryboard *storyboard = [UIStoryboard storyboardWithName:storyboardName bundle: nil];
                             UIViewController * vc = [storyboard instantiateViewControllerWithIdentifier:@"playing"];
                             [self presentViewController:vc animated:YES completion:nil];
                         }
                         onFailure:^(NSError *error) {
                             [self disableJoin];
                             
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
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    
    // leave the event
    [[LWAPIClient instance] leaveEvent: self.appDelegate.userID
                             onSuccess:^(id data) {
                                 // clear data on success
                                 self.appDelegate.userID = nil;
                                 self.appDelegate.show = nil;
                                 
                                 [defaults removeObjectForKey:@"userID"];
                                 [defaults removeObjectForKey:@"liteShow"];
                                 
                                 [defaults synchronize];

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
    
    // clear this data on pass or fail
    self.appDelegate.levelID = nil;
    self.appDelegate.sectionID = nil;
    self.appDelegate.rowID = nil;
    self.appDelegate.seatID = nil;
    
    [defaults removeObjectForKey:@"levelID"];
    [defaults removeObjectForKey:@"sectionID"];
    [defaults removeObjectForKey:@"rowID"];
    [defaults removeObjectForKey:@"seatID"];
    

    [defaults synchronize];
}

- (void)prepareView
{
    CGRect statusBarViewRect = [[UIApplication sharedApplication] statusBarFrame];
    float heightPadding = statusBarViewRect.size.height+self.navigationController.navigationBar.frame.size.height;
    
    [self loadImage];
    
    waitLabel.textColor = self.appDelegate.textColor;
    waitLabel.frame = CGRectMake(waitLabel.frame.origin.x,
                                 0,
                                 waitLabel.frame.size.width,
                                 waitLabel.frame.size.height);
    
    spinner.frame = CGRectMake(spinner.frame.origin.x,
                               waitLabel.frame.origin.y + 75,
                               spinner.frame.size.width,
                               spinner.frame.size.height);
    spinner.color = self.appDelegate.highlightColor;
    
    
    changeButton.layer.borderColor=self.appDelegate.highlightColor.CGColor;
    changeButton.layer.backgroundColor=self.appDelegate.highlightColor.CGColor;
    changeButton.layer.borderWidth=2.0f;
    [changeButton addTarget: self
                     action: @selector(changeSeat:)
           forControlEvents: UIControlEventTouchUpInside];
    
    
    int buttonWidth = 70;
    int buttonPadding = (self.view.frame.size.width - (4*buttonWidth))/5;
    int buttonXPosition = buttonPadding;
    int buttonYPostion = self.view.frame.size.height - 225;
    UILabel *infoLabel;
    
    // level
    infoLabel = [[UILabel alloc]initWithFrame:CGRectMake(buttonXPosition-5,
                                                         buttonYPostion - 50,
                                                         buttonWidth+10,
                                                         50)];
    [infoLabel setTextColor:self.appDelegate.textColor];
    [infoLabel setFont:[UIFont fontWithName:@"HelveticaNeue" size:20.0f]];
    [infoLabel setTranslatesAutoresizingMaskIntoConstraints:NO];
    infoLabel.textAlignment = NSTextAlignmentCenter;
    infoLabel.text = @"Level";
    [self.view addSubview:infoLabel];
    
    [self buildSeatButton:self.appDelegate.levelID x:buttonXPosition y:buttonYPostion size:buttonWidth];
    buttonXPosition += buttonPadding + buttonWidth;
    
    // section
    infoLabel = [[UILabel alloc]initWithFrame:CGRectMake(buttonXPosition-5,
                                                         buttonYPostion - 50,
                                                         buttonWidth+10,
                                                         50)];
    [infoLabel setTextColor:self.appDelegate.textColor];
    [infoLabel setFont:[UIFont fontWithName:@"HelveticaNeue" size:20.0f]];
    [infoLabel setTranslatesAutoresizingMaskIntoConstraints:NO];
    infoLabel.textAlignment = NSTextAlignmentCenter;
    infoLabel.text = @"Section";
    [self.view addSubview:infoLabel];
    
    [self buildSeatButton:self.appDelegate.sectionID x:buttonXPosition y:buttonYPostion size:buttonWidth];
    buttonXPosition += buttonPadding + buttonWidth;
    
    // row
    infoLabel = [[UILabel alloc]initWithFrame:CGRectMake(buttonXPosition-5,
                                                         buttonYPostion - 50,
                                                         buttonWidth+10,
                                                         50)];
    [infoLabel setTextColor:self.appDelegate.textColor];
    [infoLabel setFont:[UIFont fontWithName:@"HelveticaNeue" size:20.0f]];
    [infoLabel setTranslatesAutoresizingMaskIntoConstraints:NO];
    infoLabel.textAlignment = NSTextAlignmentCenter;
    infoLabel.text = @"Row";
    [self.view addSubview:infoLabel];

    
    [self buildSeatButton:self.appDelegate.rowID x:buttonXPosition y:buttonYPostion size:buttonWidth];
    buttonXPosition += buttonPadding + buttonWidth;

    // seat
    infoLabel = [[UILabel alloc]initWithFrame:CGRectMake(buttonXPosition-5,
                                                         buttonYPostion - 50,
                                                         buttonWidth+10,
                                                         50)];
    [infoLabel setTextColor:self.appDelegate.textColor];
    [infoLabel setFont:[UIFont fontWithName:@"HelveticaNeue" size:20.0f]];
    [infoLabel setTranslatesAutoresizingMaskIntoConstraints:NO];
    infoLabel.textAlignment = NSTextAlignmentCenter;
    infoLabel.text = @"Seat";
    [self.view addSubview:infoLabel];

    
    [self buildSeatButton:self.appDelegate.seatID x:buttonXPosition y:buttonYPostion size:buttonWidth];
    
    
    joinButton.frame = CGRectMake(0,
                                  self.view.bounds.size.height - heightPadding - 50,
                                  self.view.bounds.size.width,
                                  50);
    [self disableJoin];
}

- (void)loadImage
{
    CGRect statusBarViewRect = [[UIApplication sharedApplication] statusBarFrame];
    float heightPadding = statusBarViewRect.size.height+self.navigationController.navigationBar.frame.size.height;
    
    //NSURL *url = [NSURL URLWithString:self.appDelegate.logoUrl];
    NSURL *url = [NSURL URLWithString:@"https://s-media-cache-ak0.pinimg.com/originals/a7/e0/5d/a7e05d588e5bdf5f4f7a4d3ea03486a2.gif"];
    
    NSData *imageData = [NSData dataWithContentsOfURL:url];
    UIImage *image = [[UIImage alloc] initWithData:imageData];
    
    float height = 700;
    float width = (image.size.width*height)/image.size.height;
    imageView.frame = CGRectMake(
                                 self.view.frame.size.width/2 - width/2,
                                 self.view.frame.size.height/2 - height/2 -heightPadding,
                                 width,
                                 height);
    imageView.image = image;
    imageView.alpha = .04;
    imageView.hidden = NO;
}

-(void)buildSeatButton:(NSString*)label x:(int)x y:(int)y size:(int)size
{
    UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
    button.frame = CGRectMake(x,
                              y,
                              size,
                              size);
    button.clipsToBounds = YES;
    button.layer.cornerRadius = size/2.0f;
    button.layer.borderColor=self.appDelegate.highlightColor.CGColor;
    button.layer.backgroundColor=self.appDelegate.highlightColor.CGColor;
    button.layer.borderWidth = 2.0f;
    [self.view addSubview:button];
    
    UILabel *buttonLabel = [[UILabel alloc]initWithFrame:CGRectMake(x, y, size, size)];
    buttonLabel.text = label;
    buttonLabel.textAlignment = NSTextAlignmentCenter;
    [buttonLabel setTextColor:self.appDelegate.textSelectedColor];
    [buttonLabel setFont:[UIFont fontWithName:@"HelveticaNeue" size:20.0f]];
    [buttonLabel setTranslatesAutoresizingMaskIntoConstraints:NO];
    [self.view addSubview:buttonLabel];
}

- (void)disableJoin
{
    joinButton.layer.borderColor=[UIColor colorWithRed:46.0/255.0 green:46.0/255.0 blue:46.0/255.0 alpha:1.0].CGColor;
    joinButton.layer.backgroundColor=[UIColor colorWithRed:46.0/255.0 green:46.0/255.0 blue:46.0/255.0 alpha:1.0].CGColor;
    joinButton.layer.borderWidth=2.0f;
    
    [joinButton setTitleColor:[UIColor colorWithRed:100.0/255.0 green:100.0/255.0 blue:100.0/255.0 alpha:1.0] forState:UIControlStateNormal];
    
    [joinButton removeTarget:self action:@selector(onJoinSelect) forControlEvents:UIControlEventTouchUpInside];
    
    waitLabel.text = @"Waiting for the event to begin";
    spinner.hidden = NO;
}

- (void)enableJoin
{
    joinButton.layer.borderColor=self.appDelegate.highlightColor.CGColor;
    joinButton.layer.backgroundColor=self.appDelegate.highlightColor.CGColor;
    joinButton.layer.borderWidth=2.0f;
    
    [joinButton setTitleColor:[UIColor colorWithRed:255.0/255.0 green:255.0/255.0 blue:255.0/255.0 alpha:1.0] forState:UIControlStateNormal];
    
    [joinButton addTarget:self action:@selector(onJoinSelect) forControlEvents:UIControlEventTouchUpInside];
    
    
    waitLabel.text = @"Join the event to begin";
    spinner.hidden = YES;
}

-(void)onJoinSelect
{
    [self joinShow];
}

- (void)onBecomeActive
{
    [self getShow];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
