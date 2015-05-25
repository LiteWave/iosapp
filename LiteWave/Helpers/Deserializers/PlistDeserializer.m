//
//  PlistDeserializer.m
//  Client
//


#import "PlistDeserializer.h"

@implementation PlistDeserializer

- (NSArray *)performDeserialization:(id)data
{
    NSString *errorDescription = nil;
    NSPropertyListFormat format;
    NSArray *array = [NSPropertyListSerialization propertyListFromData:data
                                                      mutabilityOption:NSPropertyListImmutable 
                                                                format:&format 
                                                      errorDescription:&errorDescription];
    return array;
}

@end
