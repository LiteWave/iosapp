//
//  AFNetworkingDataLoader.m
//  Client
//


#import "AFNetworkingDataLoader.h"
#import "AFHTTPRequestOperation.h"

@implementation AFNetworkingDataLoader

- (void)performAsynchronousLoading
{
    void (^success)(id object) = ^(id object) {
        self.data = object;
        [self ready];
    };
    
    void (^failure)(NSHTTPURLResponse *response, NSError *error) = ^(NSHTTPURLResponse *response, NSError *error) {
        self.data = nil;
    };
    
    NSURLRequest *request = [NSURLRequest requestWithURL:self.url];
    AFHTTPRequestOperation *operation = [AFHTTPRequestOperation  HTTPRequestOperationWithRequest:request 
                                                                                         success:success
                                                                                         failure:failure];
    [operation start];
}

@end
