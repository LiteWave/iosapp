//
//  CJSONDataSerializer.h
//  Client
//


#import <Foundation/Foundation.h>

@interface CJSONDataSerializer : NSObject {
}

+ (id)serializer;

/// Take any JSON compatible object (generally NSNull, NSNumber, NSString, NSArray and NSDictionary) and produce an NSData containing the serialized JSON.
- (NSData *)serializeObject:(id)inObject;

- (NSData *)serializeNull:(NSNull *)inNull;
- (NSData *)serializeNumber:(NSNumber *)inNumber;
- (NSData *)serializeString:(NSString *)inString;
- (NSData *)serializeArray:(NSArray *)inArray;
- (NSData *)serializeDictionary:(NSDictionary *)inDictionary;

@end
