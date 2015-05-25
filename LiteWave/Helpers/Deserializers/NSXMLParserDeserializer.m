//
//  NSXMLParserDeserializer.m
//  Client
//


#import "NSXMLParserDeserializer.h"

@interface NSXMLParserDeserializer ()
@property (nonatomic, retain) NSXMLParser *parser;
@property (nonatomic, retain) NSMutableArray *array;
@property (nonatomic, copy) NSString *currentElement;
@property (nonatomic, retain) NSMutableDictionary *currentItem;
@end

@implementation NSXMLParserDeserializer

@synthesize parser = _parser;
@synthesize array = _array;
@synthesize currentElement = _currentElement;
@synthesize currentItem = _currentItem;

- (id)init
{
    if (self = [super init])
    {
        self.isAsynchronous = YES;
    }
    return self;
}

- (void)dealloc
{
    self.array = nil;
    self.parser = nil;
    
    self.currentElement = nil;
    self.currentItem = nil;
    
}

- (void)startDeserializing:(id)data
{
    [self startTimer];
    self.parser = [[NSXMLParser alloc] initWithData:data];
    self.array = [NSMutableArray array];

    [self.parser setDelegate:self];
    [self.parser setShouldProcessNamespaces:NO];
    [self.parser setShouldReportNamespacePrefixes:NO];
    [self.parser setShouldResolveExternalEntities:NO];
    [self.parser parse];
}

#pragma mark -
#pragma mark NSXMLParserDelegate methods

- (void)parser:(NSXMLParser *)parser didStartElement:(NSString *)elementName 
  namespaceURI:(NSString *)namespaceURI 
 qualifiedName:(NSString *)qName 
    attributes:(NSDictionary *)attributeDict
{
	self.currentElement = [elementName copy];
    
    if ([self.currentElement isEqualToString:@"person"])
    {
        self.currentItem = [NSMutableDictionary dictionary];
    }
}

- (void)parser:(NSXMLParser *)parser didEndElement:(NSString *)elementName 
  namespaceURI:(NSString *)namespaceURI 
 qualifiedName:(NSString *)qName
{
    if ([elementName isEqualToString:@"person"]) 
    {
        [self.array addObject:self.currentItem];
        self.currentItem = nil;
    }
}

- (void)parser:(NSXMLParser *)parser foundCharacters:(NSString *)string
{
    NSMutableString *field = [self.currentItem objectForKey:self.currentElement];
    if (field == nil)
    {
        field = [NSMutableString string];
        [self.currentItem setObject:field forKey:self.currentElement];
    }
    [field appendString:string];
}

- (void)parserDidEndDocument:(NSXMLParser *)parser 
{
    [self stopTimer];
    if ([self.delegate respondsToSelector:@selector(deserializer:didFinishDeserializing:)])
    {
        [self.delegate deserializer:self didFinishDeserializing:self.array];
    }
}

@end
