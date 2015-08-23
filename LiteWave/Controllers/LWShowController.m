//
//  ShowViewController.m
//  LiteWave
//

#import "LWShowController.h"
#import <AudioToolbox/AudioToolbox.h>
#import "AFNetworking.h"
#import "LWAppDelegate.h"
#import "LWResultsController.h"
#import "LWApiClient.h"

#ifdef __APPLE__
#include "TargetConditionals.h"
#endif

@implementation LWShowController

@synthesize startsInLabel = startsInLabel_;
@synthesize timerLabel = _timerLabel;
@synthesize frameTimer = frameTimer_;
@synthesize winnerTimer = winnerTimer_;


-(void)viewDidLoad {
    [super viewDidLoad];
    
    self.timerLabel.hidden = YES;
    self.startsInLabel.hidden = YES;
    
    [self.navigationItem setHidesBackButton:YES animated:NO];
    
    self.appDelegate = (LWAppDelegate *)[[UIApplication sharedApplication] delegate];
}

-(void)viewDidAppear:(BOOL)animated {
    
    [self.navigationItem setHidesBackButton:YES animated:NO];
    
    self.timerLabel.hidden = YES;
    self.startsInLabel.hidden = YES;
    position=0;
    diff=0;
    
    [self startShow];
}

-(void)viewDidUnload {
    [counterUtil invalidateCurrentCountDownTimer];
    
    AudioSessionSetActive(false);
}

