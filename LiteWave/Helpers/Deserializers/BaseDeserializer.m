//
//  BaseDeserializer.m
//  Client
//


#import "BaseDeserializer.h"
#import "TouchJSONDeserializer.h"
#import "SBJSONDeserializer.h"
#import "BinaryPlistDeserializer.h"
#import "XMLPlistDeserializer.h"
#import "XMLFormattedPlistDeserializer.h"
#import "NSXMLParserDeserializer.h"
#import "JSONKitDeserializer.h"
#import "BSJSONDeserializer.h"
#import "NSJSONSerializationDeserializer.h"

@implementation BaseDeserializer

@synthesize interval = _interval;
@synthesize isAsynchronous = _isAsynchronous;
@synthesize delegate = _delegate;

+ (id<Deserializer>)deserializerForFormat:(DeserializerType)format
{
    id<Deserializer> deserializer = nil;
    switch (format) 
    {
        case DeserializerTypeTouchJSON:
        {
            deserializer = [TouchJSONDeserializer deserializer];
            break;
        }
            
        case DeserializerTypeSBJSON:
        {
            deserializer = [SBJSONDeserializer deserializer];
            break;
        }

        case DeserializerTypeJSONKit:
        {
            deserializer = [JSONKitDeserializer deserializer];
            break;
        }
            
        case DeserializerTypeBSJSON:
        {
            deserializer = [BSJSONDeserializer deserializer];
            break;
        }
            
            
        case DeserializerTypeNSJSONSerialization:
        {
            deserializer = [NSJSONSerializationDeserializer deserializer];
            break;
        }
            
            
        case DeserializerTypeBinaryPlist:
        {
            deserializer = [BinaryPlistDeserializer deserializer];
            break;
        }
            
        case DeserializerTypeXMLPlist:
        {
            deserializer = [XMLPlistDeserializer deserializer];
            break;
        }
            
        case DeserializerTypeXMLFormattedPlist:
        {
            deserializer = [XMLFormattedPlistDeserializer deserializer];
            break;
        }
            
            
        case DeserializerTypeNSXMLParser:
        {
            deserializer = [NSXMLParserDeserializer deserializer];
            break;
        }
            
            

        default:
            break;
    }
    return deserializer;
}

+ (id<Deserializer>)deserializer
{
    id<Deserializer> obj = [[[self class] alloc] init];
    return obj;
}

- (id)init
{
    self = [super init];
    if (self)
    {
        self.isAsynchronous = NO;
    }
    return self;
}

- (NSArray *)deserializeData:(NSData *)data
{
    [self startTimer];
    NSArray *result = [self performDeserialization:data];
    [self stopTimer];
    return result;
}

- (NSArray *)performDeserialization:(NSData *)data
{
    return nil;
}

- (NSString *)formatIdentifier
{
    return nil;
}

- (void)startDeserializing:(NSData *)data
{
}

- (void)startTimer
{
    self.interval = [NSDate timeIntervalSinceReferenceDate];
}

- (void)stopTimer
{
    self.interval = [NSDate timeIntervalSinceReferenceDate] - self.interval;
}

@end
