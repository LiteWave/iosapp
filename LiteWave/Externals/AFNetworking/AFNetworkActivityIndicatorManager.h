// AFNetworkActivityIndicatorManager.h
//


#import <Foundation/Foundation.h>

#import <Availability.h>

#if __IPHONE_OS_VERSION_MIN_REQUIRED
#import <UIKit/UIKit.h>

/**
 `AFNetworkActivityIndicatorManager` manages the state of the network activity indicator in the status bar. When enabled, it will listen for notifications indicating that a network request operation has started or finished, and start or stop animating the indicator accordingly. The number of active requests is incremented and decremented much like a stack or a semaphore, and the activity indicator will animate so long as that number is greater than zero.
 */
@interface AFNetworkActivityIndicatorManager : NSObject {
@private
	NSInteger _activityCount;
    BOOL _enabled;
    NSTimer *_activityIndicatorVisibilityTimer;
}

/**
 A Boolean value indicating whether the manager is enabled. 
 
 @discussion If YES, the manager will change status bar network activity indicator according to network operation notifications it receives. The default value is NO.
 */
@property (nonatomic, assign, getter = isEnabled) BOOL enabled;

/**
 Returns the shared network activity indicator manager object for the system.
 
 @return The systemwide network activity indicator manager.
 */
+ (AFNetworkActivityIndicatorManager *)sharedManager;

/**
 Increments the number of active network requests. If this number was zero before incrementing, this will start animating the status bar network activity indicator.
 */
- (void)incrementActivityCount;

/**
 Decrements the number of active network requests. If this number becomes zero before decrementing, this will stop animating the status bar network activity indicator.
 */
- (void)decrementActivityCount;

@end
#endif
