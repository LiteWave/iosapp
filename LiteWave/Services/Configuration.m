//
//  LightWave.m
//  LiteWave
//
//  Created by David Anderson on 5/25/15.
//  Copyright (c) 2015 LightWave. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "Configuration.h"

@implementation Configuration

+ (id)instance {
    static Configuration *theInstance = nil;
    @synchronized(self) {
        if (theInstance == nil)
            theInstance = [[self alloc] init];
    }
    return theInstance;
}

- (id)init {
    // Forward to the "designated" initialization method
    self = [super init];
    if (self) {
        _properties = [[NSMutableDictionary alloc] init];
        
    #ifdef DEBUG
        _properties[@"apiURL"] = @"http://127.0.0.1:3000/api";
    #else
        _properties[@"apiURL"] = @"http://test.crowdpxl.com:8081/api";
    #endif
        
    }
    return self;
}

- (id)get:(NSString*)property {
    return self.properties[property];
}

- (void)set:(NSString*)property value:(id)value {
    self.properties[property] = value;
}

@end