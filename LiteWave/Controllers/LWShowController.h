//
//  ShowViewController.h
//  LiteWave
//

#import <UIKit/UIKit.h>
#import <AVFoundation/AVFoundation.h>
#import <AudioUnit/AudioUnit.h>
#import <CoreMotion/CoreMotion.h>
#import "LWCountDownTimerUtility.h"
#import "LWAppDelegate.h"

@interface LWShowController : UIViewController <UIAccelerometerDelegate, CountDownTimerProtocol>
{
    BOOL isWinner;  // device is a winner!
    BOOL onORoff;   // screen control
    BOOL flipper;   // winner on and off switch

    NSArray *commandArray;
    NSString *commandType;      // color (c) winner (win)
    long commandLength;         // command time length in milliseconds
    long shouldVibrate;         // vibrate (0)=no, (1)=yes
    NSString *playIf;           // winner (w), loser (l)
    UIColor *backgroundColor;   // (rgb)
    
    LWCountDownTimerUtility *counterUtil;
@public
    double diff;
    int position; // command position in the array
    int framePosition; // seconds elapsed during frame playtime
}
@property (nonatomic, retain) NSTimer *frameTimer;
@property (nonatomic, retain) NSTimer *winnerTimer;
@property (nonatomic, retain) IBOutlet UILabel *startsInLabel;
@property (nonatomic, retain) IBOutlet UILabel *timerLabel;
@property (nonatomic, retain) LWAppDelegate *appDelegate;

- (void)winnerTimerCallback:(id)sender;
- (void)frameTimerCallback:(id)sender;
- (void)stop;
- (void)playFrames:(int)counter;
- (void)showWinner;

@end
