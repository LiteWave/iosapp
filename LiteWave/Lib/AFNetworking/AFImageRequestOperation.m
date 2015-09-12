// AFImageRequestOperation.m
//


#import "AFImageRequestOperation.h"
#import "AFImageCache.h"

static dispatch_queue_t af_image_request_operation_processing_queue;
static dispatch_queue_t image_request_operation_processing_queue() {
    if (af_image_request_operation_processing_queue == NULL) {
        af_image_request_operation_processing_queue = dispatch_queue_create("com.alamofire.networking.image-request.processing", 0);
    }
    
    return af_image_request_operation_processing_queue;
}

@interface AFImageRequestOperation ()
#if __IPHONE_OS_VERSION_MIN_REQUIRED
@property (readwrite, nonatomic, retain) UIImage *responseImage;
#elif __MAC_OS_X_VERSION_MIN_REQUIRED 
@property (readwrite, nonatomic, retain) NSImage *responseImage;
#endif

+ (NSSet *)defaultAcceptableContentTypes;
+ (NSSet *)defaultAcceptablePathExtensions;
@end

@implementation AFImageRequestOperation
@synthesize responseImage = _responseImage;

#if __IPHONE_OS_VERSION_MIN_REQUIRED
+ (AFImageRequestOperation *)imageRequestOperationWithRequest:(NSURLRequest *)urlRequest                
                                                      success:(void (^)(UIImage *image))success
{
    return [self imageRequestOperationWithRequest:urlRequest imageProcessingBlock:nil cacheName:nil success:^(NSURLRequest __unused *request, NSHTTPURLResponse __unused *response, UIImage *image) {
        if (success) {
            success(image);
        }
    } failure:nil];
}
#elif __MAC_OS_X_VERSION_MIN_REQUIRED 
+ (AFImageRequestOperation *)imageRequestOperationWithRequest:(NSURLRequest *)urlRequest                
                                                      success:(void (^)(NSImage *image))success
{
    return [self imageRequestOperationWithRequest:urlRequest imageProcessingBlock:nil cacheName:nil success:^(NSURLRequest __unused *request, NSHTTPURLResponse __unused *response, NSImage *image) {
        if (success) {
            success(image);
        }
    } failure:nil];
}
#endif


#if __IPHONE_OS_VERSION_MIN_REQUIRED
+ (AFImageRequestOperation *)imageRequestOperationWithRequest:(NSURLRequest *)urlRequest
                                         imageProcessingBlock:(UIImage *(^)(UIImage *))imageProcessingBlock
                                                    cacheName:(NSString *)cacheNameOrNil
                                                      success:(void (^)(NSURLRequest *request, NSHTTPURLResponse *response, UIImage *image))success
                                                      failure:(void (^)(NSURLRequest *request, NSHTTPURLResponse *response, NSError *error))failure
{
    AFImageRequestOperation *operation = [[AFImageRequestOperation alloc] initWithRequest:urlRequest];
    
    operation.completionBlock = ^ {
        if ([operation isCancelled]) {
            return;
        }
        
        dispatch_async(image_request_operation_processing_queue(), ^(void) {
            if (operation.error) {
                if (failure) {
                    dispatch_async(dispatch_get_main_queue(), ^(void) {
                        failure(operation.request, operation.response, operation.error);
                    });
                }
            } else {                
                UIImage *image = operation.responseImage;
                
                if (imageProcessingBlock) {
                    image = imageProcessingBlock(image);
                }
                
                if (success) {
                    dispatch_async(dispatch_get_main_queue(), ^(void) {
                        success(operation.request, operation.response, image);
                    });
                }
                
                if ([operation.request cachePolicy] != NSURLCacheStorageNotAllowed) {
                    [[AFImageCache sharedImageCache] cacheImageData:operation.responseData forURL:[operation.request URL] cacheName:cacheNameOrNil];
                }
            }
        });        
    };
    
    return operation;
}
#elif __MAC_OS_X_VERSION_MIN_REQUIRED 
+ (AFImageRequestOperation *)imageRequestOperationWithRequest:(NSURLRequest *)urlRequest
                                         imageProcessingBlock:(NSImage *(^)(NSImage *))imageProcessingBlock
                                                    cacheName:(NSString *)cacheNameOrNil
                                                      success:(void (^)(NSURLRequest *request, NSHTTPURLResponse *response, NSImage *image))success
                                                      failure:(void (^)(NSURLRequest *request, NSHTTPURLResponse *response, NSError *error))failure
{
    AFImageRequestOperation *operation = [[[AFImageRequestOperation alloc] initWithRequest:urlRequest] autorelease];
    
    operation.completionBlock = ^ {
        if ([operation isCancelled]) {
            return;
        }
        
        dispatch_async(image_request_operation_processing_queue(), ^(void) {
            if (operation.error) {
                if (failure) {
                    dispatch_async(dispatch_get_main_queue(), ^(void) {
                        failure(operation.request, operation.response, operation.error);
                    });
                }
            } else {                
                NSImage *image = operation.responseImage;
                
                if (imageProcessingBlock) {
                    image = imageProcessingBlock(image);
                }
                
                if (success) {
                    dispatch_async(dispatch_get_main_queue(), ^(void) {
                        success(operation.request, operation.response, image);
                    });
                }
                
                if ([operation.request cachePolicy] != NSURLCacheStorageNotAllowed) {
                    [[AFImageCache sharedImageCache] cacheImageData:operation.responseData forURL:[operation.request URL] cacheName:cacheNameOrNil];
                }
            }
        });        
    };
    
    return operation;
}
#endif

