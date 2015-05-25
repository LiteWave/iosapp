//
//  Authorization.h
//

#import <Foundation/Foundation.h>

@interface Authorization : NSObject {
}

+(void) deleteAuthorization;

// Cookies
+(void) setCookies:(NSArray*)cookies;
+(NSArray*) cookies;

@end
