// AFNetworkActivityIndicatorManager.m
//


#import "LWFAFNetworkActivityIndicatorManager.h"

#import "LWFAFHTTPRequestOperation.h"

#if __IPHONE_OS_VERSION_MIN_REQUIRED
static NSTimeInterval const kLWFAFNetworkActivityIndicatorInvisibilityDelay = 0.25;

@interface LWFAFNetworkActivityIndicatorManager ()
@property (readwrite, nonatomic, assign) NSInteger activityCount;
@property (readwrite, nonatomic, retain) NSTimer *activityIndicatorVisibilityTimer;
@property (readonly, getter = isNetworkActivityIndicatorVisible) BOOL networkActivityIndicatorVisible;

- (void)updateNetworkActivityIndicatorVisibility;
@end

@implementation LWFAFNetworkActivityIndicatorManager
@synthesize activityCount = _activityCount;
@synthesize activityIndicatorVisibilityTimer = _activityIndicatorVisibilityTimer;
@synthesize enabled = _enabled;
@dynamic networkActivityIndicatorVisible;

+ (LWFAFNetworkActivityIndicatorManager *)sharedManager {
    static LWFAFNetworkActivityIndicatorManager *_sharedManager = nil;
    static dispatch_once_t oncePredicate;
    dispatch_once(&oncePredicate, ^{
        _sharedManager = [[self alloc] init];
    });
    
    return _sharedManager;
}

- (id)init {
    self = [super init];
    if (!self) {
        return nil;
    }

    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(incrementActivityCount) name:LWFAFNetworkingOperationDidStartNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(decrementActivityCount) name:LWFAFNetworkingOperationDidFinishNotification object:nil];
        
    return self;
}

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    
    [_activityIndicatorVisibilityTimer invalidate];
     _activityIndicatorVisibilityTimer = nil;
    
  
}

- (void)setActivityCount:(NSInteger)activityCount {
    [self willChangeValueForKey:@"activityCount"];
    _activityCount = MAX(activityCount, 0);
    [self didChangeValueForKey:@"activityCount"];

    if (self.enabled) {
        // Delay hiding of activity indicator for a short interval, to avoid flickering
        if (![self isNetworkActivityIndicatorVisible]) {
            [self.activityIndicatorVisibilityTimer invalidate];
            self.activityIndicatorVisibilityTimer = [NSTimer timerWithTimeInterval:kLWFAFNetworkActivityIndicatorInvisibilityDelay target:self selector:@selector(updateNetworkActivityIndicatorVisibility) userInfo:nil repeats:NO];
            [[NSRunLoop currentRunLoop] addTimer:self.activityIndicatorVisibilityTimer forMode:NSRunLoopCommonModes];
        } else {
            [self updateNetworkActivityIndicatorVisibility];
        }
    }
}

- (BOOL)isNetworkActivityIndicatorVisible {
    return self.activityCount > 0;
}

- (void)updateNetworkActivityIndicatorVisibility {
    [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:[self isNetworkActivityIndicatorVisible]];
}

- (void)incrementActivityCount {
    @synchronized(self) {
        self.activityCount += 1;
    }
}

- (void)decrementActivityCount {
    @synchronized(self) {
        self.activityCount -= 1;
    }
}

@end
#endif
