// UIImageView+AFNetworking.m
//


#import <Foundation/Foundation.h>
#import <objc/runtime.h>

#if __IPHONE_OS_VERSION_MIN_REQUIRED

#import "UIImageView+LWFAFNetworking.h"

#import "LWFAFImageCache.h"

static char kAFImageRequestOperationObjectKey;

@interface UIImageView (_LWFAFNetworking)
@property (readwrite, nonatomic, retain, setter = af_setImageRequestOperation:) LWFAFImageRequestOperation *af_imageRequestOperation;
@end

@implementation UIImageView (_LWFAFNetworking)
@dynamic af_imageRequestOperation;
@end

#pragma mark -

@implementation UIImageView (AFNetworking)

- (LWFAFHTTPRequestOperation *)af_imageRequestOperation {
    return (LWFAFHTTPRequestOperation *)objc_getAssociatedObject(self, &kAFImageRequestOperationObjectKey);
}

- (void)af_setImageRequestOperation:(LWFAFImageRequestOperation *)imageRequestOperation {
    objc_setAssociatedObject(self, &kAFImageRequestOperationObjectKey, imageRequestOperation, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

+ (NSOperationQueue *)af_sharedImageRequestOperationQueue {
    static NSOperationQueue *_imageRequestOperationQueue = nil;
    
    if (!_imageRequestOperationQueue) {
        _imageRequestOperationQueue = [[NSOperationQueue alloc] init];
        [_imageRequestOperationQueue setMaxConcurrentOperationCount:8];
    }
    
    return _imageRequestOperationQueue;
}

#pragma mark -

- (void)setImageWithURL:(NSURL *)url {
    [self setImageWithURL:url placeholderImage:nil];
}

- (void)setImageWithURL:(NSURL *)url 
       placeholderImage:(UIImage *)placeholderImage
{
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:url cachePolicy:NSURLCacheStorageAllowed timeoutInterval:30.0];
    [request setHTTPShouldHandleCookies:NO];
    [request setHTTPShouldUsePipelining:YES];
    
    [self setImageWithURLRequest:request placeholderImage:placeholderImage success:nil failure:nil];
}

- (void)setImageWithURLRequest:(NSURLRequest *)urlRequest 
              placeholderImage:(UIImage *)placeholderImage 
                       success:(void (^)(NSURLRequest *request, NSHTTPURLResponse *response, UIImage *image))success
                       failure:(void (^)(NSURLRequest *request, NSHTTPURLResponse *response, NSError *error))failure
{
    if (![urlRequest URL] || (![self.af_imageRequestOperation isCancelled] && [[urlRequest URL] isEqual:[[self.af_imageRequestOperation request] URL]])) {
        return;
    } else {
        [self cancelImageRequestOperation];
    }
    
    UIImage *cachedImage = [[LWFAFImageCache sharedImageCache] cachedImageForURL:[urlRequest URL] cacheName:nil];
    if (cachedImage) {
        self.image = cachedImage;
        self.af_imageRequestOperation = nil;
        
        if (success) {
            success(nil, nil, cachedImage);
        }
    } else {
        self.image = placeholderImage;
        
        self.af_imageRequestOperation = [LWFAFImageRequestOperation imageRequestOperationWithRequest:urlRequest imageProcessingBlock:nil cacheName:nil success:^(NSURLRequest *request, NSHTTPURLResponse *response, UIImage *image) {
            if (self.af_imageRequestOperation && ![self.af_imageRequestOperation isCancelled]) {
                if (success) {
                    success(request, response, image);
                }
            
                if ([[request URL] isEqual:[[self.af_imageRequestOperation request] URL]]) {
                    self.image = image;
                } else {
                    self.image = placeholderImage;
                }
            }            
        } failure:^(NSURLRequest *request, NSHTTPURLResponse *response, NSError *error) {
            self.af_imageRequestOperation = nil;
            
            if (failure) {
                failure(request, response, error);
            } 
        }];
       
        [[[self class] af_sharedImageRequestOperationQueue] addOperation:self.af_imageRequestOperation];
    }
}

- (void)cancelImageRequestOperation {
    [self.af_imageRequestOperation cancel];
}

@end
#endif
