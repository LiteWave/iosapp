//
//  BaseDataLoader.h
//  Client
//


#import <Foundation/Foundation.h>
#import "Deserializer.h"
#import "DeserializerDelegate.h"
#import "LoaderMechanism.h"
#import "DataLoaderDelegate.h"
#import "DataLoader.h"

@interface BaseDataLoader : NSObject <DataLoader>
{
@private
    NSData *_data;
    NSURL *_url;
    NSError *_error;
    NSTimeInterval _interval;
    NSInteger _limit;
    NSString *_baseURLString;
    id<Deserializer> _deserializer;
    __unsafe_unretained id<DataLoaderDelegate> _delegate;
}

@property (nonatomic, retain) NSURL *url;
@property (nonatomic, retain) NSError *error;
@property (nonatomic) NSTimeInterval interval;

+ (id<DataLoader>)loaderWithMechanism:(LoaderMechanism)mechanism;
+ (id<DataLoader>)loader;

- (void)ready;
- (void)performAsynchronousLoading;

@end
