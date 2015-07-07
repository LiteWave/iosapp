//
//  ShowViewController.m
//  LiteWave
//

#import "ShowController.h"
#import <AudioToolbox/AudioToolbox.h>
#import "AFNetworking.h"
#import "LiteWaveAppDelegate.h"
#import "ResultsController.h"
#import "APIClient.h"

#ifdef __APPLE__
#include "TargetConditionals.h"
#endif

OSStatus RenderTone(
                    void *inRefCon,
                    AudioUnitRenderActionFlags 	*ioActionFlags,
                    const AudioTimeStamp 		*inTimeStamp,
                    UInt32 						inBusNumber,
                    UInt32 						inNumberFrames,
                    AudioBufferList 			*ioData)

{
	// Fixed amplitude is good enough for our purposes
	const double amplitude = 0.25;
    
	// Get the tone parameters out of the view controller
	ShowController *viewController =
    (__bridge ShowController *)inRefCon;
	double theta = viewController->theta;
	double theta_increment = 2.0 * M_PI * viewController->frequency / viewController->sampleRate;
    
	// This is a mono tone generator so we only need the first buffer
	const int channel = 0;
	Float32 *buffer = (Float32 *)ioData->mBuffers[channel].mData;
	
	// Generate the samples
	for (UInt32 frame = 0; frame < inNumberFrames; frame++)
	{
		buffer[frame] = sin(theta) * amplitude;
		
		theta += theta_increment;
		if (theta > 2.0 * M_PI)
		{
			theta -= 2.0 * M_PI;
		}
	}
	
	// Store the theta back in the view controller
	viewController->theta = theta;
    
	return noErr;
}

void ToneInterruptionListener(void *inClientData, UInt32 inInterruptionState)
{
	ShowController *viewController =
    (__bridge ShowController *)inClientData;
	
	[viewController stop];
}

@implementation ShowController

@synthesize startsInLabel = startsInLabel_;
@synthesize waveLabel = waveLabel_;
@synthesize timerLabel = _timerLabel;
@synthesize strobeTimer = strobeTimer_;
@synthesize strobeActivated = strobeActivated_;
@synthesize winnerTimer = winnerTimer_;

- (void)createToneUnit
{
	// Configure the search parameters to find the default playback output unit
	// (called the kAudioUnitSubType_RemoteIO on iOS but
	// kAudioUnitSubType_DefaultOutput on Mac OS X)
	AudioComponentDescription defaultOutputDescription;
	defaultOutputDescription.componentType = kAudioUnitType_Output;
	defaultOutputDescription.componentSubType = kAudioUnitSubType_RemoteIO;
	defaultOutputDescription.componentManufacturer = kAudioUnitManufacturer_Apple;
	defaultOutputDescription.componentFlags = 0;
	defaultOutputDescription.componentFlagsMask = 0;
	
	// Get the default playback output unit
	AudioComponent defaultOutput = AudioComponentFindNext(NULL, &defaultOutputDescription);
	//NSAssert(defaultOutput, @"Can't find default output");
	
	// Create a new unit based on this that we'll use for output
	OSErr err = AudioComponentInstanceNew(defaultOutput, &toneUnit);
	//NSAssert1(self.toneUnit, @"Error creating unit: %ld", err);
	
	// Set our tone rendering function on the unit
	AURenderCallbackStruct input;
	input.inputProc = RenderTone;
	input.inputProcRefCon = (__bridge void *)(self);
	err = AudioUnitSetProperty(toneUnit,
                               kAudioUnitProperty_SetRenderCallback,
                               kAudioUnitScope_Input,
                               0,
                               &input,
                               sizeof(input));
	//NSAssert1(err == noErr, @"Error setting callback: %ld", err);
	
	// Set the format to 32 bit, single channel, floating point, linear PCM
	const int four_bytes_per_float = 4;
	const int eight_bits_per_byte = 8;
	AudioStreamBasicDescription streamFormat;
	streamFormat.mSampleRate = sampleRate;
	streamFormat.mFormatID = kAudioFormatLinearPCM;
	streamFormat.mFormatFlags =
    kAudioFormatFlagsNativeFloatPacked | kAudioFormatFlagIsNonInterleaved;
	streamFormat.mBytesPerPacket = four_bytes_per_float;
	streamFormat.mFramesPerPacket = 1;
	streamFormat.mBytesPerFrame = four_bytes_per_float;
	streamFormat.mChannelsPerFrame = 1;
	streamFormat.mBitsPerChannel = four_bytes_per_float * eight_bits_per_byte;
	err = AudioUnitSetProperty (toneUnit,
                                kAudioUnitProperty_StreamFormat,
                                kAudioUnitScope_Input,
                                0,
                                &streamFormat,
                                sizeof(AudioStreamBasicDescription));
	//NSAssert1(err == noErr, @"Error setting stream format: %ld", err);
}

