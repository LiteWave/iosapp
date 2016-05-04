// AFURLConnectionOperation.m
//


#import "LWFAFURLConnectionOperation.h"

static NSUInteger const kLWFAFHTTPMinimumInitialDataCapacity = 1024;
static NSUInteger const kLWFAFHTTPMaximumInitialDataCapacity = 1024 * 1024 * 8;

typedef enum {
    LWFAFHTTPOperationReadyState       = 1,
    LWFAFHTTPOperationExecutingState   = 2,
    LWFAFHTTPOperationFinishedState    = 3,
} LWFAFOperationState;

NSString * const LWFAFNetworkingErrorDomain = @"com.alamofire.networking.error";

NSString * const LWFAFNetworkingOperationDidStartNotification = @"com.alamofire.networking.operation.start";
NSString * const LWFAFNetworkingOperationDidFinishNotification = @"com.alamofire.networking.operation.finish";

typedef void (^LWFAFURLConnectionOperationProgressBlock)(NSInteger bytes, NSInteger totalBytes, NSInteger totalBytesExpected);

static inline NSString * LWFAFKeyPathFromOperationState(LWFAFOperationState state) {
    switch (state) {
        case LWFAFHTTPOperationReadyState:
            return @"isReady";
        case LWFAFHTTPOperationExecutingState:
            return @"isExecuting";
        case LWFAFHTTPOperationFinishedState:
            return @"isFinished";
        default:
            return @"state";
    }
}

@interface LWFAFURLConnectionOperation ()
@property (readwrite, nonatomic, assign) LWFAFOperationState state;
@property (readwrite, nonatomic, assign, getter = isCancelled) BOOL cancelled;
@property (readwrite, nonatomic, retain) NSURLConnection *connection;
@property (readwrite, nonatomic, retain) NSURLRequest *request;
@property (readwrite, nonatomic, retain) NSURLResponse *response;
@property (readwrite, nonatomic, retain) NSError *error;
@property (readwrite, nonatomic, retain) NSData *responseData;
@property (readwrite, nonatomic, copy) NSString *responseString;
@property (readwrite, nonatomic, assign) NSInteger totalBytesRead;
@property (readwrite, nonatomic, retain) NSMutableData *dataAccumulator;
@property (readwrite, nonatomic, copy) LWFAFURLConnectionOperationProgressBlock uploadProgress;
@property (readwrite, nonatomic, copy) LWFAFURLConnectionOperationProgressBlock downloadProgress;

- (BOOL)shouldTransitionToState:(LWFAFOperationState)state;
- (void)operationDidStart;
- (void)finish;
@end

@implementation LWFAFURLConnectionOperation
@synthesize state = _state;
@synthesize cancelled = _cancelled;
@synthesize connection = _connection;
@synthesize runLoopModes = _runLoopModes;
@synthesize request = _request;
@synthesize response = _response;
@synthesize error = _error;
@synthesize responseData = _responseData;
@synthesize responseString = _responseString;
@synthesize totalBytesRead = _totalBytesRead;
@synthesize dataAccumulator = _dataAccumulator;
@dynamic inputStream;
@synthesize outputStream = _outputStream;
@synthesize uploadProgress = _uploadProgress;
@synthesize downloadProgress = _downloadProgress;

+ (void)networkRequestThreadEntryPoint:(id)__unused object {
    do {
        //NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];
        [[NSRunLoop currentRunLoop] run];
        //[pool drain];
    } while (YES);
}

+ (NSThread *)networkRequestThread {
    static NSThread *_networkRequestThread = nil;
    static dispatch_once_t oncePredicate;
    
    dispatch_once(&oncePredicate, ^{
        _networkRequestThread = [[NSThread alloc] initWithTarget:self selector:@selector(networkRequestThreadEntryPoint:) object:nil];
        [_networkRequestThread start];
    });
    
    return _networkRequestThread;
}

