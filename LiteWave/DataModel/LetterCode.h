

@interface LetterCode : NSObject {
	NSArray *letterKeys;
}

@property (nonatomic, retain) NSArray *letterKeys;

- (void)setupMorse:(NSArray *)inputString;
- (id)init;

@end
