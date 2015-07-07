//
//  BSJSONAdditions
//


#import "NSDictionary+BSJSONAdditions.h"
#import "NSScanner+BSJSONAdditions.h"
#import "NSString+BSJSONAdditions.h"
#import "BSJSONEncoder.h"

@implementation NSDictionary (BSJSONAdditions)

+ (NSDictionary *)dictionaryWithJSONString:(NSString *)jsonString
{
	NSScanner *scanner = [[NSScanner alloc] initWithString:jsonString];
	NSDictionary *dictionary = nil;
	[scanner scanJSONObject:&dictionary];

	return dictionary;
}

- (NSString *)jsonStringValue
{
    return [self jsonStringValueWithIndentLevel:0];
}

- (NSString *)jsonStringValueWithIndentLevel:(NSInteger)level
{
	NSMutableString *jsonString = [[NSMutableString alloc] initWithString:jsonObjectStartString];
	
  BOOL first = YES;
	NSString *valueString;
  for (NSString *keyString in self) {
    valueString = [BSJSONEncoder jsonStringForValue:[self objectForKey:keyString] withIndentLevel:level];
    if (!first) {
      [jsonString appendString:jsonValueSeparatorString];
    }
    if (level != jsonDoNotIndent) { // indent before each key
      [jsonString appendString:[NSString jsonIndentStringForLevel:level]];
    }
    [jsonString appendFormat:@" %@ %@ %@", [keyString jsonStringValue], jsonKeyValueSeparatorString, valueString];
    first = NO;
  }
	
	[jsonString appendString:jsonObjectEndString];
	return jsonString;
}

@end
