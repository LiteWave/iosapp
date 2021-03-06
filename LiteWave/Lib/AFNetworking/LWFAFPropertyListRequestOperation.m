// AFPropertyListRequestOperation.m
//


#import "LWFAFPropertyListRequestOperation.h"

static dispatch_queue_t lwfaf_property_list_request_operation_processing_queue;
static dispatch_queue_t property_list_request_operation_processing_queue() {
    if (lwfaf_property_list_request_operation_processing_queue == NULL) {
        lwfaf_property_list_request_operation_processing_queue = dispatch_queue_create("com.alamofire.networking.property-list-request.processing", 0);
    }
    
    return lwfaf_property_list_request_operation_processing_queue;
}

@interface LWFAFPropertyListRequestOperation ()
@property (readwrite, nonatomic, retain) id responsePropertyList;
@property (readwrite, nonatomic, assign) NSPropertyListFormat propertyListFormat;
@property (readwrite, nonatomic, retain) NSError *error;

+ (NSSet *)defaultAcceptableContentTypes;
+ (NSSet *)defaultAcceptablePathExtensions;
@end

@implementation LWFAFPropertyListRequestOperation
@synthesize responsePropertyList = _responsePropertyList;
@synthesize propertyListReadOptions = _propertyListReadOptions;
@synthesize propertyListFormat = _propertyListFormat;
@synthesize error = _propertyListError;

+ (LWFAFPropertyListRequestOperation *)propertyListRequestOperationWithRequest:(NSURLRequest *)request
                                                                    success:(void (^)(NSURLRequest *request, NSHTTPURLResponse *response, id propertyList))success
                                                                    failure:(void (^)(NSURLRequest *request, NSHTTPURLResponse *response, NSError *error))failure
{
    LWFAFPropertyListRequestOperation *operation = [[self alloc] initWithRequest:request];
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
            dispatch_async(property_list_request_operation_processing_queue(), ^(void) {
                id propertyList = operation.responsePropertyList;
                
                dispatch_async(dispatch_get_main_queue(), ^(void) {
                    if (operation.error) {
                        if (failure) {
                            failure(operation.request, operation.response, operation.error);
                        }
                    } else {
                        if (success) {
                            success(operation.request, operation.response, propertyList);
                        }
                    }
                }); 
            });
        }
    };
    
    return operation;
}

+ (NSSet *)defaultAcceptableContentTypes {
    return [NSSet setWithObjects:@"application/x-plist", nil];
}

+ (NSSet *)defaultAcceptablePathExtensions {
    return [NSSet setWithObjects:@"plist", nil];
}

- (id)initWithRequest:(NSURLRequest *)urlRequest {
    self = [super initWithRequest:urlRequest];
    if (!self) {
        return nil;
    }
    
    self.acceptableContentTypes = [[self class] defaultAcceptableContentTypes];
    
    self.propertyListReadOptions = NSPropertyListImmutable;
    
    return self;
}

- (void)dealloc {
 
}

- (id)responsePropertyList {
    if (!_responsePropertyList && [self isFinished]) {
        NSPropertyListFormat format;
        NSError *error = nil;
        self.responsePropertyList = [NSPropertyListSerialization propertyListWithData:self.responseData options:self.propertyListReadOptions format:&format error:&error];
        self.propertyListFormat = format;
        self.error = error;
    }
    
    return _responsePropertyList;
}

#pragma mark - LWFAFHTTPClientOperation

+ (BOOL)canProcessRequest:(NSURLRequest *)request {
    return [[self defaultAcceptableContentTypes] containsObject:[request valueForHTTPHeaderField:@"Accept"]] || [[self defaultAcceptablePathExtensions] containsObject:[[request URL] pathExtension]];
}

+ (LWFAFHTTPRequestOperation *)HTTPRequestOperationWithRequest:(NSURLRequest *)urlRequest
                                                    success:(void (^)(id object))success 
                                                    failure:(void (^)(NSHTTPURLResponse *response, NSError *error))failure
{
    return [self propertyListRequestOperationWithRequest:urlRequest success:^(NSURLRequest __unused *request, NSHTTPURLResponse __unused *response, id propertyList) {
        success(propertyList);
    } failure:^(NSURLRequest __unused *request, NSHTTPURLResponse *response, NSError *error) {
        failure(response, error);
    }];
}

@end
