//
//  NSURLConnectionDataLoader.h
//  Client
//


#import "BaseDataLoader.h"

@interface NSURLConnectionDataLoader : BaseDataLoader 
{
@private
    NSMutableData *_receivedData;
    NSURLConnection *_connection;
}

@end
