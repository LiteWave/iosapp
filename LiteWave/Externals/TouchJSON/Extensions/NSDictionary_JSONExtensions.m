//
//  NSDictionary_JSONExtensions.m
//  Client
//


#import "NSDictionary_JSONExtensions.h"

#import "CJSONDeserializer.h"

@implementation NSDictionary (NSDictionary_JSONExtensions)

+ (id)dictionaryWithJSONData:(NSData *)inData error:(NSError **)outError
{
return([[CJSONDeserializer deserializer] deserialize:inData error:outError]);
}

@end
