// AFXMLRequestOperation.m
//


#import "LWFAFXMLRequestOperation.h"

#include <Availability.h>

static dispatch_queue_t lwfaf_xml_request_operation_processing_queue;
static dispatch_queue_t xml_request_operation_processing_queue() {
    if (lwfaf_xml_request_operation_processing_queue == NULL) {
        lwfaf_xml_request_operation_processing_queue = dispatch_queue_create("com.alamofire.networking.xml-request.processing", 0);
    }
    
    return lwfaf_xml_request_operation_processing_queue;
}

@interface LWFAFXMLRequestOperation ()
@property (readwrite, nonatomic, retain) NSXMLParser *responseXMLParser;
#if __MAC_OS_X_VERSION_MIN_REQUIRED
@property (readwrite, nonatomic, retain) NSXMLDocument *responseXMLDocument;
#endif
@property (readwrite, nonatomic, retain) NSError *error;

+ (NSSet *)defaultAcceptableContentTypes;
+ (NSSet *)defaultAcceptablePathExtensions;
@end

@implementation LWFAFXMLRequestOperation
@synthesize responseXMLParser = _responseXMLParser;
#if __MAC_OS_X_VERSION_MIN_REQUIRED
@synthesize responseXMLDocument = _responseXMLDocument;
#endif
@synthesize error = _XMLError;

+ (LWFAFXMLRequestOperation *)XMLParserRequestOperationWithRequest:(NSURLRequest *)urlRequest
                                                        success:(void (^)(NSURLRequest *request, NSHTTPURLResponse *response, NSXMLParser *XMLParser))success
                                                        failure:(void (^)(NSURLRequest *request, NSHTTPURLResponse *response, NSError *error))failure
{
    LWFAFXMLRequestOperation *operation = [[self alloc] initWithRequest:urlRequest];
    operation.completionBlock = ^ {
        if ([operation isCancelled]) {
            return;
        }
    
        if (operation.error) {
            if (failure) {
                dispatch_async(dispatch_get_main_queue(), ^(void) {
                    failure(operation.request, operation.response, operation.error);
                });
            }
        } else {
            NSXMLParser *XMLParser = operation.responseXMLParser;
            if (success) {
                dispatch_async(dispatch_get_main_queue(), ^(void) {
                    success(operation.request, operation.response, XMLParser);
                });
            }
        }
    };
    
    return operation;
}

#if __MAC_OS_X_VERSION_MIN_REQUIRED
+ (LWFAFXMLRequestOperation *)XMLDocumentRequestOperationWithRequest:(NSURLRequest *)urlRequest
                                                          success:(void (^)(NSURLRequest *request, NSHTTPURLResponse *response, NSXMLDocument *document))success
                                                          failure:(void (^)(NSURLRequest *request, NSHTTPURLResponse *response, NSError *error))failure
{
    LWFAFXMLRequestOperation *operation = [[[self alloc] initWithRequest:urlRequest] autorelease];
    operation.completionBlock = ^ {
        if ([operation isCancelled]) {
            return;
        }
        
        if (operation.error) {
            if (failure) {
                dispatch_async(dispatch_get_main_queue(), ^(void) {
                    failure(operation.request, operation.response, operation.error);
                });
            }
        } else {
            dispatch_async(xml_request_operation_processing_queue(), ^(void) {
                NSXMLDocument *XMLDocument = operation.responseXMLDocument;
                if (success) {
                    dispatch_async(dispatch_get_main_queue(), ^(void) {
                        success(operation.request, operation.response, XMLDocument);
                    });
                }
            });
        }
    };
    
    return operation;
}
#endif

+ (NSSet *)defaultAcceptableContentTypes {
    return [NSSet setWithObjects:@"application/xml", @"text/xml", nil];
}

+ (NSSet *)defaultAcceptablePathExtensions {
    return [NSSet setWithObjects:@"xml", nil];
}

- (id)initWithRequest:(NSURLRequest *)urlRequest {
    self = [super initWithRequest:urlRequest];
    if (!self) {
        return nil;
    }
    
    self.acceptableContentTypes = [[self class] defaultAcceptableContentTypes];
    
    return self;
}

- (void)dealloc {
    _responseXMLParser.delegate = nil;
   
    
#if __MAC_OS_X_VERSION_MIN_REQUIRED
    [_responseXMLDocument release];
#endif
    
  
}

- (NSXMLParser *)responseXMLParser {
    if (!_responseXMLParser && [self isFinished]) {
        self.responseXMLParser = [[NSXMLParser alloc] initWithData:self.responseData];
    }
    
    return _responseXMLParser;
}

#if __MAC_OS_X_VERSION_MIN_REQUIRED
- (NSXMLDocument *)responseXMLDocument {
    if (!_responseXMLDocument && [self isFinished]) {
        NSError *error = nil;
        self.responseXMLDocument = [[[NSXMLDocument alloc] initWithData:self.responseData options:0 error:&error] autorelease];
        self.error = error;
    }
    
    return _responseXMLDocument;
}
#endif

#pragma mark - NSOperation

- (void)cancel {
    [super cancel];
    
    self.responseXMLParser.delegate = nil;
}

#pragma mark - LWFAFHTTPClientOperation

+ (BOOL)canProcessRequest:(NSURLRequest *)request {
    return [[self defaultAcceptableContentTypes] containsObject:[request valueForHTTPHeaderField:@"Accept"]] || [[self defaultAcceptablePathExtensions] containsObject:[[request URL] pathExtension]];
}

+ (LWFAFHTTPRequestOperation *)HTTPRequestOperationWithRequest:(NSURLRequest *)urlRequest
                                                    success:(void (^)(id object))success 
                                                    failure:(void (^)(NSHTTPURLResponse *response, NSError *error))failure
{
#if __MAC_OS_X_VERSION_MIN_REQUIRED
    return [self XMLDocumentRequestOperationWithRequest:urlRequest success:^(NSURLRequest __unused *request, NSHTTPURLResponse __unused *response, NSXMLDocument *XMLDocument) {
        success(XMLDocument);
    } failure:^(NSURLRequest __unused *request, NSHTTPURLResponse *response, NSError *error) {
        failure(response, error);
    }];
#else
    return [self XMLParserRequestOperationWithRequest:urlRequest success:^(NSURLRequest __unused *request, NSHTTPURLResponse __unused *response, NSXMLParser *XMLParser) {
        success(XMLParser);
    } failure:^(NSURLRequest __unused *request, NSHTTPURLResponse *response, NSError *error) {
        failure(response, error);
    }];
#endif
}

@end
