//
//  CountDownTimerUtility.m
//  CountDownTimer

#import "LWFCountDownTimerUtility.h"

@implementation LWFCountDownTimerUtility
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
    
    double time = ((int)countDownTime/100);
    if ((int)time > 0)
        label.text=[NSString stringWithFormat:@"%d", (int)time];
}

-(void)DecrementCounterValue
{
    double time = ((int)countDownTime/100);
    if (countDownTime > 0)
	{
        countDownTime--;
        if ((int)time > 0)
            label.text=[NSString stringWithFormat:@"%d", (int)time];
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


