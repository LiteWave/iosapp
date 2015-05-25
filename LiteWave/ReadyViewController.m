//
//  ReadyViewController.m
//  LiteWave
//
//  Created by mike draghici on 10/24/13.
//  Copyright (c) 2013 LiteWave. All rights reserved.
//

#import "ReadyViewController.h"
#import "LiteWaveAppDelegate.h"
#import "AFNetworking.h"

@interface ReadyViewController ()

-(IBAction)withdrawUser:(id)sender;
-(IBAction)retryFetch:(id)sender;

@end

@implementation ReadyViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.
    playBtn.enabled = NO;
    retryBtn.hidden = YES;
    [self.navigationItem setHidesBackButton:YES animated:NO];
}

-(void)fetchShow{
    
    playBtn.enabled = NO;
    retryBtn.hidden = YES;
    
    LiteWaveAppDelegate *appDelegate = (LiteWaveAppDelegate *)[[UIApplication sharedApplication] delegate];
    
    if(appDelegate.liteShow){
        
        NSLog(@"saved liteshow = %@", appDelegate.liteShow);
        
        playBtn.enabled = YES;
        retryBtn.hidden = YES;
    }else{
        
        if(appDelegate.isOnline){
        NSURL *requestURL = [[NSURL alloc] initWithString:[NSString stringWithFormat:@"http://127.0.0.1:3000/api/lw_events/%@/event_liteshows",appDelegate.eventID]];
        
        //NSLog(@"get all liteshows %@",requestURL.absoluteString);
        
        NSURLRequest *request = [NSURLRequest requestWithURL:requestURL];
        
        AFJSONRequestOperation *operation =
        [AFJSONRequestOperation JSONRequestOperationWithRequest:request
                                                        success:^(NSURLRequest *request, NSHTTPURLResponse *response, id JSON) {
                                                            
                                                            NSError *error2;
                                                            NSData *jsonData = [NSJSONSerialization dataWithJSONObject:JSON options:kNilOptions error:&error2];
                                                            NSString *jsonArray = [[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding];
                                                            
                                                            NSArray *showDict =
                                                            [NSJSONSerialization JSONObjectWithData: [jsonArray dataUsingEncoding:NSUTF8StringEncoding]
                                                                                            options: NSJSONReadingMutableContainers
                                                                                              error: &error2];
                                                            
                                                            appDelegate.liteshowArray = [[NSArray alloc] initWithArray:showDict copyItems:YES];
                                                            
                                                            NSDictionary *liteShowDict = [appDelegate.liteshowArray objectAtIndex:0];
                                                            
                                                            NSString *liteShowID = [liteShowDict valueForKey:@"_id"];
                                                            
                                                            NSURL *requestURL = [[NSURL alloc] initWithString:[NSString stringWithFormat:@"http://127.0.0.1:3000/api/event_liteshows/%@/user_locations/%@/liteshow",liteShowID, appDelegate.userID]];
                                                            
                                                            NSLog(@"get liteshow %@",requestURL.absoluteString);
                                                            
                                                            NSURLRequest *secondrequest = [NSURLRequest requestWithURL:requestURL];
                                                            
                                                            AFJSONRequestOperation *operation =
                                                            [AFJSONRequestOperation JSONRequestOperationWithRequest:secondrequest
                                                                                                            success:^(NSURLRequest *request, NSHTTPURLResponse *response, id JSON) {
                                                                                                                
                                                                                                                NSError *error2;
                                                                                                                NSData *jsonData = [NSJSONSerialization dataWithJSONObject:JSON options:kNilOptions error:&error2];
                                                                                                                NSString *jsonArray = [[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding];
                                                                                                                
                                                                                                                NSDictionary *showDict =
                                                                                                                [NSJSONSerialization JSONObjectWithData: [jsonArray dataUsingEncoding:NSUTF8StringEncoding]
                                                                                                                                                options: NSJSONReadingMutableContainers
                                                                                                                                                  error: &error2];
                                                                                                                
                                                                                                                appDelegate.liteShow = [[NSDictionary alloc] initWithDictionary:showDict copyItems:YES];
                                                                                                                
                                                                                                                NSLog(@"new liteshow = %@", appDelegate.liteShow);
                                                                                                                
                                                                                                                playBtn.enabled = YES;
                                                                                                                retryBtn.hidden = YES;
                                                                                                                
                                                                                                            }
                                                                                                            failure:^(NSURLRequest *request, NSHTTPURLResponse *response, NSError *error) {
                                                                                                                
                                                                                                                appDelegate.liteShow = nil;
                                                                                                                
                                                                                                                playBtn.enabled = NO;
                                                                                                                
                                                                                                                UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"No Show Available" message:@"There is no show available at this time for this event." delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil];
                                                                                                                [alert show];
                                                                                                                
                                                                                                                retryBtn.hidden = NO;
                                                                                                                
                                                                                                            }];
                                                            
                                                            [operation start];
                                                            
                                                        }
                                                        failure:^(NSURLRequest *request, NSHTTPURLResponse *response, NSError *error) {
                                                            
                                                            appDelegate.liteShow = nil;
                                                            
                                                            playBtn.enabled = NO;
                                                            
                                                            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"No Shows Available" message:@"There is no shows available at this time for this event." delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil];
                                                            [alert show];
                                                            
                                                            retryBtn.hidden = NO;
                                                            
                                                        }];
        
        [operation start];
            
        }else{
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle: NSLocalizedString(@"Network error", @"Network error")
                                                            message: NSLocalizedString(@"No internet connection found, this application requires an internet connection.", @"Network error") delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil];
            [alert show];
        }
        
    }

}

- (void)viewDidAppear:(BOOL)animated{
    
    [self.navigationItem setHidesBackButton:YES animated:NO];
    
    LiteWaveAppDelegate *appDelegate = (LiteWaveAppDelegate *)[[UIApplication sharedApplication] delegate];
    
    eventName.text = appDelegate.eventName;
    mySeat.text = [NSString stringWithFormat:@"%@-%@-%@",appDelegate.sectionID,appDelegate.rowID,appDelegate.seatID];
    
    if(appDelegate.invalidShowAlert){
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle: @"Show Unavailable"
                                                        message: @"This show is not available or has expired. Please try again later." delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil];
        [alert show];
        appDelegate.invalidShowAlert=NO;
    }else{
        [self fetchShow];
    }
    
}

-(IBAction)withdrawUser:(id)sender{
    
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Withdraw From Show" message:@"Are you sure you want to withdraw from this show?" delegate:self cancelButtonTitle:@"NO" otherButtonTitles:@"YES", nil];
    [alert show];
    
}

-(IBAction)retryFetch:(id)sender{
    
    [self fetchShow];
    
}

- (void)alertView:(UIAlertView *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex {
    
    if (buttonIndex == 0)
    {
        //do nothing
    }
    else
    {
        LiteWaveAppDelegate *appDelegate = (LiteWaveAppDelegate *)[[UIApplication sharedApplication] delegate];
        
        appDelegate.sectionID = nil;
        appDelegate.rowID = nil;
        appDelegate.seatID = nil;
        appDelegate.userID = nil;
        appDelegate.liteShow = nil;
        
        NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
        
        [defaults removeObjectForKey:@"sectionID"];
        [defaults removeObjectForKey:@"rowID"];
        [defaults removeObjectForKey:@"seatID"];
        [defaults removeObjectForKey:@"userID"];
        [defaults removeObjectForKey:@"liteShow"];
        
        [defaults synchronize];
        
        [self.navigationController popToRootViewControllerAnimated:YES];
    }
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
