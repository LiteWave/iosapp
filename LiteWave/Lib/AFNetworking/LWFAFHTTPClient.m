// AFHTTPClient.m
//


#import <Foundation/Foundation.h>

#import "LWFAFHTTPClient.h"
#import "LWFAFHTTPRequestOperation.h"

#import <Availability.h>

#if __IPHONE_OS_VERSION_MIN_REQUIRED
#import <UIKit/UIKit.h>
#endif

#import "LWFJSONKit.h"

static NSString * const kLWFAFMultipartFormLineDelimiter = @"\r\n"; // CRLF
static NSString * const kLWFAFMultipartFormBoundary = @"Boundary+0xAbCdEfGbOuNdArY";

@interface LWFAFMultipartFormData : NSObject <LWFAFMultipartFormData> {
@private
    NSStringEncoding _stringEncoding;
    NSMutableData *_mutableData;
}

@property (readonly) NSData *data;

- (id)initWithStringEncoding:(NSStringEncoding)encoding;

@end

#pragma mark -

static NSUInteger const kLWFAFHTTPClientDefaultMaxConcurrentOperationCount = 4;

static NSString * LWFAFBase64EncodedStringFromString(NSString *string) {
    NSData *data = [NSData dataWithBytes:[string UTF8String] length:[string length]];
    NSUInteger length = [data length];
    NSMutableData *mutableData = [NSMutableData dataWithLength:((length + 2) / 3) * 4];
    
    uint8_t *input = (uint8_t *)[data bytes];
    uint8_t *output = (uint8_t *)[mutableData mutableBytes];
    
    for (NSUInteger i = 0; i < length; i += 3) {
        NSUInteger value = 0;
        for (NSUInteger j = i; j < (i + 3); j++) {
            value <<= 8;
            if (j < length) {
                value |= (0xFF & input[j]); 
            }
        }
        
        static uint8_t const kAFBase64EncodingTable[] = "ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789+/";

        NSUInteger idx = (i / 3) * 4;
        output[idx + 0] = kAFBase64EncodingTable[(value >> 18) & 0x3F];
        output[idx + 1] = kAFBase64EncodingTable[(value >> 12) & 0x3F];
        output[idx + 2] = (i + 1) < length ? kAFBase64EncodingTable[(value >> 6)  & 0x3F] : '=';
        output[idx + 3] = (i + 2) < length ? kAFBase64EncodingTable[(value >> 0)  & 0x3F] : '=';
    }
    
    return [[NSString alloc] initWithData:mutableData encoding:NSASCIIStringEncoding];
}

static NSURL * LWFAFURLWithPathRelativeToURL(NSString *path, NSURL *baseURL) {
    if (!path) {
        return baseURL;
    }
    
    NSURL *url = [baseURL URLByAppendingPathComponent:[path stringByTrimmingCharactersInSet:[NSCharacterSet characterSetWithCharactersInString:@"/"]]];
    NSString *URLString = [url absoluteString];
    if ([path hasSuffix:@"/"]) {
        URLString = [URLString stringByAppendingString:@"/"];
    }
    
    return [NSURL URLWithString:URLString];
}

static NSString * LWFAFURLEncodedStringFromString(NSString *string) {
    static NSString * const kAFLegalCharactersToBeEscaped = @"?!@#$^&%*+,:;='\"`<>()[]{}/\\|~ ";
    
	return (NSString *)CFBridgingRelease(CFURLCreateStringByAddingPercentEscapes(kCFAllocatorDefault, (CFStringRef)string, NULL, (CFStringRef)kAFLegalCharactersToBeEscaped, CFStringConvertNSStringEncodingToEncoding(NSUTF8StringEncoding)));
}

static NSString * LWFAFQueryStringFromParameters(NSDictionary *parameters) {
    NSMutableArray *mutableParameterComponents = [NSMutableArray array];
    for (id key in [parameters allKeys]) {
        NSString *component = [NSString stringWithFormat:@"%@=%@", LWFAFURLEncodedStringFromString([key description]), LWFAFURLEncodedStringFromString([[parameters valueForKey:key] description])];
        [mutableParameterComponents addObject:component];
    }
    
    return [mutableParameterComponents componentsJoinedByString:@"&"];
}

