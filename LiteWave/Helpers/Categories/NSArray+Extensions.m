//
//  NSArray+Extensions.m
//  Client
//


#import "NSArray+Extensions.h"

@implementation NSArray (Extensions)

- (NSData *)formattedAsCSV
{
    NSMutableString *text = [NSMutableString string];
    BOOL headerDone = NO;
    for (NSDictionary *dict in self)
    {
        if (!headerDone)
        {
            headerDone = YES;
            for (NSString *key in dict)
            {
                [text appendFormat:@"%@, ", key];
            }            
            [text appendString:@"\n"];
        }
        for (NSString *key in dict)
        {
            id value = [dict objectForKey:key];
            [text appendFormat:@"%@, ", [value description]];
        }
        [text appendString:@"\n"];
    }
    return [text dataUsingEncoding:NSUTF8StringEncoding];
}

@end
