//
//  SeatsViewController.m
//  LiteWave
//
//  Created by mike draghici on 10/24/13.
//  Copyright (c) 2013 LiteWave. All rights reserved.
//

#import "SeatsController.h"
#import "AFNetworking.h"
#import "AppDelegate.h"
#import "ReadyController.h"
#import "APIClient.h"

@interface SeatsController ()

-(IBAction)registerUserLocation:(id)sender;

@end

@implementation SeatsController

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.
    
    [seatsPicker setDataSource:self];
    [seatsPicker setDelegate:self];
    
    registerButton.hidden = YES;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)viewDidAppear:(BOOL)animated{
    
    [spinner startAnimating];
    registerButton.hidden = YES;
    self.navigationItem.hidesBackButton = YES;
    
    AppDelegate *appDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    
    if (appDelegate.isOnline) {
    
        [[APIClient instance] getStadiums: ^(id data) {
                                    NSArray *stadiums = [[NSArray alloc] initWithArray:data copyItems:YES];
                                    appDelegate.stadiumID = stadiums[0][@"_id"];
            
                                    [[APIClient instance] getStadium: appDelegate.stadiumID
                                                           onSuccess:^(id data) {
                                                               NSError *error2;
                                                               NSData *jsonData = [NSJSONSerialization dataWithJSONObject:data options:kNilOptions error:&error2];
                                                               NSString *jsonArray = [[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding];
                                                               NSDictionary *seatsDict =
                                                               [NSJSONSerialization JSONObjectWithData: [jsonArray dataUsingEncoding:NSUTF8StringEncoding]
                                                                                               options: NSJSONReadingMutableContainers
                                                                                                 error: &error2];
                                                               
                                                               appDelegate.seatsArray = [[NSDictionary alloc] initWithDictionary:seatsDict copyItems:YES];
                                                               
                                                               sections = [[NSMutableArray alloc] initWithArray:[appDelegate.seatsArray objectForKey:@"sections"]];
                                                               
                                                               rows = [[NSMutableArray alloc] init];
                                                               seats = [[NSMutableArray alloc] init];
                                                               
                                                               pickedSection = FALSE;
                                                               pickedRow = FALSE;
                                                               pickedSeat = FALSE;
                                                               
                                                               selectedSectionIndex = 0;
                                                               selectedRowIndex = 0;
                                                               selectedSeatIndex = 0;
                                                               
                                                               for (int i = 0; i < [sections count]; i++) {
                                                                   
                                                                   sectionDictionary = [sections objectAtIndex:i];
                                                                   
                                                                   if([sectionDictionary objectForKey:@"rows"]){
                                                                       
                                                                       NSArray *tempRowArray = [sectionDictionary objectForKey:@"rows"];
                                                                       [rows addObject:tempRowArray];
                                                                       
                                                                       for (int j = 0; j < [tempRowArray count]; j++) {
                                                                           
                                                                           seatDictionary = [tempRowArray objectAtIndex:j];
                                                                           
                                                                           if([seatDictionary objectForKey:@"seats"]){
                                                                               NSArray *tempSeatArray = [seatDictionary objectForKey:@"seats"];
                                                                               [seats addObject:tempSeatArray];
                                                                           }
                                                                           
                                                                       }
                                                                       
                                                                   }
                                                                   
                                                               }
                                                               
                                                               [seatsPicker reloadAllComponents];
                                                               
                                                               [spinner stopAnimating];
                                                               
                                                               registerButton.hidden = NO;
                                                           }
                                                           onFailure:^(NSError *error) {
                                                               UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Network Error" message:error.localizedDescription delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil];
                                                               [alert show];
                                                               
                                                               [spinner stopAnimating];
                                                               [self.navigationController popViewControllerAnimated:YES];
                                                           }];
                                    
                                                        }
                                                        onFailure:^(NSError *error) {
                                                            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Network Error" message:error.localizedDescription delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil];
                                                            [alert show];
                                                            
                                                            [spinner stopAnimating];
                                                            [self.navigationController popViewControllerAnimated:YES];
                                                        }];
    
    } else {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle: NSLocalizedString(@"Network error", @"Network error")
                                                        message: NSLocalizedString(@"No internet connection found, this application requires an internet connection.", @"Network error") delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil];
        [alert show];
        [spinner stopAnimating];
    }
    
}

// returns the number of 'columns' to display.
- (NSInteger)numberOfComponentsInPickerView:(UIPickerView *)pickerView
{
    if(pickedSection && pickedRow){
        actionTitle.text = @"STEP 3: CHOOSE SEAT";
        return 3;
    }else if(pickedSection && !pickedRow){
        actionTitle.text = @"STEP 2: CHOOSE ROW";
        return 2;
    }else{
        actionTitle.text = @"STEP 1: CHOOSE SECTION";
        return 1;
    }
    
}

// returns the # of rows in each component..
- (NSInteger)pickerView:(UIPickerView *)pickerView numberOfRowsInComponent: (NSInteger)component
{
    
    if(component==0){
        return [sections count]+1;
    }else if(component==1){
        NSArray *tempRowArray = [rows objectAtIndex:selectedSectionIndex];
        return [tempRowArray count]+1;
    }else{
        NSArray *tempSeatArray = [seats objectAtIndex:selectedRowIndex];
        return [tempSeatArray count]+1;
    }
    
}

