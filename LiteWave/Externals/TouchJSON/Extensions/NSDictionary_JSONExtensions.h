//
//  NSDictionary_JSONExtensions.h
//  Client
//


#import <Foundation/Foundation.h>

@interface NSDictionary (NSDictionary_JSONExtensions)

+ (id)dictionaryWithJSONData:(NSData *)inData error:(NSError **)outError;

@end
