//
//  CountDownTimerUtility.h
//  CountDownTimer

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

@protocol CountDownTimerProtocol
@optional
-(void)timesUpWithLabel:(UILabel *)label;
@end

@interface LWCountDownTimerUtility : NSObject
{
    NSTimer *CountTimer;
    NSTimer *CountDownTimer;
    double countDownTime;
    UILabel *label;
    id<CountDownTimerProtocol>delegate;
}
@property (retain)id<CountDownTimerProtocol>delegate;
-(void)startCountDownTimerWithTime:(double)time andUILabel:(UILabel *)currentLabel;
-(void)invalidateCurrentCountDownTimer;
@end