-(NSString *)pickerView:(UIPickerView *)pickerView titleForRow:(NSInteger)row forComponent:(NSInteger)component
{
    
    if(component==0){
        
        if(row==0){
            return @"SECTION";
        }else{
            NSDictionary *tempSectDictionary = [sections objectAtIndex:row-1];
            NSString *sectionNumber = [tempSectDictionary objectForKey:@"name"];
            return sectionNumber;
        }
        
    }else if(component==1){
        
        if(row==0){
            return @"ROW";
        }else{
            NSArray *tempRowArray = [rows objectAtIndex:selectedSectionIndex];
            NSDictionary *rowDetails = [tempRowArray objectAtIndex:row-1];
            NSString *rowNumber = [rowDetails objectForKey:@"name"];
            return rowNumber;
        }
        
    }else{
        
        if(row==0){
            return @"SEAT";
        }else{
            NSArray *tempSeatArray = [seats objectAtIndex:selectedRowIndex];
            NSDictionary *seatDetails = [tempSeatArray objectAtIndex:row-1];
            NSString *seatNumber = [seatDetails objectForKey:@"name"];
            return seatNumber;
        }
        
    }
    
    
}

- (void)pickerView:(UIPickerView *)pickerView didSelectRow:(NSInteger)row inComponent:(NSInteger)component{
    
    AppDelegate *appDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];

    if(component==0){
        
        if(row==0){
            pickedSection = FALSE;
            appDelegate.sectionID = nil;
            [seatsPicker reloadAllComponents];
        }else{
            selectedSectionIndex = row-1;
            NSDictionary *tempSectDictionary = [sections objectAtIndex:row-1];
            NSString *sectionNumber = [tempSectDictionary objectForKey:@"name"];
            appDelegate.sectionID = sectionNumber;
            pickedSection = TRUE;
            [seatsPicker reloadAllComponents];
        }
        
    }else if(component==1){
        
        if(row==0){
            pickedRow = FALSE;
            appDelegate.rowID = nil;
            [seatsPicker reloadAllComponents];
        }else{
            selectedRowIndex = row-1;
            NSArray *tempRowArray = [rows objectAtIndex:selectedSectionIndex];
            NSDictionary *rowDetails = [tempRowArray objectAtIndex:selectedRowIndex];
            NSString *rowNumber = [rowDetails objectForKey:@"name"];
            appDelegate.rowID = rowNumber;
            pickedRow = TRUE;
            [seatsPicker reloadAllComponents];
        }
        
    }else{
        
        if(row==0){
            pickedSeat = FALSE;
            appDelegate.seatID = nil;
            [seatsPicker reloadAllComponents];
        }else{
            selectedSeatIndex = row-1;
            NSArray *tempSeatArray = [seats objectAtIndex:selectedRowIndex];
            NSDictionary *seatDetails = [tempSeatArray objectAtIndex:selectedSeatIndex];
            NSString *seatNumber = [seatDetails objectForKey:@"name"];
            appDelegate.seatID = seatNumber;
            pickedSeat = TRUE;
        }
        
    }
    
    
}

-(IBAction)registerUserLocation:(id)sender{
    
    AppDelegate *appDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    
    if(appDelegate.isOnline){
    
    if(appDelegate.sectionID!=nil && appDelegate.rowID!=nil && appDelegate.seatID!=nil) {
        
        NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
        
        [defaults setValue:appDelegate.sectionID forKey:@"sectionID"];
        [defaults setValue:appDelegate.rowID forKey:@"rowID"];
        [defaults setValue:appDelegate.seatID forKey:@"seatID"];
        
        [defaults synchronize];
        
        NSDictionary *user_seat = [NSDictionary dictionaryWithObjectsAndKeys:appDelegate.sectionID, @"section", appDelegate.rowID, @"row", appDelegate.seatID, @"seat_number", nil];
        
        NSDictionary *params = [NSDictionary dictionaryWithObjectsAndKeys:
                                appDelegate.uniqueID, @"user_key",
                                user_seat, @"user_seat", nil];

    
        [[APIClient instance] joinEvent: appDelegate.eventID
                                 params: params
                              onSuccess:^(id data) {
                                  NSLog(@"USER ADDED RESPONSE: %@", data);
                                  
                                  NSError *error2;
                                  NSData *jsonData = [NSJSONSerialization dataWithJSONObject:data options:kNilOptions error:&error2];
                                  NSString *jsonArray = [[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding];
                                  
                                  NSDictionary *userDict =
                                  [NSJSONSerialization JSONObjectWithData: [jsonArray dataUsingEncoding:NSUTF8StringEncoding]
                                                                  options: NSJSONReadingMutableContainers
                                                                    error: &error2];
                                  
                                  appDelegate.userID = [userDict objectForKey:@"_id"];
                                  
                                  NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
                                  
                                  [defaults setValue:appDelegate.userID forKey:@"userID"];
                                  
                                  [defaults synchronize];
                                  
                                  UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Main" bundle: nil];
                                  ReadyController *ready = [storyboard instantiateViewControllerWithIdentifier:@"ready"];
                                  [self.navigationController pushViewController:ready animated:YES];

                              }
                              onFailure:^(NSError *error) {
                                  if (error) {
                                      
                                      UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Register Error" message:error.localizedDescription delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil];
                                      [alert show];
                                      
                                  }
                              }];
        
    }else{
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Choose Seat" message:@"Please choose all 3 options to pick your section, row, and seat." delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil];
        [alert show];
    }
        
    }else{
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle: NSLocalizedString(@"Network error", @"Network error")
                                                        message: NSLocalizedString(@"No internet connection found, this application requires an internet connection.", @"Network error") delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil];
        [alert show];
        [spinner stopAnimating];
    }
    
}

@end

