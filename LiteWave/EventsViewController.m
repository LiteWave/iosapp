//
//  EventsViewController.m
//  LiteWave
//
//  Created by mike draghici on 10/24/13.
//  Copyright (c) 2013 LiteWave. All rights reserved.
//

#import "EventsViewController.h"
#import "AFNetworking.h"
#import "APIClient.h"
#import "LiteWaveAppDelegate.h"
#import "SeatsViewController.h"

@interface EventsViewController ()

-(IBAction)continueToNextPage:(id)sender;

@end

@implementation EventsViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.
    
    [eventsPicker setDataSource:self];
    [eventsPicker setDelegate:self];
    continueBtn.hidden = YES;
    
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)viewDidAppear:(BOOL)animated{
    
    [self.navigationItem setHidesBackButton:YES animated:NO];
    
    [spinner startAnimating];
    continueBtn.hidden = YES;
    LiteWaveAppDelegate *appDelegate = (LiteWaveAppDelegate *)[[UIApplication sharedApplication] delegate];
    
    if (appDelegate.isOnline){
       
        [[APIClient instance] getEvents:appDelegate.clientID
                              onSuccess:^(id data) {
                                  appDelegate.eventsArray = [[NSArray alloc] initWithArray:data copyItems:YES];
                                  
                                  [eventsPicker reloadAllComponents];
                                  
                                  [spinner stopAnimating];
                                  continueBtn.hidden = NO;
                              }
                              onFailure:^(NSError *error) {
                                  UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Network Error" message:error.localizedDescription delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil];
                                  [alert show];
                                  
                                  [spinner stopAnimating];
                              }];

    }else{
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle: NSLocalizedString(@"Network error", @"Network error")
                                                        message: NSLocalizedString(@"No internet connection found, this application requires an internet connection.", @"Network error") delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil];
        [alert show];
        [spinner stopAnimating];
    }
}

// returns the number of 'columns' to display.
- (NSInteger)numberOfComponentsInPickerView:(UIPickerView *)pickerView
{
    return 1;
    
}

// returns the # of rows in each component..
- (NSInteger)pickerView:(UIPickerView *)pickerView numberOfRowsInComponent: (NSInteger)component
{
    LiteWaveAppDelegate *appDelegate = (LiteWaveAppDelegate *)[[UIApplication sharedApplication] delegate];
    //NSLog(@"found %i items", [appDelegate.eventsArray count]);
    return [appDelegate.eventsArray count];
    
}

-(NSString *)pickerView:(UIPickerView *)pickerView titleForRow:(NSInteger)row forComponent:(NSInteger)component
{
    return @"";
    
}

- (void)pickerView:(UIPickerView *)pickerView didSelectRow:(NSInteger)row inComponent:(NSInteger)component{
    
    LiteWaveAppDelegate *appDelegate = (LiteWaveAppDelegate *)[[UIApplication sharedApplication] delegate];
    
    NSDictionary *event = [appDelegate.eventsArray objectAtIndex:row];
    
    appDelegate.eventID = [event valueForKey:@"_id"];
    appDelegate.stadiumID = [event valueForKey:@"_stadiumId"];
    appDelegate.eventName = [event valueForKey:@"name"];
    
    NSDateFormatter *dateformat = [[NSDateFormatter alloc] init];
    [dateformat setDateFormat:@"yyyy-MM-dd'T'HH:mm:ss'.000Z'"];
    [dateformat setTimeZone:[NSTimeZone timeZoneWithName:@"GMT"]];
    
    appDelegate.eventDate = [dateformat dateFromString:[event valueForKey:@"event_at"]];
    
    //NSLog(@"%@", appDelegate.eventDate);
    
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    
    [defaults setValue:appDelegate.eventID forKey:@"eventID"];
    [defaults setValue:appDelegate.stadiumID forKey:@"stadiumID"];
    [defaults setValue:appDelegate.eventName forKey:@"eventName"];
    [defaults setObject:appDelegate.eventDate forKey:@"eventDate"];
    
    [defaults synchronize];
    
}

- (UIView *)pickerView:(UIPickerView *)pickerView
            viewForRow:(NSInteger)row
          forComponent:(NSInteger)component
           reusingView:(UIView *)view {
    
    LiteWaveAppDelegate *appDelegate = (LiteWaveAppDelegate *)[[UIApplication sharedApplication] delegate];
    
    NSDictionary *event = [appDelegate.eventsArray objectAtIndex:row];
    
    appDelegate.eventID = [event valueForKey:@"_id"];
    appDelegate.stadiumID = [event valueForKey:@"_stadiumId"];
    appDelegate.eventName = [event valueForKey:@"name"];
    
    NSDateFormatter *dateformat = [[NSDateFormatter alloc] init];
    [dateformat setDateFormat:@"yyyy-MM-dd'T'HH:mm:ss'.000Z'"];
    [dateformat setTimeZone:[NSTimeZone timeZoneWithName:@"GMT"]];
    
    appDelegate.eventDate = [dateformat dateFromString:[event valueForKey:@"eventAt"]];
    
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    
    [defaults setValue:appDelegate.eventID forKey:@"eventID"];
    [defaults setValue:appDelegate.stadiumID forKey:@"stadiumID"];
    [defaults setValue:appDelegate.eventName forKey:@"eventName"];
    [defaults setObject:appDelegate.eventDate forKey:@"eventDate"];
    
    [defaults synchronize];
    
    NSDateFormatter *dateformatPicker = [[NSDateFormatter alloc] init];
    [dateformatPicker setDateFormat:@"MMM d yyyy"];
    
    NSString *pickerItemText = [NSString stringWithFormat:@"%@\n%@",[event valueForKey:@"name"],[dateformatPicker stringFromDate:appDelegate.eventDate]];
    
    UILabel *pickerLabel = (UILabel *)view;
    
    if (pickerLabel == nil) {
        CGRect frame = CGRectMake(0.0, 0.0, eventsPicker.frame.size.width-40, 64);
        pickerLabel = [[UILabel alloc] initWithFrame:frame];
        [pickerLabel setBackgroundColor:[UIColor clearColor]];
        [pickerLabel setFont:[UIFont boldSystemFontOfSize:15]];
        pickerLabel.numberOfLines = 2;
    }
    
    [pickerLabel setText:pickerItemText];
    
    return pickerLabel;
    
}

- (CGFloat)pickerView:(UIPickerView *)pickerView rowHeightForComponent:(NSInteger)component{
    return 70.0f;
}

-(IBAction)continueToNextPage:(id)sender{
    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Main" bundle: nil];
    SeatsViewController *seats = [storyboard instantiateViewControllerWithIdentifier:@"seats"];
    [self.navigationController pushViewController:seats animated:YES];
}

@end
