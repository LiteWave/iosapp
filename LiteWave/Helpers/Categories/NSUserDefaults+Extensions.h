//
//  NSUserDefaults+Extensions.h
//  Client
//


#import <Foundation/Foundation.h>

@interface NSUserDefaults (Extensions)

- (void)setDefaultValuesIfRequired;

@property (nonatomic, copy) NSString *serverURL;

@end
