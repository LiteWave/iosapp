//
//  APIClient.h
//  LiteWave
//
//  Created by mike draghici on 11/14/13.
//  Copyright (c) 2013 LightWave. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef void (^Success)(id);
typedef void (^Failure)(NSError*);

@interface APIClient : NSObject

@property (nonatomic, retain) NSString *apiURL;

+(APIClient *)instance;

-(void)makeRequest:(NSURLRequest*)request onSuccess:(Success)success onFailure:(Failure)failure;

// API METHODS

-(void)getEvents:(NSString*)clientID onSuccess:(Success)success onFailure:(Failure)failure;

// API HELPERS

-(NSString*)eventsPath:(NSString*)clientID;
-(NSString*)eventsPath:(NSString*)clientID withEvent:(NSString*)eventID;

@end
