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
-(void)get:(NSURL*)url onSuccess:(Success)success onFailure:(Failure)failure;
-(void)post:(NSURL*)url params:(NSDictionary*)params onSuccess:(Success)success onFailure:(Failure)failure;
-(void)delete:(NSURL*)url onSuccess:(Success)success onFailure:(Failure)failure;

// API METHODS

-(void)getStadiums:(Success)success onFailure:(Failure)failure;
-(void)getStadium:(NSString*)stadiumID onSuccess:(Success)success onFailure:(Failure)failure;

-(void)getEvents:(NSString*)clientID onSuccess:(Success)success onFailure:(Failure)failure;
-(void)joinEvent:(NSString*)eventID params:(NSDictionary*)params onSuccess:(Success)success onFailure:(Failure)failure;
-(void)leaveEvent:(NSString*)userID onSuccess:(Success)success onFailure:(Failure)failure;

-(void)getShows:(NSString*)eventID onSuccess:(Success)success onFailure:(Failure)failure;
-(void)getShow:(NSString*)showID user:(NSString*)userID onSuccess:(Success)success onFailure:(Failure)failure;
-(void)joinShow:(NSString*)userID params:(NSDictionary*)params onSuccess:(Success)success onFailure:(Failure)failure;

// API HELPERS

-(NSString*)eventsPath:(NSString*)clientID;
-(NSString*)eventsPath:(NSString*)clientID withEvent:(NSString*)eventID;

-(NSString*)showsPath:(NSString*)eventID;
-(NSString*)showsPath:(NSString*)eventID withUser:(NSString*)userID;


@end
