//
//  CJSONDeserializer.m
//  Client
//


#import "CJSONDeserializer.h"

#import "CJSONScanner.h"
#import "CDataScanner.h"

NSString *const kJSONDeserializerErrorDomain  = @"CJSONDeserializerErrorDomain";

@implementation CJSONDeserializer

+ (id)deserializer
{
return([[self alloc] init]);
}

- (id)deserialize:(NSData *)inData error:(NSError **)outError
{
if (inData == NULL || [inData length] == 0)
	{
	if (outError)
		*outError = [NSError errorWithDomain:kJSONDeserializerErrorDomain code:-1 userInfo:NULL];

	return(NULL);
	}
CJSONScanner *theScanner = [CJSONScanner scannerWithData:inData];
id theObject = NULL;
if ([theScanner scanJSONObject:&theObject error:outError] == YES)
	return(theObject);
else
	return(NULL);
}

- (id)deserializeAsDictionary:(NSData *)inData error:(NSError **)outError;
{
if (inData == NULL || [inData length] == 0)
	{
	if (outError)
		*outError = [NSError errorWithDomain:kJSONDeserializerErrorDomain code:-1 userInfo:NULL];

	return(NULL);
	}
CJSONScanner *theScanner = [CJSONScanner scannerWithData:inData];
NSDictionary *theDictionary = NULL;
if ([theScanner scanJSONDictionary:&theDictionary error:outError] == YES)
	return(theDictionary);
else
	return(NULL);
}

- (id)deserializeAsArray:(NSData *)inData error:(NSError **)outError;
{
if (inData == NULL || [inData length] == 0)
	{
	if (outError)
		*outError = [NSError errorWithDomain:kJSONDeserializerErrorDomain code:-1 userInfo:NULL];

	return(NULL);
	}
CJSONScanner *theScanner = [CJSONScanner scannerWithData:inData];
NSArray *theArray = NULL;
if ([theScanner scanJSONArray:&theArray error:outError] == YES)
	return(theArray);
else
	return(NULL);
}

@end
