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
    BOOL isWinner; //device is a winner!
    BOOL onORoff; //screen control
    BOOL flipper; //winner on and off switch
    int vibrateDevice; //vibrate 0=no 1=yes
    int strobeDevice; // strobe light 0=no, 1=yes
    int pl1; //play time length in milliseconds
    int pl2; //play time length in milliseconds
    NSString *pif; // winner (w) looser (l)
    NSString *playType; //wait (w) flash (f) color (c) sound (s)
    UIColor *frameColor;
    NSString *screenShowString_;
    NSString *audioShowString_;
	UILabel *frequencyLabel_;
	UIButton *playButton_;
    NSTimer *strobeTimer_;
    NSTimer *winnerTimer_;
    CMMotionManager *motionManager;
    NSArray *commandArray;
    LWCountDownTimerUtility *counterUtil;
    BOOL strobeIsOn_; // For our code to turn strobe on and off
	BOOL strobeActivated_; // To allow user to turn off the light all together
	BOOL strobeFlashOn_; // For our code to turn strobe on and off rapidly
    BOOL isWaving_; //detect motion
@public
    double diff;
	double frequency;
	double theta;
    int position; //command position in the array
    int framePosition; //seconds elapsed during frame playtime
    IBOutlet UIActivityIndicatorView *spinner;
}
@property (nonatomic, retain) NSTimer *strobeTimer;
@property (nonatomic, retain) NSTimer *winnerTimer;
@property (nonatomic, retain) IBOutlet UILabel *waveLabel;
@property (nonatomic, retain) IBOutlet UILabel *startsInLabel;
@property (nonatomic, retain) IBOutlet UILabel *timerLabel;
@property (nonatomic, assign) BOOL strobeActivated;
@property (nonatomic, retain) LWAppDelegate *appDelegate;

- (void)strobeTimerCallback:(id)sender;
- (void)winnerTimerCallback:(id)sender;
- (void)togglePlay;
- (void)stop;
- (void)playFrames:(int)counter;

-(void)showComplete;

@end
