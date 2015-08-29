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

    NSArray *commandArray;
    NSString *commandType;      // color (c) winner (win)
    NSString *commandIf;           // winner (w), loser (l)
    long commandLength;         // command time length in milliseconds
    long shouldVibrate;         // vibrate (0)=no, (1)=yes
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
@property (nonatomic, retain) IBOutlet UILabel *winnerLabel;
@property (nonatomic, retain) LWAppDelegate *appDelegate;

- (void)frameTimerCallback:(id)sender;
- (void)playFrames:(int)counter;
- (void)stopShow;
- (void)showWinner;

@end
