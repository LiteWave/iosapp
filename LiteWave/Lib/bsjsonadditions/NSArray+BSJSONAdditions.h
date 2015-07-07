//
//  BSJSONAdditions
//

#import <Foundation/Foundation.h>

#import "NSDictionary+BSJSONAdditions.h"

@interface NSArray (BSJSONAdditions)

+ (NSArray *)arrayWithJSONString:(NSString *)jsonString;
- (NSString *)jsonStringValue;
- (NSString *)jsonStringValueWithIndentLevel:(NSInteger)level;

@end
