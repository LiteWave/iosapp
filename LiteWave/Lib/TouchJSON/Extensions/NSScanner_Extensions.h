//
//  NSScanner_Extensions.h
//  Client
//


#import <Foundation/Foundation.h>

@interface NSScanner (NSScanner_Extensions)

- (NSString *)remainingString;

- (unichar)currentCharacter;
- (unichar)scanCharacter;
- (BOOL)scanCharacter:(unichar)inCharacter;
- (void)backtrack:(unsigned)inCount;

- (BOOL)scanCStyleComment:(NSString **)outComment;
- (BOOL)scanCPlusPlusStyleComment:(NSString **)outComment;

@end
