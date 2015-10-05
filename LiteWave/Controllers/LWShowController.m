//
//  ShowViewController.m
//  LiteWave
//

#import "LWShowController.h"
#import <AudioToolbox/AudioToolbox.h>
#import "AFNetworking.h"
#import "LWAppDelegate.h"
#import "LWResultsController.h"
#import "LWUtility.h"
#import "LWApiClient.h"
#import "LWConfiguration.h"

@implementation LWShowController

@synthesize startsInLabel = _startsInLabel;
@synthesize timerLabel = _timerLabel;


-(void)viewDidLoad {
    [super viewDidLoad];
    
    self.timerLabel.hidden = YES;
    self.startsInLabel.hidden = YES;
    self.winnerLabel.hidden = YES;
    self.infoLabel.hidden = YES;
    
    [self.navigationItem setHidesBackButton:YES animated:NO];

    // disable fade of screen
    [[UIApplication sharedApplication] setIdleTimerDisabled:YES];
    
    self.appDelegate = (LWAppDelegate *)[[UIApplication sharedApplication] delegate];
    
    self.view.backgroundColor = [UIColor blackColor];
    self.timerLabel.textColor = [LWConfiguration instance].highlightColor;
    self.startsInLabel.textColor = [LWConfiguration instance].highlightColor;
    self.infoLabel.textColor = [LWConfiguration instance].highlightColor;
    self.infoLabel.frame = CGRectMake(self.infoLabel.frame.origin.x,
                                      self.view.frame.size.height - self.infoLabel.frame.size.height - 10,
                                      self.infoLabel.frame.size.width,
                                      self.infoLabel.frame.size.height);
}

-(void)viewDidAppear:(BOOL)animated {
    
    [self.navigationItem setHidesBackButton:YES animated:NO];
    
    self.timerLabel.hidden = YES;
    self.startsInLabel.hidden = YES;
    self.infoLabel.hidden = YES;
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
    commandArray = [[LWConfiguration instance].showData objectForKey:@"commands"];

    NSString *winnerID = [[LWConfiguration instance].showData valueForKey:@"_winnerId"];
    if (winnerID != (id)[NSNull null] && [winnerID isEqualToString:[LWConfiguration instance].userID]) {
        isWinner=YES;
    } else {
        isWinner=NO;
    }

    if ([[LWConfiguration instance].showData objectForKey:@"mobileTimeOffset"]) {
        counterUtil = [[LWCountDownTimerUtility alloc] init];
        [counterUtil setDelegate:self];

        NSDateFormatter *dateformat = [[NSDateFormatter alloc] init];
        [dateformat setDateFormat:@"yyyy-MM-dd'T'HH:mm:ss.SSS'Z'"];
        [dateformat setTimeZone:[NSTimeZone timeZoneWithName:@"GMT"]];

        NSDate *startDate = [dateformat dateFromString:[[LWConfiguration instance].showData valueForKey:@"mobileStartAt"]];
        NSString *mobileStartAt = [dateformat stringFromDate:startDate];
        NSLog(@"start %@", mobileStartAt);

        diff = [startDate timeIntervalSinceNow] * 100.0f;
        NSLog(@"countdown in %f...", diff);
      
        if (diff < 0) {
            [self.presentingViewController dismissViewControllerAnimated:YES completion:nil];
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Join error"
                                                            message:@"Sorry, the show has expired."
                                                           delegate:self
                                                  cancelButtonTitle:@"OK"
                                                  otherButtonTitles:nil];
            [alert show];

        } else {
            self.timerLabel.hidden = NO;
            self.startsInLabel.hidden = NO;
            self.infoLabel.hidden = NO;
            
            self.view.backgroundColor = [UIColor blackColor];
            
            [counterUtil startCountDownTimerWithTime:diff andUILabel:self.timerLabel];
        }
    }
}

-(void)stopShow
{
    [self.frameTimer invalidate];
    
    UIStoryboard* storyboard = [UIStoryboard storyboardWithName:@"Main"
                                                         bundle:[NSBundle bundleForClass:LWShowController.class]];
    LWResultsController *results = [storyboard instantiateViewControllerWithIdentifier:@"results"];
    [self presentViewController:results animated:YES completion:nil];
    
    self.winnerLabel.hidden = YES;
}

-(void)timesUpWithLabel:(UILabel *)label
{
    self.startsInLabel.hidden = YES;
    self.timerLabel.hidden = YES;
    self.infoLabel.hidden = YES;
    
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
            } else if([commandType isEqualToString:@"win"] && isWinner){
                winnerLoopFrame=YES;
                onORoff=NO;
                [self showWinner];
                
            } else{
                onORoff=NO;
            }

            if ([frameDict objectForKey:@"bg"]) {
                backgroundColor = [LWUtility getColorFromString:[frameDict objectForKey:@"bg"]];
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
            }
        } else {
            // unknown play time skip frame
            position++;
            [self playFrames:position];
        }
    }
}

-(void)showWinner {
    self.winnerLabel.hidden=NO;
    self.winnerLabel.text = @"WINNER";
    [self.winnerLabel setTextColor:[LWConfiguration instance].highlightColor];
    [self.winnerLabel setFont:[UIFont systemFontOfSize:70]];
}

- (void)frameTimerCallback:(id)sender {
    
    [self.frameTimer invalidate];
    [self playFrames:position];
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
