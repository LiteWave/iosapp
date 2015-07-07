//
//  BSJSONAdditions
//


#import <Foundation/Foundation.h>

extern NSString *jsonObjectStartString;
extern NSString *jsonObjectEndString;
extern NSString *jsonArrayStartString;
extern NSString *jsonArrayEndString;
extern NSString *jsonKeyValueSeparatorString;
extern NSString *jsonValueSeparatorString;
extern NSString *jsonStringDelimiterString;
extern NSString *jsonStringEscapedDoubleQuoteString;
extern NSString *jsonStringEscapedSlashString;
extern NSString *jsonTrueString;
extern NSString *jsonFalseString;
extern NSString *jsonNullString;
extern NSString *jsonIndentString;
extern const NSInteger jsonDoNotIndent;


@interface NSScanner (PrivateBSJSONAdditions)

- (BOOL)scanJSONObject:(NSDictionary **)dictionary;
- (BOOL)scanJSONArray:(NSArray **)array;
- (BOOL)scanJSONString:(NSString **)string;
- (BOOL)scanJSONValue:(id *)value;
- (BOOL)scanJSONNumber:(NSNumber **)number;

- (BOOL)scanJSONWhiteSpace;
- (BOOL)scanJSONKeyValueSeparator;
- (BOOL)scanJSONValueSeparator;
- (BOOL)scanJSONObjectStartString;
- (BOOL)scanJSONObjectEndString;
- (BOOL)scanJSONArrayStartString;
- (BOOL)scanJSONArrayEndString;
- (BOOL)scanJSONStringDelimiterString;

- (BOOL)scanUnicodeCharacterIntoString:(NSMutableString *)string;

@end
