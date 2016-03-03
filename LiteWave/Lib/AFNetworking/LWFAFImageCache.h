// AFImageCache.h
//


#import <Foundation/Foundation.h>
#import "LWFAFImageRequestOperation.h"

#import <Availability.h>

/**
 `AFImageCache` is an `NSCache` that stores and retrieves images from cache.
 
 @discussion `AFImageCache` is used to cache images for successful `AFImageRequestOperations` with the proper cache policy.
 */
@interface LWFAFImageCache : NSCache

/**
 Returns the shared image cache object for the system.
 
 @return The systemwide image cache.
 */
+ (LWFAFImageCache *)sharedImageCache;

/**
 Returns the image associated with a given URL and cache name.
 
 @param url The URL associated with the image in the cache.
 @param cacheName The cache name associated with the image in the cache. This allows for multiple versions of an image to be associated for a single URL, such as image thumbnails, for instance.
 
 @return The image associated with the URL and cache name, or `nil` if not image exists.
 */

#if __IPHONE_OS_VERSION_MIN_REQUIRED
- (UIImage *)cachedImageForURL:(NSURL *)url
                     cacheName:(NSString *)cacheName;
#elif __MAC_OS_X_VERSION_MIN_REQUIRED
- (NSImage *)cachedImageForURL:(NSURL *)url
                     cacheName:(NSString *)cacheName;
#endif

/**
 Stores image data into cache, associated with a given URL and cache name.
 
 @param imageData The image data to be stored in cache.
 @param url The URL to be associated with the image.
 @param cacheName The cache name to be associated with the image in the cache. This allows for multiple versions of an image to be associated for a single URL, such as image thumbnails, for instance.
 */
- (void)cacheImageData:(NSData *)imageData
                forURL:(NSURL *)url
             cacheName:(NSString *)cacheName;

@end
