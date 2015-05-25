//
//  CountDownTimerUtility.h
//  CountDownTimer

#import <Foundation/Foundation.h>
@protocol CountDownTimerProtocol
@optional
-(void)timesUpWithLabel:(UILabel *)label;
@end

@interface CountDownTimerUtility : NSObject
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
