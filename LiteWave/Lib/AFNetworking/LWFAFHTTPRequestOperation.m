// AFHTTPOperation.m
//


#import "LWFAFHTTPRequestOperation.h"

@interface LWFAFHTTPRequestOperation ()
@property (readwrite, nonatomic, retain) NSError *error;
@property (readonly, nonatomic, assign) BOOL hasContent;
@end

@implementation LWFAFHTTPRequestOperation
@synthesize acceptableStatusCodes = _acceptableStatusCodes;
@synthesize acceptableContentTypes = _acceptableContentTypes;
@synthesize error = _HTTPError;

- (id)initWithRequest:(NSURLRequest *)request {
    self = [super initWithRequest:request];
    if (!self) {
        return nil;
    }
    
    self.acceptableStatusCodes = [NSIndexSet indexSetWithIndexesInRange:NSMakeRange(200, 100)];
    
    return self;
}

- (void)dealloc {

}

- (NSHTTPURLResponse *)response {
    return (NSHTTPURLResponse *)[super response];
}

- (NSError *)error {
    if (self.response) {
        if (![self hasAcceptableStatusCode]) {
            NSMutableDictionary *userInfo = [NSMutableDictionary dictionary];
            [userInfo setValue:[NSString stringWithFormat:NSLocalizedString(@"Expected status code %@, got %d", nil), self.acceptableStatusCodes, [self.response statusCode]] forKey:NSLocalizedDescriptionKey];
            [userInfo setValue:[self.request URL] forKey:NSURLErrorFailingURLErrorKey];
            
            self.error = [[NSError alloc] initWithDomain:LWFAFNetworkingErrorDomain code:NSURLErrorBadServerResponse userInfo:userInfo];
        } else if ([self hasContent] && ![self hasAcceptableContentType]) { // Don't invalidate content type if there is no content
            NSMutableDictionary *userInfo = [NSMutableDictionary dictionary];
            [userInfo setValue:[NSString stringWithFormat:NSLocalizedString(@"Expected content type %@, got %@", nil), self.acceptableContentTypes, [self.response MIMEType]] forKey:NSLocalizedDescriptionKey];
            [userInfo setValue:[self.request URL] forKey:NSURLErrorFailingURLErrorKey];
            
            self.error = [[NSError alloc] initWithDomain:LWFAFNetworkingErrorDomain code:NSURLErrorCannotDecodeContentData userInfo:userInfo];
        }
    }
    
    return _HTTPError;
}

- (BOOL)hasContent {
    return [self.responseData length] > 0;
}

- (BOOL)hasAcceptableStatusCode {
    return !self.acceptableStatusCodes || [self.acceptableStatusCodes containsIndex:[self.response statusCode]];
}

- (BOOL)hasAcceptableContentType {
    return !self.acceptableContentTypes || [self.acceptableContentTypes containsObject:[self.response MIMEType]];
}

#pragma mark - LWFAFHTTPClientOperation

+ (BOOL)canProcessRequest:(NSURLRequest *)request {
    return NO;
}

+ (LWFAFHTTPRequestOperation *)HTTPRequestOperationWithRequest:(NSURLRequest *)urlRequest
                                                    success:(void (^)(id object))success 
                                                    failure:(void (^)(NSHTTPURLResponse *response, NSError *error))failure
{
    LWFAFHTTPRequestOperation *operation = [[self alloc] initWithRequest:urlRequest];
    operation.completionBlock = ^ {
        if ([operation isCancelled]) {
            return;
        }
        
        if (operation.error) {
            if (failure) {
                dispatch_async(dispatch_get_main_queue(), ^(void) {
                    failure(operation.response, operation.error);
                });
            }
        } else {
            if (success) {
                dispatch_async(dispatch_get_main_queue(), ^(void) {
                    success(operation.responseData);
                });
            }
        }
    };
    
    return operation;
}        

@end
