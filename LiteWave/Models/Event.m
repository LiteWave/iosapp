
#import "Event.h"

@interface Event ()
@property int32_t eventId;
@property (retain) NSString* eventName;
@property (retain) NSDate* eventDate;
@property (retain) NSString* stadiumId;
@property (retain) NSString* clientId;
@end

@implementation Event

- (BOOL) hasEventId {
  return !!hasEventId_;
}
- (void) setHasEventId:(BOOL) value {
  hasEventId_ = !!value;
}
@synthesize eventId;

- (BOOL) hasEventName {
  return !!hasEventName_;
}
- (void) setHasEventName:(BOOL) value {
  hasEventName_ = !!value;
}
@synthesize eventName;

- (BOOL) hasEventDate {
  return !!hasEventDate_;
}
- (void) setHasEventDate:(BOOL) value {
  hasEventDate_ = !!value;
}
@synthesize eventDate;

- (BOOL) hasStadiumId {
    return !!hasStadiumId_;
}
- (void) setHasStadiumId:(BOOL) value {
    hasStadiumId_ = !!value;
}
@synthesize stadiumId;

- (BOOL) hasClientId {
    return !!hasClientId_;
}
- (void) setHasClientId:(BOOL) value {
    hasClientId_ = !!value;
}
@synthesize clientId;

- (void) dealloc {
  self.eventName = nil;
  self.eventDate = nil;
 
}
- (id) init {
  if ((self = [super init])) {
      self.eventId = 0;
      self.eventName = @"";
      self.eventDate = [NSDate date];
      self.stadiumId = @"";
      self.clientId = @"";
  }
  return self;
}
static Event* defaultPersonInstance = nil;
+ (void) initialize {
  if (self == [Event class]) {
    defaultPersonInstance = [[Event alloc] init];
  }
}
+ (Event*) defaultInstance {
  return defaultPersonInstance;
}
- (Event*) defaultInstance {
  return defaultPersonInstance;
}
- (BOOL) isInitialized {
  if (!self.hasEventId) {
    return NO;
  }
  if (!self.hasEventName) {
    return NO;
  }
  if (!self.hasEventDate) {
    return NO;
  }
  if (!self.hasStadiumId) {
    return NO;
  }
  if (!self.hasClientId) {
    return NO;
  }
    return YES;
}

+ (Event*) parseFromData:(NSData*) data{
    return (Event*)[[Event builder] build];
}
+ (Event*) parseFromInputStream:(NSInputStream*) input{
    return (Event*)[[Event builder] build];
}

+ (Event_Builder*) builder {
  return [[Event_Builder alloc] init];
}
+ (Event_Builder*) builderWithPrototype:(Event*) prototype {
  return [[Event builder] mergeFrom:prototype];
}
- (Event_Builder*) builder {
  return [Event builder];
}
@end

@interface Event_Builder()
@property (retain) Event* result;
@end

@implementation Event_Builder
@synthesize result;
- (void) dealloc {
  self.result = nil;
 
}
- (id) init {
  if ((self = [super init])) {
    self.result = [[Event alloc] init];
  }
  return self;
}

- (Event_Builder*) clear {
  self.result = [[Event alloc] init];
  return self;
}
- (Event_Builder*) clone {
  return [Event builderWithPrototype:result];
}
- (Event*) defaultInstance {
  return [Event defaultInstance];
}
- (Event*) build {
    return [self buildPartial];
}
- (Event*) buildPartial {
  Event* returnMe = result;
  self.result = nil;
  return returnMe;
}
- (Event_Builder*) mergeFrom:(Event*) other {
  if (other == [Event defaultInstance]) {
    return self;
  }
  if (other.hasEventId) {
    [self setEventId:other.eventId];
  }
  if (other.hasEventName) {
    [self setEventName:other.eventName];
  }
  if (other.hasEventDate) {
    [self setEventDate:other.eventDate];
  }
    if (other.hasStadiumId) {
        [self setStadiumId:other.stadiumId];
    }
    if (other.hasClientId) {
        [self setClientId:other.clientId];
    }
  
  return self;
}
- (BOOL) hasEventId {
  return result.hasEventId;
}
- (int32_t) eventId {
  return result.eventId;
}
- (Event_Builder*) setEventId:(int32_t) value {
  result.hasEventId = YES;
  result.eventId = value;
  return self;
}
- (Event_Builder*) clearEventId {
  result.hasEventId = NO;
  result.eventId = 0;
  return self;
}

- (BOOL) hasEventName {
  return result.hasEventName;
}
- (NSString*) eventName {
  return result.eventName;
}
- (Event_Builder*) setEventName:(NSString *)value {
  result.hasEventName = YES;
  result.eventName = value;
  return self;
}
- (Event_Builder*) clearEventName {
  result.hasEventName = NO;
  result.eventName = @"";
  return self;
}

- (BOOL) hasEventDate {
  return result.hasEventDate;
}
- (NSDate*) eventDate {
  return result.eventDate;
}
- (Event_Builder*) setEventDate:(NSDate *)value {
  result.hasEventDate = YES;
  result.eventDate = value;
  return self;
}
- (Event_Builder*) clearEventDate {
  result.hasEventDate = NO;
  result.eventDate = nil;
  return self;
}

- (BOOL) hasStadiumId {
    return result.hasStadiumId;
}
- (NSString*) stadiumId {
    return result.stadiumId;
}
- (Event_Builder*) setStadiumId:(NSString *)value {
    result.hasStadiumId = YES;
    result.stadiumId = value;
    return self;
}
- (Event_Builder*) clearStadiumId {
    result.hasStadiumId = NO;
    result.stadiumId = @"";
    return self;
}

- (BOOL) hasClientId {
    return result.hasClientId;
}
- (NSString*) clientId {
    return result.clientId;
}
- (Event_Builder*) setClientId:(NSString *)value {
    result.hasClientId = YES;
    result.clientId = value;
    return self;
}
- (Event_Builder*) clearClientId {
    result.hasClientId = NO;
    result.clientId = @"";
    return self;
}
@end