- (id)initWithRequest:(NSURLRequest *)urlRequest {
    self = [super init];
    if (!self) {
		return nil;
    }
    
    self.runLoopModes = [NSSet setWithObject:NSRunLoopCommonModes];
    
    self.request = urlRequest;
    
    self.state = LWFAFHTTPOperationReadyState;
	
    return self;
}

- (void)dealloc {

}

- (void)setCompletionBlock:(void (^)(void))block {
    if (!block) {
        [super setCompletionBlock:nil];
    } else {
        __block id _blockSelf = self;
        [super setCompletionBlock:^ {
            block();
            [_blockSelf setCompletionBlock:nil];
        }];
    }
}

- (NSInputStream *)inputStream {
    return self.request.HTTPBodyStream;
}

- (void)setInputStream:(NSInputStream *)inputStream {
    NSMutableURLRequest *mutableRequest = [self.request mutableCopy];
    mutableRequest.HTTPBodyStream = inputStream;
    self.request = mutableRequest;
}

- (void)setUploadProgressBlock:(void (^)(NSInteger bytesWritten, NSInteger totalBytesWritten, NSInteger totalBytesExpectedToWrite))block {
    self.uploadProgress = block;
}

- (void)setDownloadProgressBlock:(void (^)(NSInteger bytesRead, NSInteger totalBytesRead, NSInteger totalBytesExpectedToRead))block {
    self.downloadProgress = block;
}

- (void)setState:(LWFAFOperationState)state {
    if (![self shouldTransitionToState:state]) {
        return;
    }
    
    NSString *oldStateKey = LWFAFKeyPathFromOperationState(self.state);
    NSString *newStateKey = LWFAFKeyPathFromOperationState(state);
    
    [self willChangeValueForKey:newStateKey];
    [self willChangeValueForKey:oldStateKey];
    _state = state;
    [self didChangeValueForKey:oldStateKey];
    [self didChangeValueForKey:newStateKey];
    
    switch (state) {
        case LWFAFHTTPOperationExecutingState:
            [[NSNotificationCenter defaultCenter] postNotificationName:LWFAFNetworkingOperationDidStartNotification object:self];
            break;
        case LWFAFHTTPOperationFinishedState:
            [[NSNotificationCenter defaultCenter] postNotificationName:LWFAFNetworkingOperationDidFinishNotification object:self];
            break;
        default:
            break;
    }
}

- (BOOL)shouldTransitionToState:(LWFAFOperationState)state {
    switch (self.state) {
        case LWFAFHTTPOperationReadyState:
            switch (state) {
                case LWFAFHTTPOperationExecutingState:
                    return YES;
                default:
                    return NO;
            }
        case LWFAFHTTPOperationExecutingState:
            switch (state) {
                case LWFAFHTTPOperationFinishedState:
                    return YES;
                default:
                    return NO;
            }
        case LWFAFHTTPOperationFinishedState:
            return NO;
        default:
            return YES;
    }
}

- (void)setCancelled:(BOOL)cancelled {
    [self willChangeValueForKey:@"isCancelled"];
    _cancelled = cancelled;
    [self didChangeValueForKey:@"isCancelled"];
    
    if ([self isCancelled]) {
        self.state = LWFAFHTTPOperationFinishedState;
    }
}

- (NSString *)responseString {
    if (!_responseString && self.response && self.responseData) {
        NSStringEncoding textEncoding = NSUTF8StringEncoding;
        if (self.response.textEncodingName) {
            textEncoding = CFStringConvertEncodingToNSStringEncoding(CFStringConvertIANACharSetNameToEncoding((CFStringRef)self.response.textEncodingName));
        }
        
        self.responseString = [[NSString alloc] initWithData:self.responseData encoding:textEncoding];
    }
    
    return _responseString;
}

#pragma mark - NSOperation

- (BOOL)isReady {
    return self.state == LWFAFHTTPOperationReadyState;
}

- (BOOL)isExecuting {
    return self.state == LWFAFHTTPOperationExecutingState;
}

