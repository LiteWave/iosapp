//
//  APIClient.m
//  LiteWave
//
//  Created by mike draghici on 11/14/13.
//  Copyright (c) 2013 LightWave. All rights reserved.
//

#import "LWAPIClient.h"
#import "AFNetworking.h"

@implementation LWAPIClient

+(LWAPIClient *)instance {
    static LWAPIClient *theInstance = nil;
    static dispatch_once_t oncePredicate;
    dispatch_once(&oncePredicate, ^{
        theInstance = [[self alloc] init];
    });
    return theInstance;
}

-(id)init {
    self = [super init];
    if (self) {
        self.appDelegate = (LWAppDelegate *)[[UIApplication sharedApplication] delegate];
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

-(void)get:(NSURL*)url onSuccess:(Success)success onFailure:(Failure)failure {
    NSURLRequest *request = [NSURLRequest requestWithURL:url];
    [self makeRequest: request onSuccess: success onFailure: failure];
}

-(void)post:(NSURL*)url params:(NSDictionary*)params onSuccess:(Success)success onFailure:(Failure)failure {
    NSMutableString *postString = [[NSMutableString alloc] init];
    for (NSString *key in params) {
        [postString appendString:[NSString stringWithFormat:@"%@=%@&", key, params[key]]];
    }
    NSData *postData = [postString dataUsingEncoding:NSASCIIStringEncoding allowLossyConversion:YES];
    NSString *postLength = [NSString stringWithFormat:@"%lu",[postData length]];
    
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:url];
    [request setHTTPMethod:@"POST"];
    [request setValue:postLength forHTTPHeaderField:@"Content-Length"];
    [request setValue:@"application/x-www-form-urlencoded" forHTTPHeaderField:@"Content-Type"];
    [request setHTTPBody:postData];
    
    [self makeRequest: request onSuccess: success onFailure: failure];
}

-(void)delete:(NSURL*)url onSuccess:(Success)success onFailure:(Failure)failure {
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:url];
    [request setHTTPMethod:@"DELETE"];
    [self makeRequest: request onSuccess: success onFailure: failure];
}


// API METHODS

// -- STADIUMS

-(void)getStadiums:(Success)success onFailure:(Failure)failure {
    NSURL *url = [[NSURL alloc] initWithString:[self stadiumsPath]];
    [self get:url onSuccess: success onFailure: failure];
}

-(void)getStadium:(NSString*)stadiumID onSuccess:(Success)success onFailure:(Failure)failure {
    NSURL *url = [[NSURL alloc] initWithString:[self stadiumsPath: stadiumID]];
    [self get:url onSuccess: success onFailure: failure];
}

// -- EVENTS

-(void)getEvents:(NSString*)clientID onSuccess:(Success)success onFailure:(Failure)failure {
    NSURL *url = [[NSURL alloc] initWithString:[self eventsPath:clientID]];
    NSURLRequest *request = [NSURLRequest requestWithURL:url];
    [self makeRequest: request onSuccess: success onFailure: failure];
}

-(void)joinEvent:(NSString*)eventID params:(NSDictionary*)params onSuccess:(Success)success onFailure:(Failure)failure {
    NSString *path = [NSString stringWithFormat: @"%@/events/%@/user_locations", self.appDelegate.apiURL, eventID];
    NSURL *url = [[NSURL alloc] initWithString:path];
    [self post:url params:params onSuccess: success onFailure: failure];
}

-(void)leaveEvent:(NSString*)userID onSuccess:(Success)success onFailure:(Failure)failure {
    NSString *path = [NSString stringWithFormat: @"%@/user_locations/%@/", self.appDelegate.apiURL, userID];
    NSURL *url = [[NSURL alloc] initWithString:path];
    [self delete:url onSuccess: success onFailure: failure];
}


// -- SHOWS

-(void)getShows:(NSString*)eventID onSuccess:(Success)success onFailure:(Failure)failure {
    NSURL *url = [[NSURL alloc] initWithString:[self showsPath:eventID]];
    [self get:url onSuccess: success onFailure: failure];
}

-(void)getShow:(NSString*)eventID show:(NSString*)showID onSuccess:(Success)success onFailure:(Failure)failure {
    NSURL *url = [[NSURL alloc] initWithString:[self showsPath:eventID withShow:showID ]];
    [self get:url onSuccess: success onFailure: failure];
}

-(void)joinShow:(NSString*)userID params:(NSDictionary*)params onSuccess:(Success)success onFailure:(Failure)failure {
    NSString *path = [NSString stringWithFormat: @"%@/user_locations/%@/event_joins", self.appDelegate.apiURL, userID];
    NSURL *url = [[NSURL alloc] initWithString:path];
    [self post:url params:params onSuccess: success onFailure: failure];
}

// API HELPERS

-(NSString*)stadiumsPath {
    return [self stadiumsPath: @""];
}
-(NSString*)stadiumsPath:(NSString*)stadiumID {
    return [NSString stringWithFormat: @"%@/stadiums/%@", self.appDelegate.apiURL, stadiumID];
}


-(NSString*)eventsPath:(NSString*)clientID {
    return [self eventsPath: clientID withEvent: @""];
}
-(NSString*)eventsPath:(NSString*)clientID withEvent:(NSString*)eventID {
    return [NSString stringWithFormat: @"%@/clients/%@/events/%@", self.appDelegate.apiURL, clientID, eventID];
}

-(NSString*)showsPath:(NSString*)eventID {
    return [NSString stringWithFormat: @"%@/events/%@/shows", self.appDelegate.apiURL, eventID];
}
-(NSString*)showsPath:(NSString*)eventID withShow:(NSString*)showID {
    return [NSString stringWithFormat: @"%@/events/%@/shows/%@", self.appDelegate.apiURL, eventID, showID];
}

@end
