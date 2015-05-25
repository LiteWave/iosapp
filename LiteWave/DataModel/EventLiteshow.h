
@class EventLiteshow;
@class EventLiteshow_Builder;


@interface EventLiteshow : NSObject {
@private
    BOOL hasShowId_:1;
    BOOL hasEventId_:1;
    BOOL hasStartDate_:1;
    BOOL hasWinnerId_:1;
    int32_t lightshowId;
    NSString* eventId;
    NSDate* startDate;
    NSString* winnerId;

}
- (BOOL) hasShowId;
- (BOOL) hasEventId;
- (BOOL) hasStartDate;
- (BOOL) hasWinnerId;

@property (readonly) int32_t showId;
@property (readonly, retain) NSString* eventId;
@property (readonly, retain) NSDate* startDate;
@property (readonly, retain) NSString* winnerId;

+ (EventLiteshow*) defaultInstance;
- (EventLiteshow*) defaultInstance;

- (BOOL) isInitialized;

- (EventLiteshow_Builder*) builder;
+ (EventLiteshow_Builder*) builder;
+ (EventLiteshow_Builder*) builderWithPrototype:(EventLiteshow*) prototype;

+ (EventLiteshow*) parseFromData:(NSData*) data;
+ (EventLiteshow*) parseFromInputStream:(NSInputStream*) input;

@end

@interface EventLiteshow_Builder : NSObject {
@private
    EventLiteshow* result;
}

- (EventLiteshow*) defaultInstance;

- (EventLiteshow_Builder*) clear;
- (EventLiteshow_Builder*) clone;

- (EventLiteshow*) build;
- (EventLiteshow*) buildPartial;

- (EventLiteshow_Builder*) mergeFrom:(EventLiteshow*) other;

- (BOOL) hasShowId;
- (int32_t) showId;
- (EventLiteshow_Builder*) setShowId:(int32_t) value;
- (EventLiteshow_Builder*) clearShowId;

- (BOOL) hasEventId;
- (NSString*) eventId;
- (EventLiteshow_Builder*) setEventId:(NSString*) value;
- (EventLiteshow_Builder*) clearEventId;

- (BOOL) hasStartDate;
- (NSDate*) startDate;
- (EventLiteshow_Builder*) setStartDate:(NSDate*) value;
- (EventLiteshow_Builder*) clearStartDate;

- (BOOL) hasWinnerId;
- (NSString*) winnerId;
- (EventLiteshow_Builder*) setWinnerId:(NSString*) value;
- (EventLiteshow_Builder*) clearWinnerId;

@end

