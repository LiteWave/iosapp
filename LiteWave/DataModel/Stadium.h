
@class Stadium;
@class Stadium_Builder;


@interface Stadium : NSObject {
@private
    BOOL hasEntryId_:1;
    BOOL hasName_:1;
    BOOL hasSections_:1;
    int32_t entryId;
    NSString* name;
    NSDictionary* sections;
}
- (BOOL) hasEntryId;
- (BOOL) hasName;
- (BOOL) hasSections;
@property (readonly) int32_t entryId;
@property (readonly, retain) NSString* name;
@property (readonly, retain) NSDictionary* sections;

+ (Stadium*) defaultInstance;
- (Stadium*) defaultInstance;

- (BOOL) isInitialized;

- (Stadium_Builder*) builder;
+ (Stadium_Builder*) builder;
+ (Stadium_Builder*) builderWithPrototype:(Stadium*) prototype;

+ (Stadium*) parseFromData:(NSData*) data;
+ (Stadium*) parseFromInputStream:(NSInputStream*) input;

@end

@interface Stadium_Builder : NSObject {
@private
    Stadium* result;
}

- (Stadium*) defaultInstance;

- (Stadium_Builder*) clear;
- (Stadium_Builder*) clone;

- (Stadium*) build;
- (Stadium*) buildPartial;

- (Stadium_Builder*) mergeFrom:(Stadium*) other;

- (BOOL) hasEntryId;
- (int32_t) entryId;
- (Stadium_Builder*) setEntryId:(int32_t) value;
- (Stadium_Builder*) clearEntryId;

- (BOOL) hasName;
- (NSString*) name;
- (Stadium_Builder*) setName:(NSString*) value;
- (Stadium_Builder*) clearName;

- (BOOL) hasSections;
- (NSDictionary*) sections;
- (Stadium_Builder*) setSections:(NSDictionary*) value;
- (Stadium_Builder*) clearSections;
@end

