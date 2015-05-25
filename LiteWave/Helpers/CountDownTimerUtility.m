//
//  CountDownTimerUtility.m
//  CountDownTimer

#import "CountDownTimerUtility.h"

@implementation CountDownTimerUtility
@synthesize delegate;

-(void)startCountDownTimerWithTime:(double)time andUILabel:(UILabel *)currentLabel
{
    countDownTime = time;
    label = currentLabel;
    [self StartCountDownTimer];
}

-(void)invalidateCurrentCountDownTimer
{
    [self InvalidateCountDownTimer];
}

#pragma mark -
#pragma mark count Down Timer
-(void)InvalidateCountDownTimer
{
    if (CountDownTimer!=nil)
    {
        if ([CountDownTimer isValid])
        {
            [CountDownTimer invalidate];
            
        }
        CountDownTimer=nil;
    }
}

-(void)StartCountDownTimer
{
    [self InvalidateCountDownTimer];
    CountDownTimer=[NSTimer scheduledTimerWithTimeInterval:.01 target:self selector:@selector(DecrementCounterValue) userInfo:nil repeats:YES];
    
    label.text=[NSString stringWithFormat:@"%f", countDownTime];
}

-(void)DecrementCounterValue
{
    if (countDownTime>0)
	{
        countDownTime--;
        label.text=[NSString stringWithFormat:@"%f",countDownTime];
    }
    else
	{
        [self InvalidateCountDownTimer];
        [self performSelectorOnMainThread:@selector(CountDownTimeFinish) withObject:nil waitUntilDone:NO];
    }
}

-(void)CountDownTimeFinish
{
    [delegate timesUpWithLabel:label];
}


@end


