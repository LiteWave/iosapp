
#import "AudioCode.h"


@implementation AudioCode

@synthesize audioKeys;

- (id)init {
	if (self = [super init]) {
		[self setupMorse:nil];
    }
	
    return self;
}

- (void)setupMorse:(NSArray *)inputString {
	audioKeys = [NSArray arrayWithObjects:
					   @"a", // .-
					   @"b", // -...
					   @"c", // -.-.
					   @"d", // -..
					   @"e", // .
					   @"f", // ..-.
					   @"g", // --.
					   @"h", // ....
					   @"i", // ..
					   @"j", // .---
					   @"k", // -.-
					   @"l", // .-..
					   @"m", // --
					   @"n", // -.
					   @"o", // ---
					   @"p", // .--.
					   @"q", // --.-
					   @"r", // .-.
					   @"s", // ...
					   @"t", // -
					   @"u", // ..-
					   @"v", // ...-
					   @"w", // .--
					   @"x", // -..-
					   @"y", // -.--
					   @"z", // --..
					   @"0", // -----
					   @"1", // .----
					   @"2", // ..---
					   @"3", // ...--
					   @"4", // ....-
					   @"5", // .....
					   @"6", // -....
					   @"7", // --...
					   @"8", // ---..
					   @"9", // ----.
					   @".", // .-.-.-
					   @",", // --..--
					   @"?", // ..--..
					   @"!", // .----.
					   nil];
}
@end
