

@interface AudioCode : NSObject {
	NSArray *audioKeys;
}

@property (nonatomic, retain) NSArray *audioKeys;

- (void)setupMorse:(NSArray *)inputString;
- (id)init;

@end
