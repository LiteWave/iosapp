//
//  ReadyViewController.m
//  LiteWave
//
//  Copyright (c) 2013 LiteWave. All rights reserved.
//

#import "LWFReadyController.h"
#import "LWFShowController.h"
#import "LWFAppDelegate.h"
#import "LWFUtility.h"
#import "LWFAFNetworking.h"
#import "LWFApiClient.h"
#import "LWFConfiguration.h"

@interface LWFReadyController ()

-(IBAction)changeSeat:(id)sender;

@end

@implementation LWFReadyController

- (void)viewDidLoad
{
    [super viewDidLoad];
	
    [self.navigationItem setHidesBackButton:YES animated:NO];
    
    self.appDelegate = (LWFAppDelegate *)[[UIApplication sharedApplication] delegate];
    
    self.view.backgroundColor = [LWFConfiguration instance].backgroundColor;
    
    pressedChangeSeat = NO;
    
    // enable fade of screen
    [[UIApplication sharedApplication] setIdleTimerDisabled:NO];
    
    [self prepareView];
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

    self.title = [LWFConfiguration instance].eventName;

    [self getShow];
    [self beginTimer];
}

-(void)getShow {
    
    [[LWFAPIClient instance] getShows: [LWFConfiguration instance].eventID
                         onSuccess: ^(id data) {
                             NSError *error2;
                             NSData *jsonData = [NSJSONSerialization dataWithJSONObject:data options:kNilOptions error:&error2];
                             NSString *jsonArray = [[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding];
                             
                             NSDictionary *currentShow;
                             NSDateFormatter *dateformat = [[NSDateFormatter alloc] init];
                             [dateformat setDateFormat:@"yyyy-MM-dd'T'HH:mm:ss.SSS'Z'"];
                             [dateformat setTimeZone:[NSTimeZone timeZoneWithName:@"GMT"]];
                             
                             int offset = [[LWFConfiguration instance].mobileOffset intValue];
                             
                             NSArray *showDict = [NSJSONSerialization JSONObjectWithData: [jsonArray dataUsingEncoding:NSUTF8StringEncoding]
                                                                                 options: NSJSONReadingMutableContainers
                                                                                   error: &error2];
                             
                             NSArray *showsArray = [[NSArray alloc] initWithArray:showDict copyItems:YES];
                             for (NSDictionary *show in showsArray) {
                                 if ([show valueForKey:@"startAt"] != (id)[NSNull null]) {
                                     NSDate *showDate = [dateformat dateFromString:[show valueForKey:@"startAt"]];
                                     if (showDate && [LWFUtility isTodayLessThanDate:showDate todayOffsetInMilliseconds:offset]) {
                                         currentShow = show;
                                         break;
                                     }
                                 }
                             }

                             if (currentShow) {
                                 NSLog(@"new liteshow = %@", [LWFConfiguration instance].show);
                                 
                                 [LWFConfiguration instance].show = [[NSDictionary alloc] initWithDictionary:currentShow copyItems:YES];
                                 [self stopTimer];
                                 [self enableJoin];
                             } else {
                                 // no shows available
                                 [LWFConfiguration instance].show = nil;

                                 [self disableJoin];
                             }
                         }
                         onFailure:^(NSError *error) {
                             // no shows available
                             [self disableJoin];
                             
                             [LWFConfiguration instance].show = nil;
                         }];
}

-(void)joinShow {
    NSString *mobileTime = [LWFUtility getTodayInGMT];
    NSDictionary *params = [NSDictionary dictionaryWithObjectsAndKeys:
                            mobileTime, @"mobileTime", nil];

    NSLog(@"EVENT JOIN REQUEST: %@", params);
    [[LWFAPIClient instance] joinShow: [LWFConfiguration instance].userLocationID
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
                             
                             [LWFConfiguration instance].mobileOffset = [joinDict objectForKey:@"mobileTimeOffset"];
                             [LWFConfiguration instance].showData = [[NSDictionary alloc] initWithDictionary:joinDict copyItems:YES];
                             
                             UIStoryboard* storyboard = [UIStoryboard storyboardWithName:@"LWFMain"
                                                                                  bundle:[NSBundle bundleForClass:LWFReadyController.class]];
                             UIViewController * vc = [storyboard instantiateViewControllerWithIdentifier:@"playing"];
                             [self presentViewController:vc animated:YES completion:nil];
                         }
                         onFailure:^(NSError *error) {
                             UIAlertController *alert =  [UIAlertController
                                                           alertControllerWithTitle:@"Show"
                                                           message:@"Sorry, this show has expired."
                                                           preferredStyle:UIAlertControllerStyleAlert];
                             UIAlertAction *okAction = [UIAlertAction
                                                        actionWithTitle:@"OK"
                                                        style:UIAlertActionStyleDefault
                                                        handler:^(UIAlertAction *action)
                                                        {}];
                             [alert addAction:okAction];
                             
                             [self presentViewController:alert animated:YES completion:nil];
                             
                             [self disableJoin];
                             [self beginTimer];
                         }];
    
}

