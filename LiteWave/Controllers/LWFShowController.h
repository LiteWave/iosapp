//
//  ShowViewController.h
//  LiteWave
//

#import <UIKit/UIKit.h>
#import <AVFoundation/AVFoundation.h>
#import <AudioUnit/AudioUnit.h>
#import <CoreMotion/CoreMotion.h>
#import "LWFCountDownTimerUtility.h"
#import "LWFAppDelegate.h"

@interface LWFShowController : UIViewController <UIAccelerometerDelegate, CountDownTimerProtocol>
{
    BOOL created;
    BOOL isWinner;  // device is a winner!
    BOOL onORoff;   // screen control

    NSArray *commandArray;
    NSString *commandType;      // color (c) winner (win)
    NSString *commandIf;           // winner (w), loser (l)
    long commandLength;         // command time length in milliseconds
    long shouldVibrate;         // vibrate (0)=no, (1)=yes
    UIColor *backgroundColor;   // (rgb)
    
    LWFCountDownTimerUtility *counterUtil;
    
    CGSize appSize;
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
@property (nonatomic, retain) IBOutlet UILabel *infoLabel;
@property (nonatomic, retain) LWFAppDelegate *appDelegate;

- (void)frameTimerCallback:(id)sender;
- (void)playFrames:(int)counter;
- (void)stopShow;
- (void)showWinner;

@end