+ (NSSet *)defaultAcceptableContentTypes {
    return [NSSet setWithObjects:@"image/tiff", @"image/jpeg", @"image/gif", @"image/png", @"image/ico", @"image/x-icon" @"image/bmp", @"image/x-bmp", @"image/x-xbitmap", @"image/x-win-bitmap", nil];
}

+ (NSSet *)defaultAcceptablePathExtensions {
    return [NSSet setWithObjects:@"tif", @"tiff", @"jpg", @"jpeg", @"gif", @"png", @"ico", @"bmp", @"cur", nil];
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
  
}

#if __IPHONE_OS_VERSION_MIN_REQUIRED
- (UIImage *)responseImage {
    if (!_responseImage && [self isFinished]) {
        if ([[UIScreen mainScreen] scale] == 2.0) {
            CGImageRef imageRef = [[UIImage imageWithData:self.responseData] CGImage];
            self.responseImage = [UIImage imageWithCGImage:imageRef scale:2.0 orientation:UIImageOrientationUp];
        } else {
            self.responseImage = [UIImage imageWithData:self.responseData]; 
        }
    }
    
    return _responseImage;
}
#elif __MAC_OS_X_VERSION_MIN_REQUIRED 
- (NSImage *)responseImage {
    if (!_responseImage && [self isFinished]) {
        self.responseImage = [[[NSImage alloc] initWithData:self.responseData] autorelease];
    }
    
    return _responseImage;
}
#endif

#pragma mark - AFHTTPClientOperation

+ (BOOL)canProcessRequest:(NSURLRequest *)request {
    return [[self defaultAcceptableContentTypes] containsObject:[request valueForHTTPHeaderField:@"Accept"]] || [[self defaultAcceptablePathExtensions] containsObject:[[request URL] pathExtension]];
}

#if __IPHONE_OS_VERSION_MIN_REQUIRED
+ (AFHTTPRequestOperation *)HTTPRequestOperationWithRequest:(NSURLRequest *)urlRequest
                                                    success:(void (^)(id object))success 
                                                    failure:(void (^)(NSHTTPURLResponse *response, NSError *error))failure
{
    return [self imageRequestOperationWithRequest:urlRequest imageProcessingBlock:nil cacheName:nil success:^(NSURLRequest __unused *request, NSHTTPURLResponse __unused *response, UIImage *image) {
        success(image);
    } failure:^(NSURLRequest __unused *request, NSHTTPURLResponse *response, NSError *error) {
        failure(response, error);
    }];
}
#elif __MAC_OS_X_VERSION_MIN_REQUIRED 
+ (AFHTTPRequestOperation *)HTTPRequestOperationWithRequest:(NSURLRequest *)urlRequest
                                                    success:(void (^)(id object))success 
                                                    failure:(void (^)(NSHTTPURLResponse *response, NSError *error))failure
{
    return [self imageRequestOperationWithRequest:urlRequest imageProcessingBlock:nil cacheName:nil success:^(NSURLRequest __unused *request, NSHTTPURLResponse __unused *response, NSImage *image) {
        success(image);
    } failure:^(NSURLRequest __unused *request, NSHTTPURLResponse *response, NSError *error) {
        failure(response, error);
    }];
}
#endif

@end
