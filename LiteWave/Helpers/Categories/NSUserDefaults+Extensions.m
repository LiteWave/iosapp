//
//  NSUserDefaults+Extensions.m
//  Client
//


#import "NSUserDefaults+Extensions.h"

#define SERVER_URL_KEY @"server_url"

@implementation NSUserDefaults (Extensions)

@dynamic serverURL;

- (void)setDefaultValuesIfRequired
{
    if ([self objectForKey:SERVER_URL_KEY] == nil)
    {
        self.serverURL = @"http://127.0.0.1:3000";
    }
    
}

- (NSString *)serverURL
{
    return [self stringForKey:SERVER_URL_KEY];
}

- (void)setServerURL:(NSString *)urlString
{
    [self setObject:urlString forKey:SERVER_URL_KEY];
    [self synchronize];
}


@end
