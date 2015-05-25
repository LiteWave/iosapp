
#import "Stadium.h"

@interface Stadium ()
@property int32_t entryId;
@property (retain) NSString* name;
@property (retain) NSDictionary* sections;
@end

@implementation Stadium

- (BOOL) hasEntryId {
  return !!hasEntryId_;
}
- (void) setHasEntryId:(BOOL) value {
  hasEntryId_ = !!value;
}
@synthesize entryId;

- (BOOL) hasName {
  return !!hasName_;
}
- (void) setHasName:(BOOL) value {
  hasName_ = !!value;
}
@synthesize name;

- (BOOL) hasSections {
  return !!hasSections_;
}
- (void) setHasSections:(BOOL) value {
  hasSections_ = !!value;
}
@synthesize sections;

- (void) dealloc {
  self.name = nil;
  self.sections = nil;
 
}
- (id) init {
  if ((self = [super init])) {
      self.entryId = 0;
      self.name = @"";
      self.sections = [[NSDictionary alloc] initWithObjects:nil forKeys:nil];
  }
  return self;
}
static Stadium* defaultPersonInstance = nil;
+ (void) initialize {
  if (self == [Stadium class]) {
    defaultPersonInstance = [[Stadium alloc] init];
  }
}
+ (Stadium*) defaultInstance {
  return defaultPersonInstance;
}
- (Stadium*) defaultInstance {
  return defaultPersonInstance;
}
- (BOOL) isInitialized {
  if (!self.hasEntryId) {
    return NO;
  }
  if (!self.hasName) {
    return NO;
  }
  if (!self.hasSections) {
    return NO;
  }
    return YES;
}

+ (Stadium*) parseFromData:(NSData*) data{
    return (Stadium*)[[Stadium builder] build];
}
+ (Stadium*) parseFromInputStream:(NSInputStream*) input{
    return (Stadium*)[[Stadium builder] build];
}

+ (Stadium_Builder*) builder {
  return [[Stadium_Builder alloc] init];
}
+ (Stadium_Builder*) builderWithPrototype:(Stadium*) prototype {
  return [[Stadium builder] mergeFrom:prototype];
}
- (Stadium_Builder*) builder {
  return [Stadium builder];
}
@end

@interface Stadium_Builder()
@property (retain) Stadium* result;
@end

@implementation Stadium_Builder
@synthesize result;
- (void) dealloc {
  self.result = nil;
 
}
- (id) init {
  if ((self = [super init])) {
    self.result = [[Stadium alloc] init];
  }
  return self;
}

- (Stadium_Builder*) clear {
  self.result = [[Stadium alloc] init];
  return self;
}
- (Stadium_Builder*) clone {
  return [Stadium builderWithPrototype:result];
}
- (Stadium*) defaultInstance {
  return [Stadium defaultInstance];
}
- (Stadium*) build {
    return [self buildPartial];
}
- (Stadium*) buildPartial {
  Stadium* returnMe = result;
  self.result = nil;
  return returnMe;
}
- (Stadium_Builder*) mergeFrom:(Stadium*) other {
  if (other == [Stadium defaultInstance]) {
    return self;
  }
  if (other.hasEntryId) {
    [self setEntryId:other.entryId];
  }
  if (other.hasName) {
    [self setName:other.name];
  }
  if (other.hasSections) {
    [self setSections:other.sections];
  }
  
  return self;
}
- (BOOL) hasEntryId {
  return result.hasEntryId;
}
- (int32_t) entryId {
  return result.entryId;
}
- (Stadium_Builder*) setEntryId:(int32_t) value {
  result.hasEntryId = YES;
  result.entryId = value;
  return self;
}
- (Stadium_Builder*) clearEntryId {
  result.hasEntryId = NO;
  result.entryId = 0;
  return self;
}
- (BOOL) hasName {
  return result.hasName;
}
- (NSString*) name {
  return result.name;
}
- (Stadium_Builder*) setName:(NSString*) value {
  result.hasName = YES;
  result.name = value;
  return self;
}
- (Stadium_Builder*) clearName {
  result.hasName = NO;
  result.name = @"";
  return self;
}
- (BOOL) hasSections {
  return result.hasSections;
}
- (NSDictionary*) sections {
  return result.sections;
}
- (Stadium_Builder*) setSections:(NSDictionary*) value {
  result.hasSections = YES;
  result.sections = value;
  return self;
}
- (Stadium_Builder*) clearSections {
  result.hasSections = NO;
  result.sections = [[NSDictionary alloc] init];
  return self;
}
@end
