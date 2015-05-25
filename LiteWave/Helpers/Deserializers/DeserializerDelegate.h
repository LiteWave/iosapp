//
//  DeserializerDelegate.h
//  Client
//


#import <Foundation/Foundation.h>

@protocol Deserializer;

@protocol DeserializerDelegate <NSObject>

@optional
- (void)deserializer:(id<Deserializer>)deserializer didFinishDeserializing:(NSArray *)array;

@end
