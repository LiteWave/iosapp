//
//  CJSONDeserializer.h
//  Client
//


#import <Foundation/Foundation.h>

extern NSString *const kJSONDeserializerErrorDomain /* = @"CJSONDeserializerErrorDomain" */;

@interface CJSONDeserializer : NSObject {

}

+ (id)deserializer;

- (id)deserialize:(NSData *)inData error:(NSError **)outError;

- (id)deserializeAsDictionary:(NSData *)inData error:(NSError **)outError;
- (id)deserializeAsArray:(NSData *)inData error:(NSError **)outError;

@end
