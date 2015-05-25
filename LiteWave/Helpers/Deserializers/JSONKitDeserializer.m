//
//  JSONKitDeserializer.m
//  Client
//


#import "JSONKitDeserializer.h"
#import "JSONKit.h"

@implementation JSONKitDeserializer

- (NSArray *)performDeserialization:(id)data
{
    NSArray *array = [data objectFromJSONData];
    return array;
}

@end
