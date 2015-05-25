//
//  APIClient.m
//  LiteWave
//
//  Created by mike draghici on 11/14/13.
//  Copyright (c) 2013 LightWave. All rights reserved.
//

#define API_URL = @"http://127.0.0.1:3000/api"
#define API_getClients = @"/clients"
#define API_getClientEvents = @"/{clientid}/lw_events"
#define API_postEventUserLocation = @"/lw_events/{eventid}/user_locations"
#define API_postEventJoin = @"/user_locations/{userid}/event_joins"
#define API_getEventShows = @"/lw_events/{eventid}/event_liteshows"
#define API_getUserEventShow = @"/event_liteshows/{showid}/user_locations/{userid}/liteshow"

#import "APIClient.h"
#import "AFNetworking.h"
#import "Configuration.h"

@implementation APIClient

+(APIClient *)instance {
    static APIClient *theInstance = nil;
    static dispatch_once_t oncePredicate;
    dispatch_once(&oncePredicate, ^{
        theInstance = [[self alloc] init];
    });
    return theInstance;
}

-(id)init {
    self = [super init];
    if (self) {
        _apiURL = [[Configuration instance] get: @"apiURL"];
    }
    
    return self;
}

-(void)makeRequest:(NSURLRequest*)request onSuccess:(Success)success onFailure:(Failure)failure {
    
    NSLog(@"requesting: %@", request.URL);
    AFJSONRequestOperation *operation =
    [AFJSONRequestOperation JSONRequestOperationWithRequest:request
                                                    success:^(NSURLRequest *request, NSHTTPURLResponse *response, id JSON) {
                                                        success(JSON);
                                                    }
                                                    failure:^(NSURLRequest *request, NSHTTPURLResponse *response, NSError *error) {
                                                        NSLog(@"failure: %@", response);
                                                        failure(error);
                                                    }];
    [operation start];
}

// API METHODS

-(void)getEvents:(NSString*)clientID onSuccess:(Success)success onFailure:(Failure)failure {
    NSURL *url = [[NSURL alloc] initWithString:[self eventsPath:clientID]];
    
    NSURLRequest *request = [NSURLRequest requestWithURL:url];
    [self makeRequest: request onSuccess: success onFailure: failure];
}

// API HELPERS

-(NSString*)eventsPath:(NSString*)clientID {
    return [self eventsPath: clientID withEvent: @""];
}
-(NSString*)eventsPath:(NSString*)clientID withEvent:(NSString*)eventID {
    return [NSString stringWithFormat: @"%@/clients/%@/lw_events/%@", self.apiURL, clientID, eventID];
}






@end
