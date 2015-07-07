//
//  CJSONSerializer.h
//  Client
//


#import <Foundation/Foundation.h>

@class CJSONDataSerializer;

/// Serialize JSON compatible objects (NSNull, NSNumber, NSString, NSArray, NSDictionary) into a JSON formatted string. Note this class is just a wrapper around CJSONDataSerializer which you really should be using instead.
@interface CJSONSerializer : NSObject {
	CJSONDataSerializer *serializer;
}

+ (id)serializer;

/// Take any JSON compatible object (generally NSNull, NSNumber, NSString, NSArray and NSDictionary) and produce a JSON string.
- (NSString *)serializeObject:(id)inObject;

- (NSString *)serializeArray:(NSArray *)inArray;
- (NSString *)serializeDictionary:(NSDictionary *)inDictionary;

@end
