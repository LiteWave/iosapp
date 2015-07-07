//
//  CSerializedJSONData.h
//  Client
//


#import <Foundation/Foundation.h>

@interface CSerializedJSONData : NSObject {
	NSData *data;
}

@property (readonly, nonatomic, retain) NSData *data;

- (id)initWithData:(NSData *)inData;

@end
