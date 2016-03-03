// AFImageCache.m
//


#import "LWFAFImageCache.h"

static inline NSString * AFImageCacheKeyFromURLAndCacheName(NSURL *url, NSString *cacheName) {
    return [[url absoluteString] stringByAppendingFormat:@"#%@", cacheName];
}

@implementation LWFAFImageCache

+ (LWFAFImageCache *)sharedImageCache {
    static LWFAFImageCache *_sharedImageCache = nil;
    static dispatch_once_t oncePredicate;

    dispatch_once(&oncePredicate, ^{
        _sharedImageCache = [[self alloc] init];
    });
    
    return _sharedImageCache;
}

#if __IPHONE_OS_VERSION_MIN_REQUIRED
- (UIImage *)cachedImageForURL:(NSURL *)url
                     cacheName:(NSString *)cacheName
{
    return [UIImage imageWithData:[self objectForKey:AFImageCacheKeyFromURLAndCacheName(url, cacheName)]];
}
#elif __MAC_OS_X_VERSION_MIN_REQUIRED
- (NSImage *)cachedImageForURL:(NSURL *)url
                     cacheName:(NSString *)cacheName
{
    return [[[NSImage alloc] initWithData:[self objectForKey:AFImageCacheKeyFromURLAndCacheName(url, cacheName)]] autorelease];
}
#endif

- (void)cacheImageData:(NSData *)imageData
                forURL:(NSURL *)url
             cacheName:(NSString *)cacheName
{
    [self setObject:[NSPurgeableData dataWithData:imageData] forKey:AFImageCacheKeyFromURLAndCacheName(url, cacheName)];
}

@end
