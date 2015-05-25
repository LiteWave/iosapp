//
//  BSJSONDeserializer.m
//  Client
//


#import "BSJSONDeserializer.h"
#import "NSArray+BSJSONAdditions.h"

@implementation BSJSONDeserializer

- (NSArray *)performDeserialization:(id)data
{
    NSString *jsonString = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
    NSArray *array = [NSArray arrayWithJSONString:jsonString];
   
    return array;
}

@end
