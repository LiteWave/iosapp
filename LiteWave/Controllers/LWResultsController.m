//
//  ResultsViewController.m
//  LiteWave
//
//  Created by mike draghici on 10/24/13.
//  Copyright (c) 2013 LiteWave. All rights reserved.
//

#import "LWResultsController.h"
#import "LWAppDelegate.h"

@implementation LWResultsController

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.

    [self.navigationItem setHidesBackButton:YES animated:NO];
    
    self.appDelegate = (LWAppDelegate *)[[UIApplication sharedApplication] delegate];
    
    NSString *winnerID = [self.appDelegate.show valueForKey:@"_winnerId"];
    if (winnerID != (id)[NSNull null] && [winnerID isEqualToString:self.appDelegate.userID]) {
        isWinner=YES;
    } else {
        isWinner=NO;
    }
    
    imageView.hidden = YES;
    participationLabel.hidden = YES;
    
    [self prepareView];
}

-(void)viewDidAppear:(BOOL)animated {
    
    [self.navigationItem setHidesBackButton:YES animated:NO];
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    
    self.appDelegate.show = nil;
    self.appDelegate.showData = nil;
    
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    [defaults removeObjectForKey:@"show"];
    [defaults removeObjectForKey:@"showData"];
    
    [defaults synchronize];
    
    [returnButton removeTarget:nil
                       action:NULL
             forControlEvents:UIControlEventAllEvents];
    
    for (UIGestureRecognizer *recognizer in self.view.gestureRecognizers) {
        [self.view removeGestureRecognizer:recognizer];
    }
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void)prepareView {
    
    if (isWinner) {
        NSString *winnerImageURL = [self.appDelegate.show valueForKey:@"winnerImageUrl"];
        if (winnerImageURL != (id)[NSNull null]) {
            NSURL *url = [NSURL URLWithString:winnerImageURL];
            NSData *data = [NSData dataWithContentsOfURL:url];
            UIImage *image = [[UIImage alloc] initWithData:data];
            
            CGFloat imageRatio = image.size.height / image.size.width;
            imageView.image = image;
            imageView.frame = CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.width * imageRatio);
            UITapGestureRecognizer *tapRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(onImageSelect)];
            [imageView addGestureRecognizer:tapRecognizer];
            imageView.userInteractionEnabled = YES;
            
            participationLabel.hidden = YES;
        }
    } else {
        participationLabel.hidden = NO;
    }

    imageView.hidden = NO;
    
    returnButton.frame = CGRectMake(0,
                                  self.view.bounds.size.height - 50,
                                  self.view.bounds.size.width,
                                  50);
    returnButton.layer.borderColor=self.appDelegate.highlightColor.CGColor;
    returnButton.layer.backgroundColor=self.appDelegate.highlightColor.CGColor;
    returnButton.layer.borderWidth=2.0f;
    
    [returnButton setTitleColor:[UIColor colorWithRed:255.0/255.0 green:255.0/255.0 blue:255.0/255.0 alpha:1.0] forState:UIControlStateNormal];
    
    [returnButton addTarget:self action:@selector(onReturnSelect) forControlEvents:UIControlEventTouchUpInside];
}

-(void)onImageSelect
{
    NSString *winnerURL = [self.appDelegate.show valueForKey:@"winnerUrl"];
    if (winnerURL != (id)[NSNull null]) {
        [[UIApplication sharedApplication] openURL:[NSURL URLWithString:winnerURL]];
    }
}

-(void)onReturnSelect
{
    [self.presentingViewController dismissViewControllerAnimated:YES completion:nil];
    [self.presentingViewController dismissViewControllerAnimated:YES completion:nil];
}

@end
