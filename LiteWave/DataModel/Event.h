
@class Event;
@class Event_Builder;


@interface Event : NSObject {
@private
    BOOL hasEventId_:1;
    BOOL hasEventName_:1;
    BOOL hasEventDate_:1;
    BOOL hasStadiumId_:1;
    BOOL hasClientId_:1;
    int32_t eventId;
    NSString* eventName;
    NSDate* eventDate;
    NSString* stadiumId;
    NSString* clientId;
}
- (BOOL) hasEventId;
- (BOOL) hasEventName;
- (BOOL) hasEventDate;
- (BOOL) hasStadiumId;
- (BOOL) hasClientId;
@property (readonly) int32_t eventId;
@property (readonly, retain) NSString* eventName;
@property (readonly, retain) NSDate* eventDate;
@property (readonly, retain) NSString* stadiumId;
@property (readonly, retain) NSString* clientId;

+ (Event*) defaultInstance;
- (Event*) defaultInstance;

- (BOOL) isInitialized;

- (Event_Builder*) builder;
+ (Event_Builder*) builder;
+ (Event_Builder*) builderWithPrototype:(Event*) prototype;

+ (Event*) parseFromData:(NSData*) data;
+ (Event*) parseFromInputStream:(NSInputStream*) input;

@end

@interface Event_Builder : NSObject {
@private
    Event* result;
}

- (Event*) defaultInstance;

- (Event_Builder*) clear;
- (Event_Builder*) clone;

- (Event*) build;
- (Event*) buildPartial;

- (Event_Builder*) mergeFrom:(Event*) other;

- (BOOL) hasEventId;
- (int32_t) eventId;
- (Event_Builder*) setEventId:(int32_t) value;
- (Event_Builder*) clearEventId;

- (BOOL) hasEventName;
- (NSString*) eventName;
- (Event_Builder*) setEventName:(NSString*) value;
- (Event_Builder*) clearEventName;

- (BOOL) hasEventDate;
- (NSDate*) eventDate;
- (Event_Builder*) setEventDate:(NSDate*) value;
- (Event_Builder*) clearEventDate;

- (BOOL) hasStadiumId;
- (NSString*) stadiumId;
- (Event_Builder*) setStadiumId:(NSString*) value;
- (Event_Builder*) clearStadiumId;

- (BOOL) hasClientId;
- (NSString*) clientId;
- (Event_Builder*) setClientId:(NSString*) value;
- (Event_Builder*) clearClientId;

@end

