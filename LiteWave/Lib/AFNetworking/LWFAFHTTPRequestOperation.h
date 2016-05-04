// AFHTTPOperation.h
//


#import <Foundation/Foundation.h>
#import "LWFAFURLConnectionOperation.h"
#import "LWFAFHTTPClient.h"

/**
 `AFHTTPRequestOperation` is a subclass of `AFURLConnectionOperation` for requests using the HTTP or HTTPS protocols. It encapsulates the concept of acceptable status codes and content types, which determine the success or failure of a request.
 */
@interface LWFAFHTTPRequestOperation : LWFAFURLConnectionOperation <LWFAFHTTPClientOperation> {
@private
    NSIndexSet *_acceptableStatusCodes;
    NSSet *_acceptableContentTypes;
    NSError *_HTTPError;
}

///----------------------------------------------
/// @name Getting HTTP URL Connection Information
///----------------------------------------------

/**
 The last HTTP response received by the operation's connection.
 */
@property (readonly, nonatomic, retain) NSHTTPURLResponse *response;


///----------------------------------------------------------
/// @name Managing And Checking For Acceptable HTTP Responses
///----------------------------------------------------------

/**
 Returns an `NSIndexSet` object containing the ranges of acceptable HTTP status codes. When non-`nil`, the operation will set the `error` property to an error in `AFErrorDomain`. See http://www.w3.org/Protocols/rfc2616/rfc2616-sec10.html
 
 By default, this is the range 200 to 299, inclusive.
 */
@property (nonatomic, retain) NSIndexSet *acceptableStatusCodes;

/**
 A Boolean value that corresponds to whether the status code of the response is within the specified set of acceptable status codes. Returns `YES` if `acceptableStatusCodes` is `nil`.
 */
@property (readonly) BOOL hasAcceptableStatusCode;

/**
 Returns an `NSSet` object containing the acceptable MIME types. When non-`nil`, the operation will set the `error` property to an error in `AFErrorDomain`. See http://www.w3.org/Protocols/rfc2616/rfc2616-sec14.html#sec14.17 
 
 By default, this is `nil`.
 */
@property (nonatomic, retain) NSSet *acceptableContentTypes;

/**
 A Boolean value that corresponds to whether the MIME type of the response is among the specified set of acceptable content types. Returns `YES` if `acceptableContentTypes` is `nil`.
 */
@property (readonly) BOOL hasAcceptableContentType;

@end
