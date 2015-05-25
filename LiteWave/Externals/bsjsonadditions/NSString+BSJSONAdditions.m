//
//  NSString+BSJSONAdditions.m
//  BSJSONAdditions
//


#import "NSScanner+BSJSONAdditions.h"
#import "NSString+BSJSONAdditions.h"

@implementation NSString (BSJSONAdditions)

+ (NSString *)jsonIndentStringForLevel:(NSInteger)level
{
  if (level != jsonDoNotIndent) {
    return [@"\n" stringByPaddingToLength:(level + 1) withString:jsonIndentString startingAtIndex:0];
  } else {
    return @"";
  }
}

- (NSString *)jsonStringValue
{
	NSMutableString *jsonString = [[NSMutableString alloc] init];
	[jsonString appendString:jsonStringDelimiterString];
	
	// Build the result one character at a time, inserting escaped characters as necessary
	NSInteger i;
	unichar nextChar;
	for (i = 0; i < [self length]; i++) {
		nextChar = [self characterAtIndex:i];
		switch (nextChar) {
			case '\"':
				[jsonString appendString:@"\\\""];
				break;
			case '\\':
				[jsonString appendString:@"\\\\"];
				break;
			case '/':
				[jsonString appendString:@"\\/"];
				break;
			case '\b':
				[jsonString appendString:@"\\b"];
				break;
			case '\f':
				[jsonString appendString:@"\\f"];
				break;
			case '\n':
				[jsonString appendString:@"\\n"];
				break;
			case '\r':
				[jsonString appendString:@"\\r"];
				break;
			case '\t':
				[jsonString appendString:@"\\t"];
				break;
      /* TODO: Find and encode unicode characters here?
      case '\u':
        [jsonString appendString:@"\\n"];
        break;
        */
			default:
				[jsonString appendFormat:@"%c", nextChar];
				break;
		}
	}
	[jsonString appendString:jsonStringDelimiterString];
	
	return jsonString;
}

@end