- (void)withdraw
{
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    
    // leave the event
    [[LWFAPIClient instance] leaveEvent: [LWFConfiguration instance].userLocationID
                             onSuccess:^(id data) {
                                 // clear data on success
                                 [LWFConfiguration instance].userLocationID = nil;
                                 [LWFConfiguration instance].show = nil;
                                 
                                 [defaults removeObjectForKey:@"userLocationID"];
                                 [defaults removeObjectForKey:@"liteShow"];
                                 
                                 [defaults synchronize];

                                 NSLog(@"Left event");
                           }
                           onFailure:^(NSError *error) {
                               UIAlertController *alert = [UIAlertController
                                                             alertControllerWithTitle:@"Leave error"
                                                             message:@"Sorry, an error occurred when leaving the event."
                                                             preferredStyle:UIAlertControllerStyleAlert];
                               UIAlertAction *okAction = [UIAlertAction
                                                          actionWithTitle:@"OK"
                                                          style:UIAlertActionStyleDefault
                                                          handler:^(UIAlertAction *action)
                                                          {}];
                               [alert addAction:okAction];
                               
                               
                               [self presentViewController:alert animated:YES completion:nil];
                           }];
    
    // clear this data on pass or fail
    [LWFConfiguration instance].sectionID = nil;
    [LWFConfiguration instance].rowID = nil;
    [LWFConfiguration instance].seatID = nil;
    
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
    
    [waitLabel setFont:[UIFont fontWithName:@"HelveticaNeue" size:self.view.frame.size.width*.065]];
    waitLabel.textColor = [LWFConfiguration instance].textColor;
    waitLabel.frame = CGRectMake(0,
                                 self.view.frame.size.height*.03,
                                 self.view.frame.size.width,
                                 waitLabel.frame.size.height);
    
    spinner.frame = CGRectMake(self.view.frame.size.width/2 - spinner.frame.size.width/2,
                               waitLabel.frame.origin.y + 75,
                               spinner.frame.size.width,
                               spinner.frame.size.height);
    spinner.color = [LWFConfiguration instance].highlightColor;
    
    
    int buttonWidth = self.view.frame.size.width*.2;
    int buttonPadding = (self.view.frame.size.width - (4*buttonWidth))/5;
    int buttonXPosition = buttonPadding;
    int buttonYPostion = self.view.frame.size.height - 220;
    
    // level
    [self buildInfoLabel:@"level" x:(buttonXPosition-5) y:(buttonYPostion-50) size:(buttonWidth+10)];
    [self buildSeatButton:[LWFConfiguration instance].levelID x:buttonXPosition y:buttonYPostion size:buttonWidth];
    buttonXPosition += buttonPadding + buttonWidth;
    
    // section
    [self buildInfoLabel:@"section" x:(buttonXPosition-5) y:(buttonYPostion-50) size:(buttonWidth+10)];
    [self buildSeatButton:[LWFConfiguration instance].sectionID x:buttonXPosition y:buttonYPostion size:buttonWidth];
    buttonXPosition += buttonPadding + buttonWidth;
    
    // row
    [self buildInfoLabel:@"row" x:(buttonXPosition-5) y:(buttonYPostion-50) size:(buttonWidth+10)];
    [self buildSeatButton:[LWFConfiguration instance].rowID x:buttonXPosition y:buttonYPostion size:buttonWidth];
    buttonXPosition += buttonPadding + buttonWidth;

    // seat
    [self buildInfoLabel:@"seat" x:(buttonXPosition-5) y:(buttonYPostion-50) size:(buttonWidth+10)];
    [self buildSeatButton:[LWFConfiguration instance].seatID x:buttonXPosition y:buttonYPostion size:buttonWidth];
    
    
    joinButton.frame = CGRectMake(0,
                                  self.view.bounds.size.height - heightPadding - 50,
                                  self.view.bounds.size.width,
                                  50);
    [self disableJoin];
}

