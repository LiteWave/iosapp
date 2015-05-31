//
//  BaseDataLoader.m
//  Client
//


#import "BaseDataLoader.h"
#import "NSURLConnectionDataLoader.h"
#import "NSUserDefaults+Extensions.h"
#import "AFNetworkingDataLoader.h"

@implementation BaseDataLoader

@synthesize deserializer = _deserializer;
@synthesize data = _data;
@synthesize delegate = _delegate;
@synthesize url = _url;
@synthesize error = _error;
@synthesize interval = _interval;
@synthesize baseURLString = _baseURLString;
@synthesize limit = _limit;

+ (id<DataLoader>)loaderWithMechanism:(LoaderMechanism)mechanism
{
    BaseDataLoader *loader = nil;
    switch (mechanism) 
    {
        case LoaderMechanismNSURLConnection:
        {
            loader = [NSURLConnectionDataLoader loader];
            break;
        }
            
        case LoaderMechanismAFNetworking:
        {
            loader = [AFNetworkingDataLoader loader];
            break;
        }

        default:
            break;
    }
    return loader;
}

+ (id<DataLoader>)loader
{
    return [[[self class] alloc] init];
}

- (id)init
{
    self = [super init];
    if (self)
    {
        self.limit = 300;
        //NSString *baseURL = [NSUserDefaults standardUserDefaults].serverURL;
        //self.baseURLString = [NSString stringWithFormat:@"%@", baseURL];
    }
    return self;
}

- (void)dealloc
{
    self.baseURLString = nil;
    self.error = nil;
    self.delegate = nil;
    self.deserializer = nil;
    self.data = nil;
    self.url = nil;
  
}

- (void)loadData
{
    NSString *format = [self.deserializer formatIdentifier];
    //NSString *urlString = [NSString stringWithFormat:@"%@?format=%@&limit=%d", self.baseURLString, format, self.limit];
    //self.url = [NSURL URLWithString:urlString];
    self.interval = [NSDate timeIntervalSinceReferenceDate];
    
    // Template method, to be overridden by subclasses
    [self performAsynchronousLoading];
}

- (void)performAsynchronousLoading
{
}

- (void)ready
{
    // This method must be called by subclasses at the end of the
    // asynchronous network call
    self.interval = [NSDate timeIntervalSinceReferenceDate] - self.interval;
    if (self.deserializer.isAsynchronous)
    {
        self.deserializer.delegate = self;
        [self.deserializer startDeserializing:self.data];
    }
    else
    {
        NSArray *array = [self.deserializer deserializeData:self.data];
        [self.delegate dataLoader:self didLoadData:array];
    }
}

#pragma mark -
#pragma mark DeserializerDelegate methods

- (void)deserializer:(id<Deserializer>)deserializer didFinishDeserializing:(NSArray *)array
{
    [self.delegate dataLoader:self didLoadData:array];
}

@end
