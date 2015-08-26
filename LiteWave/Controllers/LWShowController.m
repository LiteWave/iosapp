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

@implementation LWShowController

@synthesize startsInLabel = _startsInLabel;
@synthesize timerLabel = _timerLabel;


-(void)viewDidLoad {
    [super viewDidLoad];
    
    self.timerLabel.hidden = YES;
    self.startsInLabel.hidden = YES;
    self.winnerLabel.hidden = YES;
    
    [self.navigationItem setHidesBackButton:YES animated:NO];
    
    self.appDelegate = (LWAppDelegate *)[[UIApplication sharedApplication] delegate];
    
    self.view.backgroundColor = self.appDelegate.backgroundColor;
    self.timerLabel.textColor = self.appDelegate.highlightColor;
    self.startsInLabel.textColor = self.appDelegate.highlightColor;
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

    NSString *winnerID = [self.appDelegate.showData valueForKey:@"_winner_user_location_id"];
    if (winnerID != (id)[NSNull null] && [winnerID isEqualToString:self.appDelegate.userID]) {
        isWinner=YES;
    } else {
        isWinner=NO;
    }

    if ([self.appDelegate.showData objectForKey:@"mobileTimeOffset"]) {
        counterUtil = [[LWCountDownTimerUtility alloc] init];
        [counterUtil setDelegate:self];

        NSDateFormatter *dateformat = [[NSDateFormatter alloc] init];
        [dateformat setDateFormat:@"yyyy-MM-dd'T'HH:mm:ss.SSS'Z'"];
        [dateformat setTimeZone:[NSTimeZone timeZoneWithName:@"GMT"]];

        NSDate *startDate = [dateformat dateFromString:[self.appDelegate.showData valueForKey:@"mobileStartAt"]];
        NSString *mobileStartAt = [dateformat stringFromDate:startDate];
        NSLog(@"start %@", mobileStartAt);

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

-(void)stopShow
{
    [self.frameTimer invalidate];
    
    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Main" bundle: nil];
    LWResultsController *results = [storyboard instantiateViewControllerWithIdentifier:@"results"];
    [self presentViewController:results animated:YES completion:nil];
    
    self.winnerLabel.hidden = YES;
}

-(void)timesUpWithLabel:(UILabel *)label
{
    self.startsInLabel.hidden = YES;
    self.timerLabel.hidden = YES;
    
    position = 0;
    [self playFrames:position];
}

-(void)playFrames:(int)counter {
    BOOL winnerLoopFrame = NO;

    if (counter==[commandArray count]) {
        // stop the timers when the end is reached and stop the show
        [self stopShow];
    } else {
        commandType = @"c"; // color (c) winner (win)
        commandLength = 0; // command time length in milliseconds
        commandIf = nil; // winner (w), loser (l)
        shouldVibrate = 1; // vibrate 0=no 1=yes
        backgroundColor = [UIColor blackColor]; // (rgb)
        
        // cl -> command length
        // ct -> command type
        // sv -> should vibrate
        // bg -> background color (rgb)
        NSDictionary *frameDict = [commandArray objectAtIndex:counter];
        NSLog(@"%@", frameDict);
        
        if([frameDict objectForKey:@"sv"]) {
            shouldVibrate = [[frameDict valueForKey:@"sv"] integerValue];
        }
        
        if ([frameDict objectForKey:@"cif"]) {
            commandIf = [frameDict valueForKey:@"cif"];
        }
        
        if ([frameDict objectForKey:@"ct"]) {
            commandType = [frameDict valueForKey:@"ct"];
        }
        
        if ([frameDict objectForKey:@"cl"]) {
            commandLength = [[frameDict valueForKey:@"cl"] integerValue];
            
            if ([commandType isEqualToString:@"c"]){
                onORoff=YES;
            } else if([commandType isEqualToString:@"win"]){
                winnerLoopFrame=YES;
                onORoff=NO;
            } else{
                onORoff=NO;
            }
            
            if ((counter+1) == [commandArray count] && isWinner) {
                winnerLoopFrame=YES;
                commandIf = @"w";
            }
            
            if ([frameDict objectForKey:@"bg"]) {
                
                NSString *colorArray = [frameDict objectForKey:@"bg"];
                NSArray *colorItems = [colorArray componentsSeparatedByString:@","];
            
                float red = [[colorItems objectAtIndex:0] doubleValue];
                float green = [[colorItems objectAtIndex:1] doubleValue];
                float blue = [[colorItems objectAtIndex:2] doubleValue];
            
                backgroundColor = [UIColor colorWithRed:red/255.0 green:green/255.0 blue:blue/255.0 alpha:1];

            } else {
                backgroundColor = [UIColor blackColor];
            }
            
            if ([commandIf isEqualToString:@"w"] && !isWinner) {
                //skip frame
                position++;
                [self playFrames:position];
            } else if ([commandIf isEqualToString:@"l"] && isWinner) {
                //skip frame
                position++;
                [self playFrames:position];
            } else {
                [self onOffSwitch:onORoff];
                position++;
                float timeinterval = commandLength/1000.0;

                NSLog(@"cl time = %f", timeinterval);
                self.frameTimer = [NSTimer scheduledTimerWithTimeInterval:timeinterval target:self selector:@selector(frameTimerCallback:) userInfo:nil repeats:NO];
      
                
                if (winnerLoopFrame) {
                    [self showWinner];
                }
            }
        } else {
            // unknown play time skip frame
            position++;
            [self playFrames:position];
        }
    }
}

-(void)showWinner {
    backgroundColor = [UIColor whiteColor];
    flipper=YES;
    
    self.winnerLabel.hidden = YES;
    self.winnerLabel.hidden=NO;
    self.winnerLabel.text = @"WINNER";
    [self.winnerLabel setTextColor:self.appDelegate.highlightColor];
    [self.winnerLabel setFont:[UIFont systemFontOfSize:70]];
    
    self.winnerTimer = [NSTimer scheduledTimerWithTimeInterval:0.5 target:self selector:@selector(winnerTimerCallback:) userInfo:nil repeats:YES];
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
        self.view.backgroundColor = backgroundColor;
        
        if (shouldVibrate==1) {
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
        self.view.backgroundColor = backgroundColor;
        
        if (shouldVibrate==1) {
            AudioServicesPlaySystemSound(kSystemSoundID_Vibrate);
        }
    } else {
        // screen off
        self.view.backgroundColor = backgroundColor;
    }
}

@end
