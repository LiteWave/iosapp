//
//  CJSONSerializer.m
//  Client
//


#import "CJSONSerializer.h"

#import "CJSONDataSerializer.h"

@implementation CJSONSerializer

+ (id)serializer
{
return([[self alloc] init]);
}

- (id)init
{
if ((self = [super init]) != NULL)
	{
	serializer = [[CJSONDataSerializer alloc] init];
	}
return(self);
}

- (void)dealloc
{
//[serializer release];
serializer = NULL;
//
//[super dealloc];
}

- (NSString *)serializeObject:(id)inObject;
{
NSData *theData = [serializer serializeObject:inObject];
return([[NSString alloc] initWithData:theData encoding:NSUTF8StringEncoding]);
}

- (NSString *)serializeArray:(NSArray *)inArray
{
NSData *theData = [serializer serializeArray:inArray];
return([[NSString alloc] initWithData:theData encoding:NSUTF8StringEncoding]);
}

- (NSString *)serializeDictionary:(NSDictionary *)inDictionary;
{
NSData *theData = [serializer serializeDictionary:inDictionary];
return([[NSString alloc] initWithData:theData encoding:NSUTF8StringEncoding]);
}
@end
