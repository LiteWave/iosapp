//
//  LightWave.m
//  LiteWave
//
//  Created by David Anderson on 5/25/15.
//  Copyright (c) 2015 LightWave. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "LWConfiguration.h"

@implementation LWConfiguration

+ (id)instance {
    static LWConfiguration *theInstance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        theInstance = [[self alloc] init];
    });
    return theInstance;
}

- (id)init {
    // Forward to the "designated" initialization method
    self = [super init];
    if (self) {
        _properties = [[NSMutableDictionary alloc] init];
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