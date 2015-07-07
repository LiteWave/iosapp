
@class User;
@class User_Builder;


@interface User : NSObject {
@private
    BOOL hasEventId_:1;
    BOOL hasUserKey_:1;
    BOOL hasUserSeat_:1;
    BOOL hasLogicalRow_:1;
    BOOL hasLogicalCol_:1;
    int32_t eventId;
    NSString* userKey;
    NSDictionary* userSeat;
    NSNumber* logicalRow;
    NSNumber* logicalCol;
}
- (BOOL) hasEventId;
- (BOOL) hasUserKey;
- (BOOL) hasUserSeat;
- (BOOL) hasLogicalRow;
- (BOOL) hasLogicalCol;
@property (readonly) int32_t eventId;
@property (readonly, retain) NSString* userKey;
@property (readonly, retain) NSDictionary* userSeat;
@property (readonly, retain) NSNumber* logicalRow;
@property (readonly, retain) NSNumber* logicalCol;

+ (User*) defaultInstance;
- (User*) defaultInstance;

- (BOOL) isInitialized;

- (User_Builder*) builder;
+ (User_Builder*) builder;
+ (User_Builder*) builderWithPrototype:(User*) prototype;

+ (User*) parseFromData:(NSData*) data;
+ (User*) parseFromInputStream:(NSInputStream*) input;

@end

@interface User_Builder : NSObject {
@private
    User* result;
}

- (User*) defaultInstance;

- (User_Builder*) clear;
- (User_Builder*) clone;

- (User*) build;
- (User*) buildPartial;

- (User_Builder*) mergeFrom:(User*) other;

- (BOOL) hasEventId;
- (int32_t) eventId;
- (User_Builder*) setEventId:(int32_t) value;
- (User_Builder*) clearEventId;

- (BOOL) hasUserKey;
- (NSString*) userKey;
- (User_Builder*) setUserKey:(NSString*) value;
- (User_Builder*) clearUserKey;

- (BOOL) hasUserSeat;
- (NSDictionary*) userSeat;
- (User_Builder*) setUserSeat:(NSDictionary*) value;
- (User_Builder*) clearUserSeat;

- (BOOL) hasLogicalRow;
- (NSNumber*) logicalRow;
- (User_Builder*) setLogicalRow:(NSNumber*) value;
- (User_Builder*) clearLogicalRow;

- (BOOL) hasLogicalCol;
- (NSNumber*) logicalCol;
- (User_Builder*) setLogicalCol:(NSNumber*) value;
- (User_Builder*) clearLogicalCol;

@end

