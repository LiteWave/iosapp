//
//  DataLoaderDelegate.h
//  Client
//


#import <Foundation/Foundation.h>

@class BaseDataLoader;

@protocol DataLoaderDelegate <NSObject>

@required

- (void)dataLoader:(BaseDataLoader *)loader didLoadData:(NSArray *)data;

@end
