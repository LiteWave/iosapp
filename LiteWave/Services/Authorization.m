//
//  Authorization.m
//

#import "Authorization.h"

@interface Authorization (PrivateMethods)
+(void) installPlistTemplateIfNeeded;
+(NSString*) pathToPlistFile;
+(NSDictionary*) readPlistFile;

+(id) readValueInPlistFileForKey:(NSString*)key;
+(void) writeToPlistFileKey:(NSString*)key value:(id)value;
@end

@implementation Authorization

+(void) deleteAuthorization {
	// Delete cookies for the web view
	NSHTTPCookie *cookie;
	NSHTTPCookieStorage *storage = [NSHTTPCookieStorage sharedHTTPCookieStorage];

	for (cookie in [storage cookies]) {
		[storage deleteCookie:cookie];
	}
	
	[self writeToPlistFileKey:@"cookies" value:[NSArray array]];
}

#pragma mark -
#pragma mark Cookies Management

+(void) setCookies:(NSArray*)cookies {
	[self writeToPlistFileKey:@"cookies" value:cookies];
}

+(NSArray*) cookies {
	return (NSArray*)[self readValueInPlistFileForKey:@"cookies"];
}

#pragma mark -
#pragma mark Private API - read and write of the values in the plist file

+(id) readValueInPlistFileForKey:(NSString*)key {
	return [[self readPlistFile] valueForKey:key];
}

+(void) writeToPlistFileKey:(NSString*)key value:(id)value {
	NSDictionary *plist = [self readPlistFile];
	[plist setValue:value forKey:key];
	[plist writeToFile:[self pathToPlistFile] atomically:NO];
	
#ifdef DEBUG_PLIST_WRITES
	NSLog(@"[PList] Saving %@ to %@", key, value);
#endif
}

#pragma mark -
#pragma mark Private API - plist file management

+(void) installPlistTemplateIfNeeded {
    if (![[NSFileManager defaultManager] fileExistsAtPath:[self pathToPlistFile]]) {
        NSString *plistTemplatePath = [[NSBundle mainBundle] pathForResource:@"Authorization" ofType:@"plist"];
        if (plistTemplatePath) {
            [[NSFileManager defaultManager] copyItemAtPath:plistTemplatePath toPath:[self pathToPlistFile] error:NULL];
        }	
    }
}

/**
 Returns the URL to the application's Documents directory.
 */
- (NSURL *)applicationDocumentsDirectory
{
    NSArray *searchPaths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentPath = [searchPaths lastObject];
    
    return [NSURL fileURLWithPath:documentPath];
}

//+ (NSString *)pathToPlistFile {
//	return [[self applicationDocumentsDirectory] stringByAppendingPathComponent:@"Authorization.plist"];
//}

+(NSDictionary*) readPlistFile {
	[self installPlistTemplateIfNeeded];
    NSMutableDictionary* plistDict = [[NSMutableDictionary alloc] initWithContentsOfFile:[self pathToPlistFile]];
	return plistDict;
}

@end