- (void)togglePlay
{
	if (toneUnit)
	{
		AudioOutputUnitStop(toneUnit);
		AudioUnitUninitialize(toneUnit);
		AudioComponentInstanceDispose(toneUnit);
		toneUnit = nil;
		
	}
	else
	{
		[self createToneUnit];
		
		// Stop changing parameters on the unit
		OSErr err = AudioUnitInitialize(toneUnit);
		//NSAssert1(err == noErr, @"Error initializing unit: %ld", err);
		
		// Start playback
		err = AudioOutputUnitStart(toneUnit);
		//NSAssert1(err == noErr, @"Error starting unit: %ld", err);
		
	}
}

-(void)startAccelerometerData{
    
    motionManager = [[CMMotionManager alloc] init];
    motionManager.accelerometerUpdateInterval = 0.01;
    [motionManager startAccelerometerUpdatesToQueue:[NSOperationQueue currentQueue] withHandler:^(CMAccelerometerData *accelerometerData, NSError *error) {
        //NSLog(@"x:= %f y:= %f z:= %f", accelerometerData.acceleration.x, accelerometerData.acceleration.x,accelerometerData.acceleration.x);
        
        if(accelerometerData.acceleration.x > 1.0){
            
            [motionManager stopAccelerometerUpdates];
            
            LiteWaveAppDelegate *appDelegate = (LiteWaveAppDelegate *)[[UIApplication sharedApplication] delegate];
            
            NSDateFormatter *dateformat = [[NSDateFormatter alloc] init];
            [dateformat setDateFormat:@"yyyy-MM-dd'T'HH:mm:ss.SSS'Z'"];
            [dateformat setTimeZone:[NSTimeZone timeZoneWithName:@"GMT"]];
            
            NSDate *startDate = [dateformat dateFromString:[appDelegate.eventJoinData valueForKey:@"mobile_start_at"]];
            
            NSLog(@"start %@",startDate);
            
            diff = [startDate timeIntervalSinceNow] * 100.0f;
            
            NSLog(@"countdown in %f...", diff);
            
            if(diff<0){
                
                [spinner stopAnimating];
                UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Show Expired" message:@"This show is no longer available for this event. Please withdraw and register for a new event." delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil];
                [alert show];
                
                [self.navigationController popViewControllerAnimated:YES];
                
            }else{
                
                [spinner stopAnimating];
                self.timerLabel.hidden = NO;
                self.startsInLabel.hidden = NO;
                
                [counterUtil startCountDownTimerWithTime:diff andUILabel:self.timerLabel];
                
                self.waveLabel.hidden = YES;
                
            }
            
            motionManager = nil;
            
        }
        
    } ];
}

