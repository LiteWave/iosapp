//
//  SBJSONDeserializer.m
//  Client
//


#import "SBJSONDeserializer.h"
#import "JSON.h"

@implementation SBJSONDeserializer

- (NSArray *)performDeserialization:(id)data
{
    NSString *jsonString = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
    NSArray *array = [jsonString JSONValue];
   
    return array;
}

@end