static NSString * LWFAFJSONStringFromParameters(NSDictionary *parameters) {
    NSString *JSONString = nil;
    
#if __IPHONE_OS_VERSION_MIN_REQUIRED > __IPHONE_4_3 || __MAC_OS_X_VERSION_MIN_REQUIRED > __MAC_10_6
    if ([NSJSONSerialization class]) {
        NSError *error = nil;
        NSData *JSONData = [NSJSONSerialization dataWithJSONObject:parameters options:0 error:&error];
        if (!error) {
            JSONString = [[NSString alloc] initWithData:JSONData encoding:NSUTF8StringEncoding];
        }
    } else {
        JSONString = [parameters JSONString];
    }
#else
    JSONString = [parameters JSONString];
#endif

    return JSONString;
}

static NSString * LWFAFPropertyListStringFromParameters(NSDictionary *parameters) {
    NSString *propertyListString = nil;
    NSError *error = nil;
    
    NSData *propertyListData = [NSPropertyListSerialization dataWithPropertyList:parameters format:NSPropertyListXMLFormat_v1_0 options:0 error:&error];
    if (!error) {
        propertyListString = [[NSString alloc] initWithData:propertyListData encoding:NSUTF8StringEncoding];
    }
    
    return propertyListString;
}

@interface LWFAFHTTPClient ()
@property (readwrite, nonatomic, retain) NSURL *baseURL;
@property (readwrite, nonatomic, retain) NSMutableArray *registeredHTTPOperationClassNames;
@property (readwrite, nonatomic, retain) NSMutableDictionary *defaultHeaders;
@property (readwrite, nonatomic, retain) NSOperationQueue *operationQueue;
@end

@implementation LWFAFHTTPClient
@synthesize baseURL = _baseURL;
@synthesize stringEncoding = _stringEncoding;
@synthesize parameterEncoding = _parameterEncoding;
@synthesize registeredHTTPOperationClassNames = _registeredHTTPOperationClassNames;
@synthesize defaultHeaders = _defaultHeaders;
@synthesize operationQueue = _operationQueue;

+ (LWFAFHTTPClient *)clientWithBaseURL:(NSURL *)url {
    return [[self alloc] initWithBaseURL:url];
}

- (id)initWithBaseURL:(NSURL *)url {
    self = [super init];
    if (!self) {
        return nil;
    }
    
    self.baseURL = url;
    
    self.stringEncoding = NSUTF8StringEncoding;
    self.parameterEncoding = LWFAFFormURLParameterEncoding;
	
    self.registeredHTTPOperationClassNames = [NSMutableArray array];
    
	self.defaultHeaders = [NSMutableDictionary dictionary];
    
	// Accept-Encoding HTTP Header; see http://www.w3.org/Protocols/rfc2616/rfc2616-sec14.html#sec14.3
	[self setDefaultHeader:@"Accept-Encoding" value:@"gzip"];
	
	// Accept-Language HTTP Header; see http://www.w3.org/Protocols/rfc2616/rfc2616-sec14.html#sec14.4
	NSString *preferredLanguageCodes = [[NSLocale preferredLanguages] componentsJoinedByString:@", "];
	[self setDefaultHeader:@"Accept-Language" value:[NSString stringWithFormat:@"%@, en-us;q=0.8", preferredLanguageCodes]];

#if __IPHONE_OS_VERSION_MIN_REQUIRED
    // User-Agent Header; see http://www.w3.org/Protocols/rfc2616/rfc2616-sec14.html#sec14.43
    [self setDefaultHeader:@"User-Agent" value:[NSString stringWithFormat:@"%@/%@ (%@, %@ %@, %@, Scale/%f)", [[[NSBundle mainBundle] infoDictionary] objectForKey:(NSString *)kCFBundleIdentifierKey], [[[NSBundle mainBundle] infoDictionary] objectForKey:(NSString *)kCFBundleVersionKey], @"unknown", [[UIDevice currentDevice] systemName], [[UIDevice currentDevice] systemVersion], [[UIDevice currentDevice] model], ([[UIScreen mainScreen] respondsToSelector:@selector(scale)] ? [[UIScreen mainScreen] scale] : 1.0)]];
#elif __MAC_OS_X_VERSION_MIN_REQUIRED
    [self setDefaultHeader:@"User-Agent" value:[NSString stringWithFormat:@"%@/%@ (%@)", [[[NSBundle mainBundle] infoDictionary] objectForKey:(NSString *)kCFBundleIdentifierKey], [[[NSBundle mainBundle] infoDictionary] objectForKey:(NSString *)kCFBundleVersionKey], @"unknown"]];
#endif
    
    self.operationQueue = [[NSOperationQueue alloc] init];
	[self.operationQueue setMaxConcurrentOperationCount:kLWFAFHTTPClientDefaultMaxConcurrentOperationCount];
    
    return self;
}

