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
    
    label.text=[NSString stringWithFormat:@"%d", ((int)countDownTime/100)];
}

-(void)DecrementCounterValue
{
    if (((int)countDownTime/100) > 0)
	{
        countDownTime--;
        label.text=[NSString stringWithFormat:@"%d", ((int)countDownTime/100)];
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