- (BOOL)isFinished {
    return self.state == LWFAFHTTPOperationFinishedState;
}

- (BOOL)isConcurrent {
    return YES;
}

- (void)start {  
    if (![self isReady]) {
        return;
    }
    
    self.state = LWFAFHTTPOperationExecutingState;
    
    [self performSelector:@selector(operationDidStart) onThread:[[self class] networkRequestThread] withObject:nil waitUntilDone:YES modes:[self.runLoopModes allObjects]];
}

- (void)operationDidStart {
    if ([self isCancelled]) {
        [self finish];
        return;
    }
    
    self.connection = [[NSURLConnection alloc] initWithRequest:self.request delegate:self startImmediately:NO];
    
    NSRunLoop *runLoop = [NSRunLoop currentRunLoop];
    for (NSString *runLoopMode in self.runLoopModes) {
        [self.connection scheduleInRunLoop:runLoop forMode:runLoopMode];
        [self.outputStream scheduleInRunLoop:runLoop forMode:runLoopMode];
    }
    
    [self.connection start];
}

- (void)finish {
    self.state = LWFAFHTTPOperationFinishedState;
}

- (void)cancel {
    if ([self isFinished]) {
        return;
    }
    
    [super cancel];
    
    self.cancelled = YES;
    
    [self.connection cancel];
}

#pragma mark - NSURLConnectionDelegate

- (void)connection:(NSURLConnection *)__unused connection 
   didSendBodyData:(NSInteger)bytesWritten 
 totalBytesWritten:(NSInteger)totalBytesWritten 
totalBytesExpectedToWrite:(NSInteger)totalBytesExpectedToWrite
{
    if (self.uploadProgress) {
        self.uploadProgress(bytesWritten, totalBytesWritten, totalBytesExpectedToWrite);
    }
}

- (void)connection:(NSURLConnection *)__unused connection 
didReceiveResponse:(NSURLResponse *)response 
{
    self.response = (NSHTTPURLResponse *)response;
    
    if (self.outputStream) {
        [self.outputStream open];
    } else {
        NSUInteger maxCapacity = MAX((NSUInteger)llabs(response.expectedContentLength), kLWFAFHTTPMinimumInitialDataCapacity);
        NSUInteger capacity = MIN(maxCapacity, kLWFAFHTTPMaximumInitialDataCapacity);
        self.dataAccumulator = [NSMutableData dataWithCapacity:capacity];
    }
}

- (void)connection:(NSURLConnection *)__unused connection 
    didReceiveData:(NSData *)data 
{
    self.totalBytesRead += [data length];
    
    if (self.outputStream) {
        if ([self.outputStream hasSpaceAvailable]) {
            const uint8_t *dataBuffer = [data bytes];
            [self.outputStream write:&dataBuffer[0] maxLength:[data length]];
        }
    } else {
        [self.dataAccumulator appendData:data];
    }
    
    if (self.downloadProgress) {
        self.downloadProgress([data length], self.totalBytesRead, (NSInteger)self.response.expectedContentLength);
    }
}

- (void)connectionDidFinishLoading:(NSURLConnection *)__unused connection {        
    if (self.outputStream) {
        [self.outputStream close];
    } else {
        self.responseData = [NSData dataWithData:self.dataAccumulator];
         _dataAccumulator = nil;
    }
    
    [self finish];
}

- (void)connection:(NSURLConnection *)__unused connection 
  didFailWithError:(NSError *)error 
{      
    self.error = error;
    
    if (self.outputStream) {
        [self.outputStream close];
    } else {
         _dataAccumulator = nil;
    }
    
    [self finish];
}

- (NSCachedURLResponse *)connection:(NSURLConnection *)__unused connection 
                  willCacheResponse:(NSCachedURLResponse *)cachedResponse 
{
    if ([self isCancelled]) {
        return nil;
    }
    
    return cachedResponse;
}

@end
