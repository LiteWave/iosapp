//
//  NSURLConnectionDataLoader.m
//  Client
//


#import "NSURLConnectionDataLoader.h"

@interface NSURLConnectionDataLoader ()
@property (nonatomic, retain) NSMutableData *receivedData;
@property (nonatomic, retain) NSURLConnection *connection;
@end


@implementation NSURLConnectionDataLoader

@synthesize receivedData = _receivedData;
@synthesize connection = _connection;

- (void)dealloc
{
    self.connection = nil;
    self.receivedData = nil;
   
}

- (void)performAsynchronousLoading
{
    NSMutableURLRequest* request = [NSMutableURLRequest requestWithURL:self.url
                                                           cachePolicy:NSURLRequestUseProtocolCachePolicy
                                                       timeoutInterval:60.0];
    NSMutableData *receivedData = [[NSMutableData alloc] init];
    self.receivedData = receivedData;
    

    NSURLConnection *connection = [[NSURLConnection alloc] initWithRequest:request
                                                                  delegate:self
                                                          startImmediately:YES];
    self.connection = connection;
   
}

#pragma mark -
#pragma mark NSURLConnection delegate methods

- (void)connection:(NSURLConnection *)connection didReceiveResponse:(NSURLResponse *)response
{
    [self.receivedData setLength:0];
}

- (void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)data
{
    [self.receivedData appendData:data];
}

- (void)connection:(NSURLConnection *)connection didFailWithError:(NSError *)error
{
    self.error = error;
}

- (void)connectionDidFinishLoading:(NSURLConnection *)connection
{
    self.data = self.receivedData;
    [self ready];
}

@end
