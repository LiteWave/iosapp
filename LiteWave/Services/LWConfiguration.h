//
//  Configuration.h
//  LiteWave
//
//  Created by David Anderson on 5/25/15.
//  Copyright (c) 2015 LightWave. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface LWConfiguration : NSObject {
}

@property (nonatomic, retain) NSMutableDictionary *properties;

+ (id)instance;

- (id)get:(NSString*)property;
- (void)set:(NSString*)property value:(id)value;

@end
