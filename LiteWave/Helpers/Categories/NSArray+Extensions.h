//
//  NSArray+Extensions.h
//  Client
//


#import <Foundation/Foundation.h>

#define KEY_DATA_LOADER @"dataLoader"
#define KEY_DESERIALIZER @"deserializer"
#define KEY_LIMIT @"limit"
#define KEY_LOADER_TIME @"loaderTime"
#define KEY_DESERIALIZER_TIME @"deserializerTime"
#define KEY_DATA_LENGTH @"dataLength"
#define KEY_FORMAT @"format"

@interface NSArray (Extensions)

- (NSData *)formattedAsCSV;

@end
