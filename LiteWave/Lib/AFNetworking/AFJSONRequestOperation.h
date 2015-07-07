// AFJSONRequestOperation.h
//


#import <Foundation/Foundation.h>
#import "AFHTTPRequestOperation.h"

/**
 `AFJSONRequestOperation` is a subclass of `AFHTTPRequestOperation` for downloading and working with JSON response data.
 
 ## Acceptable Content Types
 
 By default, `AFJSONRequestOperation` accepts the following MIME types, which includes the official standard, `application/json`, as well as other commonly-used types:
 
 - `application/json`
 - `text/json`
 */
@interface AFJSONRequestOperation : AFHTTPRequestOperation {
@private
    id _responseJSON;
    NSError *_JSONError;
}

///----------------------------
/// @name Getting Response Data
///----------------------------

/**
 A JSON object constructed from the response data. If an error occurs while parsing, `nil` will be returned, and the `error` property will be set to the error.
 */
@property (readonly, nonatomic, retain) id responseJSON;

///----------------------------------
/// @name Creating Request Operations
///----------------------------------

/**
 Creates and returns an `AFJSONRequestOperation` object and sets the specified success and failure callbacks.
 
 @param urlRequest The request object to be loaded asynchronously during execution of the operation
 @param success A block object to be executed when the operation finishes successfully. This block has no return value and takes three arguments: the request sent from the client, the response received from the server, and the JSON object created from the response data of request.
 @param failure A block object to be executed when the operation finishes unsuccessfully, or that finishes successfully, but encountered an error while parsing the resonse data as JSON. This block has no return value and takes three arguments: the request sent from the client, the response received from the server, and the error describing the network or parsing error that occurred.
  
 @return A new JSON request operation
 */
+ (AFJSONRequestOperation *)JSONRequestOperationWithRequest:(NSURLRequest *)urlRequest
                                                    success:(void (^)(NSURLRequest *request, NSHTTPURLResponse *response, id JSON))success
                                                    failure:(void (^)(NSURLRequest *request, NSHTTPURLResponse *response, NSError *error))failure;
@end
