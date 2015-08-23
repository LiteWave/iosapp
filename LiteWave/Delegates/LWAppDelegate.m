//
//  LiteWaveAppDelegate.m
//  LiteWave
//
//  Created by mike draghici on 10/24/13.
//  Copyright (c) 2013 LiteWave. All rights reserved.
//

#import "LWAppDelegate.h"
#import "Reachability.h"

@implementation LWAppDelegate

@synthesize uniqueID = _uniqueID;
@synthesize clientID = _clientID;
@synthesize seatsArray = _seatsArray;
@synthesize eventID = _eventID;
@synthesize stadiumID = _stadiumID;
@synthesize sectionID = _sectionID;
@synthesize rowID = _rowID;
@synthesize seatID = _seatID;
@synthesize eventName = _eventName;
@synthesize eventDate = _eventDate;
@synthesize userID = _userID;
@synthesize show = _show;
@synthesize showData = _showData;
@synthesize isOnline = _isOnline;

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{

    [[NSNotificationCenter defaultCenter] addObserver: self selector: @selector(reachabilityChanged:) name: kReachabilityChangedNotification object: nil];
    
    [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleLightContent];

    #ifdef DEBUG
        self.apiURL = @"http://127.0.0.1:3000/api";
    #else
        self.apiURL = @"http://104.130.156.82:8080/api";
    #endif
    
    hostReach = [Reachability reachabilityWithHostName:self.apiURL];
    [hostReach startNotifier];
    [self updateInterfaceWithReachability: hostReach];
    
    internetReach = [Reachability reachabilityForInternetConnection];
    [internetReach startNotifier];
    [self updateInterfaceWithReachability: internetReach];
    
    wifiReach = [Reachability reachabilityForLocalWiFi];
    [wifiReach startNotifier];
    [self updateInterfaceWithReachability: wifiReach];
    
    //check and store uuid if doesn't exist
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    self.uniqueID = [defaults stringForKey:@"uuid"];
    self.clientID = @"5260316cbf80240000000001"; //trailblazers
    self.levelID = [defaults stringForKey:@"levelID"];
    self.sectionID = [defaults stringForKey:@"sectionID"];
    self.rowID = [defaults stringForKey:@"rowID"];
    self.seatID = [defaults stringForKey:@"seatID"];
    self.eventID = [defaults stringForKey:@"eventID"];
    self.eventName = [defaults stringForKey:@"eventName"];
    self.eventDate = [defaults objectForKey:@"eventDate"];
    self.stadiumID = [defaults stringForKey:@"stadiumID"];
    self.userID = [defaults objectForKey:@"userID"];
    self.show = [defaults objectForKey:@"show"];
    
    self.backgroundColor = [UIColor whiteColor];
    self.borderColor = [UIColor blackColor];
    self.highlightColor = [UIColor colorWithRed:222.0/255.0 green:32.0/255 blue:50.0/255 alpha:1.0];
    self.textColor = [UIColor colorWithRed:0.0/255.0 green:0.0/255 blue:0.0/255 alpha:1.0];
    self.textSelectedColor = [UIColor whiteColor];
    
    NSLog(@"stored uuid %@", self.uniqueID);
    if(self.uniqueID.length==0){
        self.uniqueID = [self uuid];
        [defaults setValue:self.uniqueID forKey:@"uuid"];
        [defaults synchronize];
        NSLog(@"stored new uuid %@", self.uniqueID);
    }
    
    return YES;
}

static NSString *uuid;
- (NSString *)uuid
{
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        CFUUIDRef theUUID = CFUUIDCreate(kCFAllocatorDefault);
        if (theUUID) {
            uuid = CFBridgingRelease(CFUUIDCreateString(kCFAllocatorDefault, theUUID));
            CFRelease(theUUID);
        }
    });
    
    return uuid;
}

- (void) updateInterfaceWithReachability: (Reachability*) curReach
{
    self.isOnline=YES;
    if(curReach == hostReach)
    {
        BOOL connectionRequired = [curReach connectionRequired];
        
        NSString* baseLabel=  @"";
        if(connectionRequired)
        {
            baseLabel=  @"Cellular data network is available.\n  Internet traffic will be routed through it after a connection is established.";
        }
        else
        {
            baseLabel=  @"Cellular data network is active.\n  Internet traffic will be routed through it.";
        }
        
    }
    if (curReach == internetReach)
    {
        
    }
    if (curReach == wifiReach)
    {
       
    }
}

//Called by Reachability whenever status changes.
- (void) reachabilityChanged: (NSNotification* )note
{
    Reachability* curReach = [note object];
    NSParameterAssert([curReach isKindOfClass: [Reachability class]]);
    [self updateInterfaceWithReachability: curReach];
    
    Reachability *reachability = [Reachability reachabilityForInternetConnection];
    NetworkStatus internetStatus = [reachability currentReachabilityStatus];
    
    if (internetStatus != NotReachable) {
        self.isOnline=NO;
    } else {
        self.isOnline=YES;
    }
}

							
- (void)applicationWillResignActive:(UIApplication *)application
{
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
}

- (void)applicationDidEnterBackground:(UIApplication *)application
{
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later. 
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
}

- (void)applicationWillEnterForeground:(UIApplication *)application
{
    // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
}

- (void)applicationDidBecomeActive:(UIApplication *)application
{
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
}

- (void)applicationWillTerminate:(UIApplication *)application
{
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
}

@end