-(void) startLiteShow{
    
    LiteWaveAppDelegate *appDelegate = (LiteWaveAppDelegate *)[[UIApplication sharedApplication] delegate];
    
    if (appDelegate.isOnline) {
        
        [spinner startAnimating];
        
        commandArray = [appDelegate.liteShow objectForKey:@"commands"];

        NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
        if([appDelegate.eventJoinData objectForKey:@"_winner_user_locationId"]) {
          
          appDelegate.winnerID = [appDelegate.eventJoinData valueForKey:@"_winner_user_locationId"];
          if([appDelegate.winnerID isKindOfClass:[NSNull class]]){
              
              [defaults removeObjectForKey:@"winnerID"];
              isWinner=NO;
              
          }else{
              
              [defaults setValue:appDelegate.winnerID forKey:@"winnerID"];
              isWinner=YES;
              
          }
          
        } else {
          appDelegate.winnerID = nil;
          [defaults removeObjectForKey:@"winnerID"];
          isWinner=NO;
        }
        [defaults synchronize];

        if ([appDelegate.eventJoinData objectForKey:@"mobile_time_offset_ms"]) {
          
          [spinner stopAnimating];
          
          counterUtil = [[CountDownTimerUtility alloc] init];
          [counterUtil setDelegate:self];
          
          self.waveLabel.hidden = NO;
          
          [self startAccelerometerData];
          
        #if (TARGET_IPHONE_SIMULATOR)
          
          [motionManager stopAccelerometerUpdates];
          
          NSDateFormatter *dateformat = [[NSDateFormatter alloc] init];
          [dateformat setDateFormat:@"yyyy-MM-dd'T'HH:mm:ss.SSS'Z'"];
          [dateformat setTimeZone:[NSTimeZone timeZoneWithName:@"GMT"]];
          
          NSDate *startDate = [dateformat dateFromString:[appDelegate.eventJoinData valueForKey:@"mobile_start_at"]];
          
          NSString *mobile_start_at = [dateformat stringFromDate:startDate];
          
          NSLog(@"start %@",mobile_start_at);
          
          diff = [startDate timeIntervalSinceNow] * 100.0f;
          
          NSLog(@"countdown in %f...", diff);
          
          if(diff<0){
              
              [spinner stopAnimating];
              [self.navigationController popViewControllerAnimated:YES];
              
          }else{
              
              [spinner stopAnimating];
              self.timerLabel.hidden = NO;
              self.startsInLabel.hidden = NO;
              
              [counterUtil startCountDownTimerWithTime:diff andUILabel:self.timerLabel];
              
          }
          
          self.waveLabel.hidden = YES;
          motionManager = nil;
          
          
        #endif
        }
    } else {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle: NSLocalizedString(@"Network error", @"Network error")
                                                        message: NSLocalizedString(@"No internet connection found, this application requires an internet connection.", @"Network error") delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil];
        [alert show];
    }
    
}

- (void)viewDidLoad {
	[super viewDidLoad];
    
    self.timerLabel.hidden = YES;
    self.startsInLabel.hidden = YES;
    self.waveLabel.hidden = YES;
    
    [self.navigationItem setHidesBackButton:YES animated:NO];
    
    sampleRate = 44100;
    
	OSStatus result = AudioSessionInitialize(NULL, NULL, ToneInterruptionListener, (__bridge void *)(self));
	if (result == kAudioSessionNoError)
	{
		UInt32 sessionCategory = kAudioSessionCategory_MediaPlayback;
		AudioSessionSetProperty(kAudioSessionProperty_AudioCategory, sizeof(sessionCategory), &sessionCategory);
	}
	AudioSessionSetActive(true);
    
}

- (void)viewDidAppear:(BOOL)animated{
    
    [self.navigationItem setHidesBackButton:YES animated:NO];
    
    self.timerLabel.hidden = YES;
    self.startsInLabel.hidden = YES;
    self.waveLabel.hidden = YES;
    position=0;
    diff=0;
    
    [self startLiteShow];
    
    strobeIsOn_ = NO;
	self.strobeActivated = NO;
	strobeFlashOn_ = NO;
    
}