- (void)dealloc {

}

#pragma mark -

- (BOOL)registerHTTPOperationClass:(Class)operationClass {
    if (![operationClass conformsToProtocol:@protocol(LWFAFHTTPClientOperation)]) {
        return NO;
    }
    
    NSString *className = NSStringFromClass(operationClass);
    [self.registeredHTTPOperationClassNames removeObject:className];
    [self.registeredHTTPOperationClassNames insertObject:className atIndex:0];
    
    return YES;
}

- (void)unregisterHTTPOperationClass:(Class)operationClass {
    NSString *className = NSStringFromClass(operationClass);
    [self.registeredHTTPOperationClassNames removeObject:className];
}

#pragma mark -

- (NSString *)defaultValueForHeader:(NSString *)header {
	return [self.defaultHeaders valueForKey:header];
}

- (void)setDefaultHeader:(NSString *)header value:(NSString *)value {
	[self.defaultHeaders setValue:value forKey:header];
}

- (void)setAuthorizationHeaderWithUsername:(NSString *)username password:(NSString *)password {
	NSString *basicAuthCredentials = [NSString stringWithFormat:@"%@:%@", username, password];
    [self setDefaultHeader:@"Authorization" value:[NSString stringWithFormat:@"Basic %@", LWFAFBase64EncodedStringFromString(basicAuthCredentials)]];
}

- (void)setAuthorizationHeaderWithToken:(NSString *)token {
    [self setDefaultHeader:@"Authorization" value:[NSString stringWithFormat:@"Token token=\"%@\"", token]];
}

- (void)clearAuthorizationHeader {
	[self.defaultHeaders removeObjectForKey:@"Authorization"];
}

#pragma mark -

- (NSMutableURLRequest *)requestWithMethod:(NSString *)method 
                                      path:(NSString *)path 
                                parameters:(NSDictionary *)parameters 
{	
    NSURL *url = LWFAFURLWithPathRelativeToURL(path, self.baseURL);
	NSMutableURLRequest *request = [[NSMutableURLRequest alloc] initWithURL:url];
    [request setHTTPMethod:method];
    [request setAllHTTPHeaderFields:self.defaultHeaders];
	
    if (parameters) {        
        if ([method isEqualToString:@"GET"]) {
            url = [NSURL URLWithString:[[url absoluteString] stringByAppendingFormat:[path rangeOfString:@"?"].location == NSNotFound ? @"?%@" : @"&%@", LWFAFQueryStringFromParameters(parameters)]];
            [request setURL:url];
        } else {
            NSString *charset = (NSString *)CFStringConvertEncodingToIANACharSetName(CFStringConvertNSStringEncodingToEncoding(self.stringEncoding));
            switch (self.parameterEncoding) {
                case LWFAFFormURLParameterEncoding:;
                    [request setValue:[NSString stringWithFormat:@"application/x-www-form-urlencoded; charset=%@", charset] forHTTPHeaderField:@"Content-Type"];
                    [request setHTTPBody:[LWFAFQueryStringFromParameters(parameters) dataUsingEncoding:self.stringEncoding]];
                    break;
                case LWFAFJSONParameterEncoding:;
                    [request setValue:[NSString stringWithFormat:@"application/json; charset=%@", charset] forHTTPHeaderField:@"Content-Type"];
                    [request setHTTPBody:[LWFAFJSONStringFromParameters(parameters) dataUsingEncoding:self.stringEncoding]];
                    break;
                case LWFAFPropertyListParameterEncoding:;
                    [request setValue:[NSString stringWithFormat:@"application/x-plist; charset=%@", charset] forHTTPHeaderField:@"Content-Type"];
                    [request setHTTPBody:[LWFAFPropertyListStringFromParameters(parameters) dataUsingEncoding:self.stringEncoding]];
                    break;
            }
        }
    }
    
	return request;
}

