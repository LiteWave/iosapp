
#import "User.h"

@interface User ()
@property int32_t eventId;
@property (retain) NSString* userKey;
@property (retain) NSDictionary* userSeat;
@property (retain) NSNumber* logicalRow;
@property (retain) NSNumber* logicalCol;
@end

@implementation User

- (BOOL) hasEventId {
  return !!hasEventId_;
}
- (void) setHasEventId:(BOOL) value {
  hasEventId_ = !!value;
}
@synthesize eventId;

- (BOOL) hasUserKey {
  return !!hasUserKey_;
}
- (void) setHasUserKey:(BOOL) value {
  hasUserKey_ = !!value;
}
@synthesize userKey;

- (BOOL) hasUserSeat {
  return !!hasUserSeat_;
}
- (void) setHasUserSeat:(BOOL) value {
  hasUserSeat_ = !!value;
}
@synthesize userSeat;

- (BOOL) hasLogicalRow {
    return !!hasLogicalRow_;
}
- (void) setHasLogicalRow:(BOOL) value {
    hasLogicalRow_ = !!value;
}
@synthesize logicalRow;

- (BOOL) hasLogicalCol {
    return !!hasLogicalCol_;
}
- (void) setHasLogicalCol:(BOOL) value {
    hasLogicalCol_ = !!value;
}
@synthesize logicalCol;

- (void) dealloc {
  self.userKey = nil;
  self.userSeat = nil;
 
}
- (id) init {
  if ((self = [super init])) {
      self.eventId = 0;
      self.userKey = @"DFGSDSFGDSGSDFGDSFGVDSFGVDSFGVFDSGVDF";
      self.userSeat = [[NSDictionary alloc] initWithObjects:nil forKeys:nil];
      self.logicalRow = 0;
      self.logicalCol = 0;
  }
  return self;
}
static User* defaultPersonInstance = nil;
+ (void) initialize {
  if (self == [User class]) {
    defaultPersonInstance = [[User alloc] init];
  }
}
+ (User*) defaultInstance {
  return defaultPersonInstance;
}
- (User*) defaultInstance {
  return defaultPersonInstance;
}
- (BOOL) isInitialized {
  if (!self.hasEventId) {
    return NO;
  }
  if (!self.hasUserKey) {
    return NO;
  }
  if (!self.hasUserSeat) {
    return NO;
  }
  if (!self.hasLogicalRow) {
    return NO;
  }
  if (!self.hasLogicalCol) {
    return NO;
  }
    return YES;
}

+ (User*) parseFromData:(NSData*) data{
    return (User*)[[User builder] build];
}
+ (User*) parseFromInputStream:(NSInputStream*) input{
    return (User*)[[User builder] build];
}

+ (User_Builder*) builder {
  return [[User_Builder alloc] init];
}
+ (User_Builder*) builderWithPrototype:(User*) prototype {
  return [[User builder] mergeFrom:prototype];
}
- (User_Builder*) builder {
  return [User builder];
}
@end

@interface User_Builder()
@property (retain) User* result;
@end

@implementation User_Builder
@synthesize result;
- (void) dealloc {
  self.result = nil;
 
}
- (id) init {
  if ((self = [super init])) {
    self.result = [[User alloc] init];
  }
  return self;
}

- (User_Builder*) clear {
  self.result = [[User alloc] init];
  return self;
}
- (User_Builder*) clone {
  return [User builderWithPrototype:result];
}
- (User*) defaultInstance {
  return [User defaultInstance];
}
- (User*) build {
    return [self buildPartial];
}
- (User*) buildPartial {
  User* returnMe = result;
  self.result = nil;
  return returnMe;
}
- (User_Builder*) mergeFrom:(User*) other {
  if (other == [User defaultInstance]) {
    return self;
  }
  if (other.hasEventId) {
    [self setEventId:other.eventId];
  }
  if (other.hasUserKey) {
    [self setUserKey:other.userKey];
  }
  if (other.hasUserSeat) {
    [self setUserSeat:other.userSeat];
  }
    if (other.hasLogicalRow) {
        [self setLogicalRow:other.logicalRow];
    }
    if (other.hasLogicalCol) {
        [self setLogicalCol:other.logicalCol];
    }
  
  return self;
}
- (BOOL) hasEventId {
  return result.hasEventId;
}
- (int32_t) eventId {
  return result.eventId;
}
- (User_Builder*) setEventId:(int32_t) value {
  result.hasEventId = YES;
  result.eventId = value;
  return self;
}
- (User_Builder*) clearEventId {
  result.hasEventId = NO;
  result.eventId = 0;
  return self;
}

- (BOOL) hasUserKey {
  return result.hasUserKey;
}
- (NSString*) userKey {
  return result.userKey;
}
- (User_Builder*) setUserKey:(NSString *)value {
  result.hasUserKey = YES;
  result.userKey = value;
  return self;
}
- (User_Builder*) clearUserKey {
  result.hasUserKey = NO;
  result.userKey = @"";
  return self;
}

- (BOOL) hasUserSeat {
  return result.hasUserSeat;
}
- (NSDictionary*) userSeat {
  return result.userSeat;
}
- (User_Builder*) setUserSeat:(NSDictionary *)value {
  result.hasUserSeat = YES;
  result.userSeat = value;
  return self;
}
- (User_Builder*) clearUserSeat {
  result.hasUserSeat = NO;
  result.userSeat = [[NSDictionary alloc] init];
  return self;
}

- (BOOL) hasLogicalRow {
    return result.hasLogicalRow;
}
- (NSNumber*) logicalRow {
    return result.logicalRow;
}
- (User_Builder*) setLogicalRow:(NSNumber *)value {
    result.hasLogicalRow = YES;
    result.logicalRow = value;
    return self;
}
- (User_Builder*) clearLogicalRow {
    result.hasLogicalRow = NO;
    result.logicalRow = 0;
    return self;
}

- (BOOL) hasLogicalCol {
    return result.hasLogicalCol;
}
- (NSNumber*) logicalCol {
    return result.logicalCol;
}
- (User_Builder*) setLogicalCol:(NSNumber *)value {
    result.hasLogicalCol = YES;
    result.logicalCol = value;
    return self;
}
- (User_Builder*) clearLogicalCol {
    result.hasLogicalCol = NO;
    result.logicalCol = 0;
    return self;
}
@end
