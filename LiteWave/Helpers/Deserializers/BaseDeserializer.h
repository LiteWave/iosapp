//
//  BaseDeserializer.h
//  Client
//


#import <Foundation/Foundation.h>
#import "Deserializer.h"
#import "DeserializerDelegate.h"
#import "DeserializerType.h"

@interface BaseDeserializer : NSObject <Deserializer>
{
@private
    NSTimeInterval _interval;
    BOOL _isAsynchronous;
    __unsafe_unretained id<DeserializerDelegate> _delegate;
}

+ (id<Deserializer>)deserializerForFormat:(DeserializerType)format;
+ (id<Deserializer>)deserializer;
- (NSArray *)performDeserialization:(NSData *)data;
- (void)startTimer;
- (void)stopTimer;

@end
