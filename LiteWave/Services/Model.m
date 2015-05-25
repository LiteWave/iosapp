//
//  Model.m
//


#import "Model.h"
#import "Authorization.h"

static WebServiceRequest *allRequest;
static WebServiceRequest *firstRequest;
static id<ModelDelegate> allDelegate;
static id<ModelDelegate> firstDelegate;

@interface Model (PrivateMethods)
+(NSString*) getCompletePath:(NSNumber*)objectId;
@end

@implementation NSString (NSString_Extended)

- (NSString *)stringByUrlEncoding {
    NSMutableString *output = [NSMutableString string];
    const unsigned char *source = (const unsigned char *)[self UTF8String];
    int sourceLen = strlen((const char *)source);
    for (int i = 0; i < sourceLen; ++i) {
        const unsigned char thisChar = source[i];
        if (thisChar == ' '){
            [output appendString:@"+"];
        } else if (thisChar == '.' || thisChar == '-' || thisChar == '_' || thisChar == '~' ||
                   (thisChar >= 'a' && thisChar <= 'z') ||
                   (thisChar >= 'A' && thisChar <= 'Z') ||
                   (thisChar >= '0' && thisChar <= '9')) {
            [output appendFormat:@"%c", thisChar];
        } else {
            [output appendFormat:@"%%%02X", thisChar];
        }
    }
    return output;
}

@end

@implementation Model

@synthesize detailsRequest, objectId, gotDetailsDelegate, refreshRequest, refreshDelegate;

#pragma mark -
#pragma mark Methods to be overriden

// to be overriden
-(id) initWithJson:(NSDictionary*)json {
	if ((self = [super init])) {
		[self updateModelWithJson:json];
#ifdef DEBUG_MODEL_OBJECTS_CREATIONS
		NSLog(@"%@ object created from json data: %@", [self class], json);
#endif
	}
    return self;
}

// to be overriden
+(NSString*) getPath {
    NSLog(@"[Model] !! path not defined. Declare the method +(NSString*) getPath to set the path to your resource.");
    return @"/";
}

-(void) addDetailsWithJson:(NSDictionary*)json {
	[self updateModelWithJson:json];
}

// to be overidden
-(void) updateModelWithJson:(NSDictionary*)json {
	NSLog(@"[Model] updateModelWithJson: method not overriden. JSON data not being saved: %@", json);
}

#pragma mark -
#pragma mark Finders

+(void)getAllFromPath:(NSString*)path delegate:(id)delegate {
	[self getAllFromPath:path delegate:delegate withHud:YES];
}

+(void)getAllFromPath:(NSString*)path delegate:(id)delegate withHud:(BOOL)displayHud {
    [self cancelAll]; // Cancel current all request if it happens
    WebServiceRequest *request = [[WebServiceRequest alloc] initGetWithPath:path delegate:self];
    allRequest = request;
    
    allDelegate = delegate;
}

+(void)getAllFromPath:(NSString*)path withParameters:(NSDictionary*)params delegate:(id)delegate {
	[self getAllFromPath:path withParameters:params delegate:delegate withHud:YES];
}

+(void)getAllFromPath:(NSString*)path withParameters:(NSDictionary*)params delegate:(id)delegate withHud:(BOOL)displayHud {
    NSMutableArray *paramsTokens = [[NSMutableArray alloc] init];
    
    for (NSString *key in [params allKeys]) {
        [paramsTokens addObject:[NSString stringWithFormat:@"%@=%@",
                                 [key stringByUrlEncoding],
                                 [[params valueForKey:key] stringByUrlEncoding]]];
    }
    
    NSString *paramsAsString = [paramsTokens componentsJoinedByString:@"&"];
	
    NSString *completePath = [NSString stringWithFormat:@"%@?%@", path, paramsAsString];
    
    [self getAllFromPath:completePath delegate:delegate withHud:displayHud];
}

+(void)getAllWithParameters:(NSDictionary*)params delegate:(id)delegate {
	[self getAllFromPath:[self getCompletePath:nil] withParameters:params delegate:delegate];
}

+(void)getAllWithParameters:(NSDictionary*)params delegate:(id)delegate withHud:(BOOL)displayHud {
	[self getAllFromPath:[self getCompletePath:nil] withParameters:params delegate:delegate withHud:displayHud];
}

+(void)getAllWithDelegate:(id)delegate withHud:(BOOL)displayHud {
    [self getAllFromPath:[self getCompletePath:nil] delegate:delegate withHud:displayHud];
}

+(void)getAllWithDelegate:(id<ModelDelegate>)delegate {
    [self getAllFromPath:[self getCompletePath:nil] delegate:delegate];
}

+(void)cancelAll {
    if (allRequest!=nil) {
        allRequest.delegate = nil;
        allRequest = nil;
    }
    allDelegate = nil;
}

#pragma mark -
#pragma mark First

+(void)firstWithId:(int)objectId withDelegate:(id)delegate {
	[self firstWithPath:[self getCompletePath:[NSNumber numberWithInt:objectId]] withDelegate:delegate];
}

