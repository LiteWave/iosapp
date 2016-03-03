

#import "NSObject+LWFSBJSON.h"
#import "LWFSBJsonWriter.h"

@implementation NSObject (NSObject_LWFSBJSON)

- (NSString *)JSONFragment {
    LWFSBJsonWriter *jsonWriter = [LWFSBJsonWriter new];
    NSString *json = [jsonWriter stringWithFragment:self];    
    if (!json)
        NSLog(@"-JSONFragment failed. Error trace is: %@", [jsonWriter errorTrace]);
   
    return json;
}

- (NSString *)JSONRepresentation {
    LWFSBJsonWriter *jsonWriter = [LWFSBJsonWriter new];    
    NSString *json = [jsonWriter stringWithObject:self];
    if (!json)
        NSLog(@"-JSONRepresentation failed. Error trace is: %@", [jsonWriter errorTrace]);
   
    return json;
}

@end