- (void)loadImage
{
    if (![LWFConfiguration instance].logoUrl || ![LWFConfiguration instance].logoImage)
        return;
    
    CGRect statusBarViewRect = [[UIApplication sharedApplication] statusBarFrame];
    float heightPadding = statusBarViewRect.size.height+self.navigationController.navigationBar.frame.size.height;
    
    float height = 700;
    float width = ([LWFConfiguration instance].logoImage.size.width*height)/[LWFConfiguration instance].logoImage.size.height;
    imageView.frame = CGRectMake(self.view.frame.size.width/2 - width/2, self.view.frame.size.height/2 - height/2 - heightPadding, width, height);
    imageView.image = [LWFConfiguration instance].logoImage;
    imageView.alpha = .05;
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
    button.layer.borderColor=[LWFConfiguration instance].highlightColor.CGColor;
    button.layer.backgroundColor=[LWFConfiguration instance].highlightColor.CGColor;
    button.layer.borderWidth = 2.0f;
    [self.view addSubview:button];
    
    UILabel *buttonLabel = [[UILabel alloc]initWithFrame:CGRectMake(x, y, size, size)];
    buttonLabel.text = label;
    buttonLabel.textAlignment = NSTextAlignmentCenter;
    [buttonLabel setTextColor:[LWFConfiguration instance].textSelectedColor];
    [buttonLabel setFont:[UIFont fontWithName:@"HelveticaNeue" size:20.0f]];
    [buttonLabel setTranslatesAutoresizingMaskIntoConstraints:NO];
    [self.view addSubview:buttonLabel];
}

-(void)buildInfoLabel:(NSString*)label x:(int)x y:(int)y size:(int)size
{
    UILabel *infoLabel = [[UILabel alloc]initWithFrame:CGRectMake(x,
                                                         y,
                                                         size,
                                                         50)];
    [infoLabel setTextColor:[LWFConfiguration instance].textColor];
    [infoLabel setFont:[UIFont fontWithName:@"HelveticaNeue" size:19.0f]];
    [infoLabel setTranslatesAutoresizingMaskIntoConstraints:NO];
    infoLabel.textAlignment = NSTextAlignmentCenter;
    infoLabel.text = label;
    [self.view addSubview:infoLabel];
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
    joinButton.layer.borderColor=[LWFConfiguration instance].highlightColor.CGColor;
    joinButton.layer.backgroundColor=[LWFConfiguration instance].highlightColor.CGColor;
    joinButton.layer.borderWidth=2.0f;
    
    [joinButton setTitleColor:[UIColor colorWithRed:255.0/255.0 green:255.0/255.0 blue:255.0/255.0 alpha:1.0] forState:UIControlStateNormal];
    
    [joinButton addTarget:self action:@selector(onJoinSelect) forControlEvents:UIControlEventTouchUpInside];
    
    
    waitLabel.text = @"Join the event to begin";
    spinner.hidden = YES;
}

- (void)beginTimer
{
    double interval = [[LWFConfiguration instance].pollInterval doubleValue];
    self.timer = [NSTimer scheduledTimerWithTimeInterval: interval/1000
                                                  target: self
                                                selector: @selector(retryFetch:)
                                                userInfo: nil
                                                 repeats: YES];
}

- (void)stopTimer
{
    if (self.timer) {
        [self.timer invalidate];
        self.timer = nil;
    }
}

-(IBAction)retryFetch:(id)sender{
    
    [self getShow];
}

-(void)onJoinSelect
{
    [self joinShow];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
