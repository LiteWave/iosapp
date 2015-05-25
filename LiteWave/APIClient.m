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

@implementation APIClient

+(APIClient *)sharedProxy {
    static APIClient *_sharedProxy = nil;
    static dispatch_once_t oncePredicate;
    dispatch_once(&oncePredicate, ^{
        _sharedProxy = [[self alloc] initWithBaseURL:[NSURL URLWithString:@"http://127.0.0.1:3000"]];
    });
    return _sharedProxy;
}

-(id)initWithBaseURL:(NSURL *)url {
    self = [super initWithBaseURL:url];
    if (!self) {
        return nil;
    }
    [self registerHTTPOperationClass:[AFJSONRequestOperation class]];
    [self setDefaultHeader:@"Accept" value:@"application/json"];
    self.parameterEncoding = AFJSONParameterEncoding;
    
    return self;
    
}

@end
