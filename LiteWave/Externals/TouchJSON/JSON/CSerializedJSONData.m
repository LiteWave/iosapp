//
//  CSerializedJSONData.m
//  Client
//


#import "CSerializedJSONData.h"

@implementation CSerializedJSONData

@synthesize data;

- (id)initWithData:(NSData *)inData;
{
if ((self = [self init]) != NULL)
	{
	data = inData;
	}
return(self);
}

- (void)dealloc
{

data = NULL;

}


@end
