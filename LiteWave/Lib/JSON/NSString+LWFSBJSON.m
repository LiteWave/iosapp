

#import "NSString+LWFSBJSON.h"
#import "LWFSBJsonParser.h"

@implementation NSString (NSString_LWFSBJSON)

- (id)JSONFragmentValue
{
    LWFSBJsonParser *jsonParser = [LWFSBJsonParser new];    
    id repr = [jsonParser fragmentWithString:self];    
    if (!repr)
        NSLog(@"-JSONFragmentValue failed. Error trace is: %@", [jsonParser errorTrace]);
   
    return repr;
}

- (id)JSONValue
{
    LWFSBJsonParser *jsonParser = [LWFSBJsonParser new];
    id repr = [jsonParser objectWithString:self];
    if (!repr)
        NSLog(@"-JSONValue failed. Error trace is: %@", [jsonParser errorTrace]);
   
    return repr;
}

@end
