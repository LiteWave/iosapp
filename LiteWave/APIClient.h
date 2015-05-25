//
//  APIClient.h
//  LiteWave
//
//  Created by mike draghici on 11/14/13.
//  Copyright (c) 2013 LightWave. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "AFHTTPClient.h"

@interface APIClient : AFHTTPClient

+(APIClient *)sharedProxy;

@end
