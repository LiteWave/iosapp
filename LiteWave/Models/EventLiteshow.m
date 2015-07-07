
#import "EventLiteshow.h"

@interface EventLiteshow ()
@property int32_t showId;
@property (retain) NSString* eventId;
@property (retain) NSDate* startDate;
@property (retain) NSString* winnerId;
@end

@implementation EventLiteshow

- (BOOL) hasShowId {
  return !!hasShowId_;
}
- (void) setHasShowId:(BOOL) value {
  hasShowId_ = !!value;
}
@synthesize showId;

- (BOOL) hasEventId {
  return !!hasEventId_;
}
- (void) setHasEventId:(BOOL) value {
  hasEventId_ = !!value;
}
@synthesize eventId;

- (BOOL) hasStartDate {
  return !!hasStartDate_;
}
- (void) setHasStartDate:(BOOL) value {
  hasStartDate_ = !!value;
}
@synthesize startDate;

- (BOOL) hasWinnerId {
    return !!hasWinnerId_;
}
- (void) setHasWinnerId:(BOOL) value {
    hasWinnerId_ = !!value;
}
@synthesize winnerId;


- (void) dealloc {
  self.eventId = nil;
  self.startDate = nil;
 
}
- (id) init {
  if ((self = [super init])) {
      self.showId = 0;
      self.eventId = @"";
      self.startDate = [NSDate date];
      self.winnerId = @"";
  }
  return self;
}
static EventLiteshow* defaultPersonInstance = nil;
+ (void) initialize {
  if (self == [EventLiteshow class]) {
    defaultPersonInstance = [[EventLiteshow alloc] init];
  }
}
+ (EventLiteshow*) defaultInstance {
  return defaultPersonInstance;
}
- (EventLiteshow*) defaultInstance {
  return defaultPersonInstance;
}
- (BOOL) isInitialized {
  if (!self.hasShowId) {
    return NO;
  }
  if (!self.hasEventId) {
    return NO;
  }
  if (!self.hasStartDate) {
    return NO;
  }
  if (!self.hasWinnerId) {
    return NO;
  }
    return YES;
}

+ (EventLiteshow*) parseFromData:(NSData*) data{
    return (EventLiteshow*)[[EventLiteshow builder] build];
}
+ (EventLiteshow*) parseFromInputStream:(NSInputStream*) input{
    return (EventLiteshow*)[[EventLiteshow builder] build];
}

+ (EventLiteshow_Builder*) builder {
  return [[EventLiteshow_Builder alloc] init];
}
+ (EventLiteshow_Builder*) builderWithPrototype:(EventLiteshow*) prototype {
  return [[EventLiteshow builder] mergeFrom:prototype];
}
- (EventLiteshow_Builder*) builder {
  return [EventLiteshow builder];
}
@end

@interface EventLiteshow_Builder()
@property (retain) EventLiteshow* result;
@end

@implementation EventLiteshow_Builder
@synthesize result;
- (void) dealloc {
  self.result = nil;
 
}
- (id) init {
  if ((self = [super init])) {
    self.result = [[EventLiteshow alloc] init];
  }
  return self;
}

- (EventLiteshow_Builder*) clear {
  self.result = [[EventLiteshow alloc] init];
  return self;
}
- (EventLiteshow_Builder*) clone {
  return [EventLiteshow builderWithPrototype:result];
}
- (EventLiteshow*) defaultInstance {
  return [EventLiteshow defaultInstance];
}
- (EventLiteshow*) build {
    return [self buildPartial];
}
- (EventLiteshow*) buildPartial {
  EventLiteshow* returnMe = result;
  self.result = nil;
  return returnMe;
}
- (EventLiteshow_Builder*) mergeFrom:(EventLiteshow*) other {
  if (other == [EventLiteshow defaultInstance]) {
    return self;
  }
  if (other.hasShowId) {
    [self setShowId:other.showId];
  }
  if (other.hasEventId) {
    [self setEventId:other.eventId];
  }
  if (other.hasStartDate) {
    [self setStartDate:other.startDate];
  }
    if (other.hasWinnerId) {
        [self setWinnerId:other.winnerId];
    }
  
  return self;
}
- (BOOL) hasShowId {
  return result.hasShowId;
}
- (int32_t) showId {
  return result.showId;
}
- (EventLiteshow_Builder*) setShowId:(int32_t) value {
  result.hasShowId = YES;
  result.showId = value;
  return self;
}
- (EventLiteshow_Builder*) clearShowId {
  result.hasShowId = NO;
  result.showId = 0;
  return self;
}

- (BOOL) hasEventId {
  return result.hasEventId;
}
- (NSString*) eventId {
  return result.eventId;
}
- (EventLiteshow_Builder*) setEventId:(NSString *)value {
  result.hasEventId = YES;
  result.eventId = value;
  return self;
}
- (EventLiteshow_Builder*) clearEventId {
  result.hasEventId = NO;
  result.eventId = @"";
  return self;
}

- (BOOL) hasStartDate {
  return result.hasStartDate;
}
- (NSDate*) startDate {
  return result.startDate;
}
- (EventLiteshow_Builder*) setStartDate:(NSDate *)value {
  result.hasStartDate = YES;
  result.startDate = value;
  return self;
}
- (EventLiteshow_Builder*) clearStartDate {
  result.hasStartDate = NO;
  result.startDate = nil;
  return self;
}

- (BOOL) hasWinnerId {
    return result.hasWinnerId;
}
- (NSString*) winnerId {
    return result.winnerId;
}
- (EventLiteshow_Builder*) setWinnerId:(NSString *)value {
    result.hasWinnerId = YES;
    result.winnerId = value;
    return self;
}
- (EventLiteshow_Builder*) clearWinnerId {
    result.hasWinnerId = NO;
    result.winnerId = @"";
    return self;
}

@end
