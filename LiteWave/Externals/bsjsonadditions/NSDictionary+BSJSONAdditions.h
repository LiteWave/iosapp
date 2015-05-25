//
//  BSJSONAdditions
//

#import <Foundation/Foundation.h>

@interface NSDictionary (BSJSONAdditions)
+ (NSDictionary *)dictionaryWithJSONString:(NSString *)jsonString;

- (NSString *)jsonStringValue;
- (NSString *)jsonStringValueWithIndentLevel:(NSInteger)level;
@end
