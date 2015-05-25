//  BSJSONAdditions
//


#import "NSArray+BSJSONAdditions.h"
#import "NSScanner+BSJSONAdditions.h"
#import "BSJSONEncoder.h"

@implementation NSArray (BSJSONAdditions)

+ (NSArray *)arrayWithJSONString:(NSString *)jsonString
{
	NSScanner *scanner = [[NSScanner alloc] initWithString:jsonString];
	NSArray *array = nil;
	[scanner scanJSONArray:&array];
	
	
	return array;
}

- (NSString *)jsonStringValue
{
	return [self jsonStringValueWithIndentLevel:0];
}

- (NSString *)jsonStringValueWithIndentLevel:(NSInteger)level
{
	NSMutableString *jsonString = [[NSMutableString alloc] init];
	[jsonString appendString:jsonArrayStartString];
	
	if ([self count] > 0) {
		[jsonString appendString:[BSJSONEncoder jsonStringForValue:[self objectAtIndex:0] withIndentLevel:level]];
	}
	
	NSInteger i;
  NSString *encoded;
	for (i = 1; i < [self count]; i++) {
    encoded = [BSJSONEncoder jsonStringForValue:[self objectAtIndex:i] withIndentLevel:level];
		[jsonString appendFormat:@"%@ %@", jsonValueSeparatorString, encoded];
	}
	
	[jsonString appendString:jsonArrayEndString];
	return jsonString;
}

@end