-(void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


-(void)startShow {
    commandArray = [self.appDelegate.showData objectForKey:@"commands"];

    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    if ([self.appDelegate.showData objectForKey:@"_winner_user_locationId"]) {
      
        self.appDelegate.winnerID = [self.appDelegate.showData valueForKey:@"_winner_user_locationId"];
        if ([self.appDelegate.winnerID isKindOfClass:[NSNull class]]){
          [defaults removeObjectForKey:@"winnerID"];
          isWinner=NO;
        } else {
          [defaults setValue:self.appDelegate.winnerID forKey:@"winnerID"];
          isWinner=YES;
        }
    } else {
        self.appDelegate.winnerID = nil;
        [defaults removeObjectForKey:@"winnerID"];
        isWinner=NO;
    }
    [defaults synchronize];

    if ([self.appDelegate.showData objectForKey:@"mobile_time_offset_ms"]) {
        counterUtil = [[LWCountDownTimerUtility alloc] init];
        [counterUtil setDelegate:self];

        NSDateFormatter *dateformat = [[NSDateFormatter alloc] init];
        [dateformat setDateFormat:@"yyyy-MM-dd'T'HH:mm:ss.SSS'Z'"];
        [dateformat setTimeZone:[NSTimeZone timeZoneWithName:@"GMT"]];

        NSDate *startDate = [dateformat dateFromString:[self.appDelegate.showData valueForKey:@"mobile_start_at"]];
        NSString *mobile_start_at = [dateformat stringFromDate:startDate];
        NSLog(@"start %@",mobile_start_at);

        diff = [startDate timeIntervalSinceNow] * 100.0f;
        NSLog(@"countdown in %f...", diff);
      
        if (diff < 0) {
            [self.navigationController popViewControllerAnimated:YES];
        } else {
            self.timerLabel.hidden = NO;
            self.startsInLabel.hidden = NO;

            [counterUtil startCountDownTimerWithTime:diff andUILabel:self.timerLabel];
        }
    }
}


#pragma mark -
#pragma mark CountDownTimer Delegate methods
-(void)timesUpWithLabel:(UILabel *)label
{
    self.startsInLabel.hidden = YES;
    self.timerLabel.hidden = YES;
    
    position = 0;
    [self playFrames:position];
}

#pragma mark -
#pragma mark ShowViewController Playing show methods

-(void)stop
{
    [self.frameTimer invalidate];
    
    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Main" bundle: nil];
    LWResultsController *results = [storyboard instantiateViewControllerWithIdentifier:@"results"];
    [self presentViewController:results animated:YES completion:nil];
}

-(void)playFrames:(int)counter{
    BOOL winnerLoopFrame = NO;

    if (counter==[commandArray count]) {
        // stop the timers when the end is reached and stop the show
        [self stop];
    } else {
        vibrateDevice = 1; //vibrate 0=no 1=yes
        pl1 = 0; //play time length in milliseconds
        pl2 = 0; //play time length in milliseconds
        pif = nil; // winner (w) looser (l) // not supporting
        playType = @"c"; //wait (w) flash (f) color (c) sound (s)
        frameColor = [UIColor blackColor];
        
        // cl -> command length
        // ct -> command type ('c' for color)
        // sv -> should vibrate (0=no 1=yes)
        // bg -> background color (rgb)

        NSDictionary *frameDict = [commandArray objectAtIndex:counter];
        NSLog(@"%@", frameDict);
        
        if([frameDict objectForKey:@"v"]) {
            vibrateDevice = [[frameDict valueForKey:@"v"] integerValue];
        }
        
        if ([frameDict objectForKey:@"pif"]) {
            pif = [frameDict valueForKey:@"pif"];
        }
        
        if ([frameDict objectForKey:@"pt"]) {
            playType = [frameDict valueForKey:@"pt"];
        }
        
        if ([frameDict objectForKey:@"pl2"]) {
            pl2 = [[frameDict valueForKey:@"pl2"] integerValue];
        }
        
        if ([frameDict objectForKey:@"pl1"]) {
            pl1 = [[frameDict valueForKey:@"pl1"] integerValue];
            
            if ([playType isEqualToString:@"c"]){
                onORoff=YES;
            } else if([playType isEqualToString:@"w"]){
                onORoff=NO;
            } else if([playType isEqualToString:@"r"]){
                onORoff=YES;
            } else if([playType isEqualToString:@"f"]){
                onORoff=YES;
            } else if([playType isEqualToString:@"s"]){
                onORoff=NO;
            } else if([playType isEqualToString:@"win"]){
                winnerLoopFrame=YES;
                onORoff=NO;
            } else{
                onORoff=NO;
            }
            
            if ((counter+1) == [commandArray count] && isWinner) {
                winnerLoopFrame=YES;
                pif = @"w"; 
            }
            
            if ([frameDict objectForKey:@"c"]) {
                
                NSString *colorArray = [frameDict objectForKey:@"c"];
                NSArray *colorItems = [colorArray componentsSeparatedByString:@","];
            
                float red = [[colorItems objectAtIndex:0] doubleValue];
                float green = [[colorItems objectAtIndex:1] doubleValue];
                float blue = [[colorItems objectAtIndex:2] doubleValue];
            
                frameColor = [UIColor colorWithRed:red/255.0 green:green/255.0 blue:blue/255.0 alpha:1];

            } else {
                frameColor = [UIColor blackColor];
            }
            
            if ([pif isEqualToString:@"w"] && !isWinner) {
                //skip frame
                position++;
                [self playFrames:position];
            } else if ([pif isEqualToString:@"l"] && isWinner) {
                //skip frame
                position++;
                [self playFrames:position];
            } else {
                [self onOffSwitch:onORoff];
                position++;
                float timeinterval;
                long extraTime;
                
                if(pl2 > 0) {
                    long randNum;
                    
                    randNum = (pl1 + rand()) % (pl2-pl1); //create the random number.
                    extraTime = pl2 - randNum;
                    
                    timeinterval = randNum/1000.0;
                    NSLog(@"pl1 RANDOM time = %f", timeinterval);
                    self.frameTimer = [NSTimer scheduledTimerWithTimeInterval:timeinterval target:self selector:@selector(randomTimerCallback:) userInfo:nil repeats:NO];
                } else {
                    timeinterval = pl1/1000.0;
                    NSLog(@"pl1 time = %f", timeinterval);
                    self.frameTimer = [NSTimer scheduledTimerWithTimeInterval:timeinterval target:self selector:@selector(frameTimerCallback:) userInfo:nil repeats:NO];
                }
                
                if (winnerLoopFrame) {
                    [self showWinner];
                }
            }
        } else {
            //unknown play time skip frame
            position++;
            [self playFrames:position];
        }
    }
}


-(void)showWinner {
    frameColor = [UIColor whiteColor];
    flipper=YES;
    //self.waveLabel.hidden=NO;
    //self.waveLabel.text = @"WINNER";
    
    //[self.waveLabel setFont:[UIFont systemFontOfSize:70]];
    
    self.winnerTimer = [NSTimer scheduledTimerWithTimeInterval:0.5 target:self selector:@selector(winnerTimerCallback:) userInfo:nil repeats:YES];
}


//  if we're doing a random sequence, then the first part is the color, followed by a call to this time, followed by blacking the screen, followed by a timer for remaining amount of time prior to next command.
- (void)randomTimerCallback:(NSTimer *)sender {
    float timeInterval;
    // NSNumber *num = [sender userInfo];
    timeInterval = 10;  // *num/1000.0;
    frameColor = [UIColor blackColor];
    onORoff=NO;
    [self onOffSwitch:onORoff];
    NSLog(@"random time done, now finishing with %f", timeInterval);
}

- (void)frameTimerCallback:(id)sender {
    
    [self.frameTimer invalidate];
    [self.winnerTimer invalidate];
    [self playFrames:position];
    
}

- (void)winnerTimerCallback:(id)sender {

    flipper = !flipper;
    
    [self winnerAnimation:flipper];
    
}

-(void)winnerAnimation:(BOOL)var
{
    if (var) {
        //screen on
        self.view.backgroundColor = frameColor;
        
        if (vibrateDevice==1) {
            AudioServicesPlaySystemSound(kSystemSoundID_Vibrate);
        }
    } else {
        // screen off
        self.view.backgroundColor = [UIColor blackColor];
    }
}


-(void)onOffSwitch:(BOOL)var
{
    if (var) {
        // screen on
        self.view.backgroundColor = frameColor;
        
        if (vibrateDevice==1) {
            AudioServicesPlaySystemSound(kSystemSoundID_Vibrate);
        }
    } else {
        // screen off
        self.view.backgroundColor = frameColor;
    }
}

@end