- (NSMutableURLRequest *)multipartFormRequestWithMethod:(NSString *)method
                                                   path:(NSString *)path
                                             parameters:(NSDictionary *)parameters
                              constructingBodyWithBlock:(void (^)(id <LWFAFMultipartFormData>formData))block
{
    if (!([method isEqualToString:@"POST"] || [method isEqualToString:@"PUT"] || [method isEqualToString:@"DELETE"])) {
        [NSException raise:@"Invalid HTTP Method" format:@"%@ is not supported for multipart form requests; must be either POST, PUT, or DELETE", method];
        return nil;
    }
    
    NSMutableURLRequest *request = [self requestWithMethod:method path:path parameters:nil];
    __block LWFAFMultipartFormData *formData = [[LWFAFMultipartFormData alloc] initWithStringEncoding:self.stringEncoding];
    
    id key = nil;
	NSEnumerator *enumerator = [parameters keyEnumerator];
	while ((key = [enumerator nextObject])) {
        id value = [parameters valueForKey:key];
        NSData *data = nil;
        
        if ([value isKindOfClass:[NSData class]]) {
            data = value;
        } else {
            data = [[value description] dataUsingEncoding:self.stringEncoding];
        }
        
        [formData appendPartWithFormData:data name:[key description]];
    }
    
    if (block) {
        block(formData);
    }
    
    [request setValue:[NSString stringWithFormat:@"multipart/form-data; boundary=%@", kLWFAFMultipartFormBoundary] forHTTPHeaderField:@"Content-Type"];
    [request setHTTPBody:[formData data]];
    

    
    return request;
}

- (void)enqueueHTTPRequestOperationWithRequest:(NSURLRequest *)urlRequest 
                                       success:(void (^)(id object))success 
                                       failure:(void (^)(NSHTTPURLResponse *response, NSError *error))failure 
{
    LWFAFHTTPRequestOperation *operation = nil;
    NSString *className = nil;
    NSEnumerator *enumerator = [self.registeredHTTPOperationClassNames reverseObjectEnumerator];
    while (!operation && (className = [enumerator nextObject])) {
        Class class = NSClassFromString(className);
        if (class && [class canProcessRequest:urlRequest]) {
            operation = [class HTTPRequestOperationWithRequest:urlRequest success:success failure:failure];
        }
    }
    
    if (!operation) {
        operation = [LWFAFHTTPRequestOperation HTTPRequestOperationWithRequest:urlRequest success:success failure:failure];
    }
       
    [self enqueueHTTPRequestOperation:operation];
}

- (void)enqueueHTTPRequestOperation:(LWFAFHTTPRequestOperation *)operation {
    [self.operationQueue addOperation:operation];
}

- (void)cancelHTTPOperationsWithMethod:(NSString *)method andURL:(NSURL *)url {
    for (LWFAFHTTPRequestOperation *operation in [self.operationQueue operations]) {
        if ([[[operation request] HTTPMethod] isEqualToString:method] && [[[operation request] URL] isEqual:url]) {
            [operation cancel];
        }
    }
}

#pragma mark -

- (void)getPath:(NSString *)path 
     parameters:(NSDictionary *)parameters 
        success:(void (^)(id object))success 
        failure:(void (^)(NSHTTPURLResponse *response, NSError *error))failure 
{
	NSURLRequest *request = [self requestWithMethod:@"GET" path:path parameters:parameters];
	[self enqueueHTTPRequestOperationWithRequest:request success:success failure:failure];
}

- (void)postPath:(NSString *)path 
      parameters:(NSDictionary *)parameters 
         success:(void (^)(id object))success 
         failure:(void (^)(NSHTTPURLResponse *response, NSError *error))failure 
{
	NSURLRequest *request = [self requestWithMethod:@"POST" path:path parameters:parameters];
	[self enqueueHTTPRequestOperationWithRequest:request success:success failure:failure];
}

