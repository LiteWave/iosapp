// AFPropertyListRequestOperation.h
//


#import <Foundation/Foundation.h>
#import "AFHTTPRequestOperation.h"

/**
 `AFPropertyListRequestOperation` is a subclass of `AFHTTPRequestOperation` for downloading and deserializing objects with property list (plist) response data.
 
 ## Acceptable Content Types
 
 By default, `AFPropertyListRequestOperation` accepts the following MIME types:
 
 - `application/x-plist`
 */
@interface AFPropertyListRequestOperation : AFHTTPRequestOperation {
@private
    id _responsePropertyList;
    NSPropertyListFormat _propertyListFormat;
    NSPropertyListReadOptions _propertyListReadOptions;
    NSError *_propertyListError;
}

///----------------------------
/// @name Getting Response Data
///----------------------------

/**
 An object deserialized from a plist constructed using the response data.
 */
@property (readonly, nonatomic, retain) id responsePropertyList;

///--------------------------------------
/// @name Managing Property List Behavior
///--------------------------------------

/**
 One of the `NSPropertyListMutabilityOptions` options, specifying the mutability of objects deserialized from the property list. By default, this is `NSPropertyListImmutable`.
 */
@property (nonatomic, assign) NSPropertyListReadOptions propertyListReadOptions;

/**
 Creates and returns an `AFPropertyListRequestOperation` object and sets the specified success and failure callbacks.
 
 @param urlRequest The request object to be loaded asynchronously during execution of the operation
 @param success A block object to be executed when the operation finishes successfully. This block has no return value and takes three arguments: the request sent from the client, the response received from the server, and the object deserialized from a plist constructed using the response data.
 @param failure A block object to be executed when the operation finishes unsuccessfully, or that finishes successfully, but encountered an error while deserializing the object from a property list. This block has no return value and takes three arguments: the request sent from the client, the response received from the server, and the error describing the network or parsing error that occurred.
 
 @return A new property list request operation
 */
+ (AFPropertyListRequestOperation *)propertyListRequestOperationWithRequest:(NSURLRequest *)request
                                                                    success:(void (^)(NSURLRequest *request, NSHTTPURLResponse *response, id propertyList))success
                                                                    failure:(void (^)(NSURLRequest *request, NSHTTPURLResponse *response, NSError *error))failure;

@end
