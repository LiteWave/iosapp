//
//  UIDeviceHardware.h
//  Client
//


#import <Foundation/Foundation.h>

// This class was adapted from
// http://stackoverflow.com/questions/448162/determine-device-iphone-ipod-touch-with-iphone-sdk

@interface UIDeviceHardware : NSObject 

+ (NSString *)platform;
+ (NSString *)platformString;

@end
