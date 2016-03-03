//
//  LightWave.m
//  LiteWave
//
//  Created by David Anderson on 5/25/15.
//  Copyright (c) 2015 LightWave. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "LWFConfiguration.h"
#import "LWFUtility.h"

@implementation LWFConfiguration

+ (LWFConfiguration*)instance {
    static LWFConfiguration *theInstance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        theInstance = [[self alloc] init];
    });
    return theInstance;
}

- (LWFConfiguration*)init {
    // Forward to the "designated" initialization method
    self = [super init];
    if (self) {
        _properties = [[NSMutableDictionary alloc] init];
        
        [self loadData];
    }
    return self;
}

-(void)loadData
{
    //self.apiURL = @"http://127.0.0.1:3000/api"; // DEV
    self.apiURL = @"http://www.litewaveinc.com/api"; // PROD
    
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    self.clientID = @"5260316cbf80240000000001"; // trailblazers
    self.levelID = [defaults stringForKey:@"levelID"];
    self.sectionID = [defaults stringForKey:@"sectionID"];
    self.rowID = [defaults stringForKey:@"rowID"];
    self.seatID = [defaults stringForKey:@"seatID"];
    self.eventID = [defaults stringForKey:@"eventID"];
    self.eventName = [defaults stringForKey:@"eventName"];
    self.eventDate = [defaults objectForKey:@"eventDate"];
    self.stadiumID = [defaults stringForKey:@"stadiumID"];
    self.userID = [defaults stringForKey:@"uuid"];
    self.userLocationID = [defaults objectForKey:@"userLocationID"];
    self.mobileOffset = [defaults objectForKey:@"mobileOffset"];
    self.show = [defaults objectForKey:@"show"];
    
    self.defaultColor = [UIColor colorWithRed:222.0/255.0 green:32.0/255 blue:50.0/255 alpha:1.0];
    self.backgroundColor = [LWFUtility getColorFromString:[defaults objectForKey:@"backgroundColor"]];
    self.borderColor = [LWFUtility getColorFromString:[defaults objectForKey:@"borderColor"]];
    self.highlightColor = [LWFUtility getColorFromString:[defaults objectForKey:@"highlightColor"]];
    self.textColor = [LWFUtility getColorFromString:[defaults objectForKey:@"textColor"]];
    self.textSelectedColor = [LWFUtility getColorFromString:[defaults objectForKey:@"textSelectedColor"]];
    self.logoUrl = [defaults stringForKey:@"logoUrl"];
    if (self.logoUrl) {
        NSURL *url = [NSURL URLWithString:self.logoUrl];
        NSData *imageData = [NSData dataWithContentsOfURL:url];
        self.logoImage = [[UIImage alloc] initWithData:imageData];
    }
    
    self.pollInterval = [defaults stringForKey:@"pollInterval"];
    if (self.pollInterval.length==0){
        self.pollInterval = @"5000";
    }
    
    //check and store uuid if doesn't exist
    NSLog(@"stored uuid %@", self.userID);
    if (self.userID.length==0){
        self.userID = [self uuid];
        [defaults setValue:self.userID forKey:@"uuid"];
        [defaults synchronize];
        NSLog(@"stored new uuid %@", self.userID);
    }
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


- (id)get:(NSString*)property {
    return self.properties[property];
}

- (void)set:(NSString*)property value:(id)value {
    self.properties[property] = value;
}

@end