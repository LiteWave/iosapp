//
//  NSString+BSJSONAdditions.h
//  BSJSONAdditions
//

#import <Foundation/Foundation.h>


@interface NSString (BSJSONAdditions)

+ (NSString *)jsonIndentStringForLevel:(NSInteger)level;
- (NSString *)jsonStringValue;

@end
