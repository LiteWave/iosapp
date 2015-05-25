//
//  DataLoader.h
//  Client
//


#import <Foundation/Foundation.h>

@protocol DataLoaderDelegate;
@protocol DeserializerDelegate;
@protocol Deserializer;

@protocol DataLoader <DeserializerDelegate>

@required

@property (nonatomic) NSInteger limit;
@property (nonatomic, copy) NSString *baseURLString;
@property (nonatomic, assign) id<DataLoaderDelegate> delegate;
@property (nonatomic, retain) id<Deserializer> deserializer;
@property (nonatomic, retain) id data;

- (void)loadData;

@end
