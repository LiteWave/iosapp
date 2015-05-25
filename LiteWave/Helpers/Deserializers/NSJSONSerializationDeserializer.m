//
//  NSJSONSerializationDeserializer.m
//  Client
//


#import "NSJSONSerializationDeserializer.h"

@implementation NSJSONSerializationDeserializer

- (NSArray *)performDeserialization:(id)data
{
    NSArray *array = nil;
    
    // Just to make sure that this doesn't crash in iOS 4.x
    Class klass = NSClassFromString(@"NSJSONSerialization");
    if (nil != klass)
    {
        array = [NSJSONSerialization JSONObjectWithData:data options:0 error:nil];
    }
    return array;
}

@end
