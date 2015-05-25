//
//  TouchJSONDeserializer.m
//  Client
//


#import "TouchJSONDeserializer.h"
#import "CJSONDeserializer.h"

@implementation TouchJSONDeserializer

- (NSArray *)performDeserialization:(id)data
{
    NSError *error = nil;
    NSArray *array = [[CJSONDeserializer deserializer] deserializeAsArray:data 
                                                                    error:&error];
    return array;
}

@end