+(void)firstWithPath:(NSString*)path withDelegate:(id)delegate {
	  WebServiceRequest *request = [[WebServiceRequest alloc] initGetWithPath:path delegate:self];
    firstRequest = request;
    
    firstDelegate = delegate;    	
}

+(void)cancelFirst {
    if (firstRequest!=nil) {
        firstRequest.delegate = nil;
        firstRequest = nil;
    }
    firstDelegate = nil;
}


+(id<ModelDelegate>)firstDelegate {
	return firstDelegate;
}

+(void)setFirstDelegate:(id<ModelDelegate>)newFirstDelegate {
	firstDelegate = newFirstDelegate;
}

+(id<ModelDelegate>)allDelegate {
	return allDelegate;
}

+(void)setAllDelegate:(id<ModelDelegate>)newAllDelegate{
	allDelegate = newAllDelegate;    
}

#pragma mark -
#pragma mark Get Details

-(void)getDetailsWithDelegate:(id)delegate {
    WebServiceRequest *request = [[WebServiceRequest alloc] initGetWithPath:[[self class] getCompletePath:self.objectId] delegate:self];
    self.detailsRequest = request;
    self.gotDetailsDelegate = delegate;
}

#pragma mark -
#pragma mark Refresh

-(void)refreshWithDelegate:(id<ModelDelegate>)delegate {
	[self refreshWithPath:[[self class] getCompletePath:self.objectId] withDelegate:delegate withHud:YES];
}

-(void)refreshWithPath:(NSString*)path withDelegate:(id<ModelDelegate>)delegate {
	[self refreshWithPath:path withDelegate:delegate withHud:YES];
}

-(void)refreshWithPath:(NSString*)path withDelegate:(id<ModelDelegate>)delegate withHud:(BOOL)displayHud {
    WebServiceRequest *request = [[WebServiceRequest alloc] initGetWithPath:path delegate:self];
    self.refreshRequest = request;
    self.refreshDelegate = delegate;
}

#pragma mark -
#pragma mark Helpers

+(NSString*) getCompletePath:(NSNumber*)objectId{
    if (objectId) {
        return  [NSString stringWithFormat:@"%@/%@.json",[self getPath],objectId];
    } else {
        return [NSString stringWithFormat:@"%@.json",[self getPath]];
    }
}

#pragma mark -
#pragma mark JSON Delegate Methods

+ (void) jsonDidFinishLoading:(NSDictionary*)json jsonRequest:(WebServiceRequest*)request {
    if (request == allRequest) {
        allRequest = nil;

    		if ([json isKindOfClass:[NSDictionary class]] && [json valueForKey:@"error"]) {
    			NSLog(@"[Model] Error getting all objects. Response is: %@", json);
    			return;
    		}
		
        NSMutableArray *array = [[NSMutableArray alloc] init];
        for (NSDictionary *attributes in json) {
            Model *object = [[self alloc] initWithJson:attributes];
            [array addObject:object];
        
        }
        
        if (allDelegate!=nil) {
            [allDelegate all:[self class] objects:array];
        } else {
            
        }
    }

	if (request == firstRequest) {
		firstRequest = nil;

		if ([json isKindOfClass:[NSDictionary class]] && [json valueForKey:@"error"]) {
			NSLog(@"[Model] Error getting all objects. Response is: %@", json);
			return;
		}

		Model *object = [[self alloc] initWithJson:json];
		if (firstDelegate!=nil) {
			[firstDelegate first:object];

		}
	}
}

+ (void) jsonDidFailWithError:(NSError*)error jsonRequest:(WebServiceRequest*)request {
    if (request==allRequest)
        allRequest = nil;
    NSLog(@"[Model] Request failed with error %@", error);
}

- (void) jsonDidFinishLoading:(NSDictionary*)json jsonRequest:(WebServiceRequest*)request {
    if (request == detailsRequest){
        [self addDetailsWithJson:json];

		if ([json isKindOfClass:[NSDictionary class]] && [json valueForKey:@"error"]) {
			if ([[json valueForKey:@"error"] isEqualToString:@"not_authenticated"]) {
        // Do something ?
			}
			NSLog(@"[Model] Error getting all objects. Response is: %@", json);
			return;
		}
		
        if (gotDetailsDelegate!=nil)
            [gotDetailsDelegate modelGotDetails:self];
    }

	if (request == refreshRequest) {
		[self updateModelWithJson:json];

		if ([json isKindOfClass:[NSDictionary class]] && [json valueForKey:@"error"]) {
			if ([[json valueForKey:@"error"] isEqualToString:@"not_authenticated"]) {
        // Do something ?
			}
			NSLog(@"[Model] Error getting all objects. Response is: %@", json);
			return;
		}		
		
		if (refreshDelegate!=nil)
			[refreshDelegate modelUpdated:self];
	}
	
}

- (void) jsonDidFailWithError:(NSError*)error jsonRequest:(WebServiceRequest*)request {
    NSLog(@"[Model] JSON failed with error %@", error);
}


-(void)dealloc{
    if (detailsRequest!=nil) { detailsRequest.delegate = nil; }
    detailsRequest = nil;
    
    if (refreshRequest!=nil) { refreshRequest.delegate = nil; }
    refreshRequest = nil;
	
    objectId = nil;
    
}

@end