- (void)viewDidUnload {

    [counterUtil invalidateCurrentCountDownTimer];
	AudioSessionSetActive(false);
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark -
#pragma mark CountDownTimer Delegate methods
-(void)timesUpWithLabel:(UILabel *)label
{
    
    self.startsInLabel.hidden = YES;
    self.waveLabel.hidden = YES;
    self.timerLabel.hidden = YES;
    
    strobeIsOn_ = YES;
	self.strobeActivated = YES;
	strobeFlashOn_ = YES;

    position = 0;
    [self playFrames:position];
    
}

#pragma mark -
#pragma mark ShowViewController Playing show methods

- (void)stop
{

    AVCaptureDevice *strobelight = [AVCaptureDevice defaultDeviceWithMediaType:AVMediaTypeVideo];
    if([strobelight isTorchAvailable] && [strobelight isTorchModeSupported:AVCaptureTorchModeOn])
    {
        BOOL success = [strobelight lockForConfiguration:nil];
        if(success)
        {
            [strobelight setTorchMode:AVCaptureTorchModeOff];
            [strobelight unlockForConfiguration];
        }
    }
    
    self.waveLabel.hidden=YES;
    self.waveLabel.text = @"WAVE YOUR PHONE IN THE AIR";
    
    strobeIsOn_ = NO;
    self.strobeActivated = NO;
    strobeFlashOn_ = NO;
    
    [self.strobeTimer invalidate];
    
    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Main" bundle: nil];
    ResultsController *results = [storyboard instantiateViewControllerWithIdentifier:@"results"];
    [self presentViewController:results animated:YES completion:nil];
}

-(void)playFrames:(int)counter{
    //isWinner = YES;
    BOOL winnerLoopFrame = NO;
    NSLog(@"[commandArray count] %i",[commandArray count]);
    if(counter==[commandArray count]){
        //stop the timers when the end is reached and stop the show
        [self stop];
    
    }else{
        //counter = 3;
        vibrateDevice = 1; //vibrate 0=no 1=yes
        strobeDevice = 1;  // strobe 0=no, 1=yes
        pl1 = 0; //play time length in milliseconds
        pl2 = 0; //play time length in milliseconds
        pif = nil; // winner (w) looser (l)
        playType = @"c"; //wait (w) flash (f) color (c) sound (s)
        frameColor = [UIColor blackColor];
        
        NSDictionary *frameDict = [commandArray objectAtIndex:counter];
        NSLog(@"%@", frameDict);
        
        if([frameDict objectForKey:@"v"]){
            vibrateDevice = [[frameDict valueForKey:@"v"] integerValue];
        }
        if([frameDict objectForKey:@"strobe"]){
            strobeDevice = [[frameDict valueForKey:@"strobe"] integerValue];
        }
        
        if([frameDict objectForKey:@"pif"]){
            pif = [frameDict valueForKey:@"pif"];
        }
        
        if([frameDict objectForKey:@"pt"]){
            playType = [frameDict valueForKey:@"pt"];
        }
        
        if([frameDict objectForKey:@"pl2"]){
            pl2 = [[frameDict valueForKey:@"pl2"] integerValue];
        }
        
        if([frameDict objectForKey:@"pl1"]){
            pl1 = [[frameDict valueForKey:@"pl1"] integerValue];
            
            if([playType isEqualToString:@"c"]){
                onORoff=YES;
            }else if([playType isEqualToString:@"w"]){
                onORoff=NO;
            }else if([playType isEqualToString:@"r"]){
                onORoff=YES;
            }else if([playType isEqualToString:@"f"]){
                onORoff=YES;
            }else if([playType isEqualToString:@"s"]){
                onORoff=NO;
            }else if([playType isEqualToString:@"win"]){
                winnerLoopFrame=YES;
                onORoff=NO;
            }else{
                onORoff=NO;
            }
            
            if ((counter+1) == [commandArray count] && isWinner) {
                winnerLoopFrame=YES;
                pif = @"w"; 
            }
            
            if([frameDict objectForKey:@"c"]){
                
                NSString *colorArray = [frameDict objectForKey:@"c"];
                NSArray *colorItems = [colorArray componentsSeparatedByString:@","];
            
                float red = [[colorItems objectAtIndex:0] doubleValue];
                float green = [[colorItems objectAtIndex:1] doubleValue];
                float blue = [[colorItems objectAtIndex:2] doubleValue];
            
                frameColor = [UIColor colorWithRed:red/255.0 green:green/255.0 blue:blue/255.0 alpha:1];

            }else{
                frameColor = [UIColor blackColor];
            }
            
            if([pif isEqualToString:@"w"] && !isWinner){
                //skip frame
                position++;
                [self playFrames:position];
            }else if([pif isEqualToString:@"l"] && isWinner){
                //skip frame
                position++;
                [self playFrames:position];
            }else{
            
                [self onOffSwitch:onORoff];
                position++;
                float timeinterval;
                int extraTime;
                
                if(pl2>0){
                    int randNum;
                    
                    randNum = (pl1 + rand()) % (pl2-pl1); //create the random number.
                    extraTime = pl2 - randNum;
                    
                   // NSNumber numResult = [NSNumber numberWithInt: (arc4random() % pl2) - pl1] + pl1;
                    //timeinterval = [numResult integerValue]/1000;
                    //NSLog(@"pl2 time = %f", timeinterval);
                    
                    timeinterval = randNum/1000.0;
                    NSLog(@"pl1 RANDOM time = %f", timeinterval);
                    self.strobeTimer = [NSTimer scheduledTimerWithTimeInterval:timeinterval target:self selector:@selector(randomTimerCallback:) userInfo:nil repeats:NO];
                }else{
                    timeinterval = pl1/1000.0;
                    NSLog(@"pl1 time = %f", timeinterval);
                    self.strobeTimer = [NSTimer scheduledTimerWithTimeInterval:timeinterval target:self selector:@selector(strobeTimerCallback:) userInfo:nil repeats:NO];
                }
                
                
                if(winnerLoopFrame){
                    frameColor = [UIColor whiteColor];
                    flipper=YES;
                    self.waveLabel.hidden=NO;
                    self.waveLabel.text = @"WINNER";
                    
                    [self.waveLabel setFont:[UIFont systemFontOfSize:70]];
                    
                    self.winnerTimer = [NSTimer scheduledTimerWithTimeInterval:0.5 target:self selector:@selector(winnerTimerCallback:) userInfo:nil repeats:YES];
                }
                
            }
            
                
        }else{ //unknown play time skip frame
            
                position++;
                [self playFrames:position];
                
        }
        
        
    }
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
    self.strobeTimer = [NSTimer scheduledTimerWithTimeInterval:timeInterval target:self selector:@selector(strobeTimerCallback:) userInfo:nil repeats:NO];
    
}

- (void)strobeTimerCallback:(id)sender {
    
    [self.strobeTimer invalidate];
    [self.winnerTimer invalidate];
    [self playFrames:position];
    
}

- (void)winnerTimerCallback:(id)sender {

    flipper = !flipper;
    
    [self winnerAnimation:flipper];
    
}

-(void)winnerAnimation:(BOOL)var
{
    if(var) {
        //screen on
        
        self.view.backgroundColor = frameColor;
        
        if(vibrateDevice==1){
            AudioServicesPlaySystemSound(kSystemSoundID_Vibrate);
        }
        
        AVCaptureDevice *strobelight = [AVCaptureDevice defaultDeviceWithMediaType:AVMediaTypeVideo];
        if([strobelight isTorchAvailable] && [strobelight isTorchModeSupported:AVCaptureTorchModeOn])
        {
            BOOL success = [strobelight lockForConfiguration:nil];
            if(success)
            {
                [strobelight setTorchMode:AVCaptureTorchModeOn];
                [strobelight unlockForConfiguration];
            }
        }
    } else {
        
        //screen off
        self.view.backgroundColor = [UIColor blackColor];
        
        AVCaptureDevice *strobelight = [AVCaptureDevice defaultDeviceWithMediaType:AVMediaTypeVideo];
        if([strobelight isTorchAvailable] && [strobelight isTorchModeSupported:AVCaptureTorchModeOn])
        {
            BOOL success = [strobelight lockForConfiguration:nil];
            if(success)
            {
                [strobelight setTorchMode:AVCaptureTorchModeOff];
                [strobelight unlockForConfiguration];
            }
        }
    }
}


-(void)onOffSwitch:(BOOL)var
{
    if(var) {
        //screen on
        
        self.view.backgroundColor = frameColor;
        
        if(vibrateDevice==1){
            AudioServicesPlaySystemSound(kSystemSoundID_Vibrate);
        }
        
        if(strobeDevice==1) {
            AVCaptureDevice *strobelight = [AVCaptureDevice defaultDeviceWithMediaType:AVMediaTypeVideo];
            if([strobelight isTorchAvailable] && [strobelight isTorchModeSupported:AVCaptureTorchModeOn])
            {
                BOOL success = [strobelight lockForConfiguration:nil];
                if(success)
                {
                    [strobelight setTorchMode:AVCaptureTorchModeOn];
                    [strobelight unlockForConfiguration];
                }
            }
        }
    } else {
        
        //screen off
        self.view.backgroundColor = frameColor;
        
        AVCaptureDevice *strobelight = [AVCaptureDevice defaultDeviceWithMediaType:AVMediaTypeVideo];
        if([strobelight isTorchAvailable] && [strobelight isTorchModeSupported:AVCaptureTorchModeOn])
        {
            BOOL success = [strobelight lockForConfiguration:nil];
            if(success)
            {
                [strobelight setTorchMode:AVCaptureTorchModeOff];
                [strobelight unlockForConfiguration];
            }
        }
    }
}

@end
