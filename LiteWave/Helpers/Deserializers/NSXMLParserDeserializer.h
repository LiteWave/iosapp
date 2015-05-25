//
//  NSXMLParserDeserializer.h
//  Client
//


#import "BaseXMLDeserializer.h"

@interface NSXMLParserDeserializer : BaseXMLDeserializer <NSXMLParserDelegate>
{
@private
    NSXMLParser *_parser;
    NSMutableArray *_array;
    NSString *_currentElement;
    NSMutableDictionary *_currentItem;
}

@end
