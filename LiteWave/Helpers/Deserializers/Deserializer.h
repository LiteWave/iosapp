//
//  Deserializer.h
//  Client
//


#import <Foundation/Foundation.h>

@protocol DeserializerDelegate;

@protocol Deserializer <NSObject>

@required

@property (nonatomic) BOOL isAsynchronous;
@property (nonatomic, assign) id<DeserializerDelegate> delegate;
@property (nonatomic) NSTimeInterval interval;

- (NSArray *)deserializeData:(id)data;
- (NSString *)formatIdentifier;
- (void)startDeserializing:(id)data;

@end