- (void)putPath:(NSString *)path 
     parameters:(NSDictionary *)parameters 
        success:(void (^)(id object))success 
        failure:(void (^)(NSHTTPURLResponse *response, NSError *error))failure 
{
	NSURLRequest *request = [self requestWithMethod:@"PUT" path:path parameters:parameters];
	[self enqueueHTTPRequestOperationWithRequest:request success:success failure:failure];
}

- (void)deletePath:(NSString *)path 
        parameters:(NSDictionary *)parameters 
           success:(void (^)(id object))success 
           failure:(void (^)(NSHTTPURLResponse *response, NSError *error))failure 
{
	NSURLRequest *request = [self requestWithMethod:@"DELETE" path:path parameters:parameters];
	[self enqueueHTTPRequestOperationWithRequest:request success:success failure:failure];
}

@end

#pragma mark -

static inline NSString * LWFAFMultipartFormEncapsulationBoundary() {
    return [NSString stringWithFormat:@"%@--%@%@", kLWFAFMultipartFormLineDelimiter, kLWFAFMultipartFormBoundary, kLWFAFMultipartFormLineDelimiter];
}

static inline NSString * LWFAFMultipartFormFinalBoundary() {
    return [NSString stringWithFormat:@"%@--%@--", kLWFAFMultipartFormLineDelimiter, kLWFAFMultipartFormBoundary];
}

@interface LWFAFMultipartFormData ()
@property (readwrite, nonatomic, assign) NSStringEncoding stringEncoding;
@property (readwrite, nonatomic, retain) NSMutableData *mutableData;
@end

@implementation LWFAFMultipartFormData
@synthesize stringEncoding = _stringEncoding;
@synthesize mutableData = _mutableData;

- (id)initWithStringEncoding:(NSStringEncoding)encoding {
    self = [super init];
    if (!self) {
        return nil;
    }
    
    self.stringEncoding = encoding;
    self.mutableData = [NSMutableData dataWithLength:0];
    
    return self;
}

- (void)dealloc {
  
}

- (NSData *)data {
    NSMutableData *finalizedData = [NSMutableData dataWithData:self.mutableData];
    [finalizedData appendData:[LWFAFMultipartFormFinalBoundary() dataUsingEncoding:self.stringEncoding]];
    return finalizedData;
}

#pragma mark - LWFAFMultipartFormData

- (void)appendPartWithHeaders:(NSDictionary *)headers body:(NSData *)body {
    [self appendString:LWFAFMultipartFormEncapsulationBoundary()];
    
    for (NSString *field in [headers allKeys]) {
        [self appendString:[NSString stringWithFormat:@"%@: %@%@", field, [headers valueForKey:field], kLWFAFMultipartFormLineDelimiter]];
    }
    
    [self appendString:kLWFAFMultipartFormLineDelimiter];
    [self appendData:body];
}

- (void)appendPartWithFormData:(NSData *)data name:(NSString *)name {
    NSMutableDictionary *mutableHeaders = [NSMutableDictionary dictionary];
    [mutableHeaders setValue:[NSString stringWithFormat:@"form-data; name=\"%@\"", name] forKey:@"Content-Disposition"];
    
    [self appendPartWithHeaders:mutableHeaders body:data];
}

- (void)appendPartWithFileData:(NSData *)data mimeType:(NSString *)mimeType name:(NSString *)name {
    NSString *fileName = [[NSString stringWithFormat:@"%@-%d", name, [[NSDate date] hash]] stringByAppendingPathExtension:[mimeType lastPathComponent]];
    
    NSMutableDictionary *mutableHeaders = [NSMutableDictionary dictionary];
    [mutableHeaders setValue:[NSString stringWithFormat:@"file; name=\"%@\"; filename=\"%@\"", name, fileName] forKey:@"Content-Disposition"];
    [mutableHeaders setValue:mimeType forKey:@"Content-Type"];
    
    [self appendPartWithHeaders:mutableHeaders body:data];
}

- (void)appendData:(NSData *)data {
    [self.mutableData appendData:data];
}

- (void)appendString:(NSString *)string {
    [self appendData:[string dataUsingEncoding:self.stringEncoding]];
}

@end
