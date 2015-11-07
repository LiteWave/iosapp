//
//  LWResultsController.m
//  LiteWave
//
//  Created by david anderson on 08/24/15.
//  Copyright (c) 2013 LiteWave. All rights reserved.
//

#import "LWResultsController.h"
#import "LWAppDelegate.h"
#import "LWConfiguration.h"

@implementation LWResultsController

- (void)viewDidLoad
{
    [super viewDidLoad];

    self.appDelegate = (LWAppDelegate *)[[UIApplication sharedApplication] delegate];
    
    NSString *winnerID = [[LWConfiguration instance].showData valueForKey:@"_winnerId"];
    if (winnerID != (id)[NSNull null] && [winnerID isEqualToString:[LWConfiguration instance].userLocationID]) {
        isWinner=YES;
    } else {
        isWinner=NO;
    }
    self.view.backgroundColor = [LWConfiguration instance].backgroundColor;
    
    imageView.hidden = YES;
    participationLabel.hidden = YES;
    logoImageView.hidden = YES;
    poweredByLabel.hidden = YES;
    
    [self prepareView];
}

-(void)viewDidAppear:(BOOL)animated {
    
    [self.navigationItem setHidesBackButton:YES animated:NO];
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    
    [LWConfiguration instance].show = nil;
    [LWConfiguration instance].showData = nil;
    
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    [defaults removeObjectForKey:@"show"];
    [defaults removeObjectForKey:@"showData"];
    
    [defaults synchronize];
    
    // cleanup
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
        NSString *winnerImageURL = [[LWConfiguration instance].show valueForKey:@"winnerImageUrl"];
        if (winnerImageURL != (id)[NSNull null]) {
            NSURL *url = [NSURL URLWithString:winnerImageURL];
            NSData *data = [NSData dataWithContentsOfURL:url];
            UIImage *image = [[UIImage alloc] initWithData:data];
            
            CGFloat imageRatio;
            float size;
            if (image.size.width > image.size.height) {
                imageRatio = image.size.width / image.size.height;
                size = self.view.frame.size.height * imageRatio;
                imageView.frame = CGRectMake(self.view.frame.size.width/2 - size/2, 0, size, self.view.frame.size.height);
            } else {
                imageRatio = image.size.height / image.size.width;
                size = self.view.frame.size.width * imageRatio;
                imageView.frame = CGRectMake(0, self.view.frame.size.height/2 - size/2, self.view.frame.size.width, size);
            }
            imageView.image = image;
            UITapGestureRecognizer *tapRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(onImageSelect)];
            [imageView addGestureRecognizer:tapRecognizer];
            imageView.userInteractionEnabled = YES;
            
            participationLabel.hidden = YES;
        }
    } else {
        [self loadImage];
        
        logoImageView.frame = CGRectMake(logoImageView.frame.origin.x,
                                         self.view.frame.size.height - logoImageView.frame.size.height - 65,
                                         logoImageView.frame.size.width,
                                         logoImageView.frame.size.height);
        logoImageView.hidden = NO;
        
        poweredByLabel.frame = CGRectMake(poweredByLabel.frame.origin.x,
                                          logoImageView.frame.origin.y - 20,
                                          poweredByLabel.frame.size.width,
                                          poweredByLabel.frame.size.height);
        poweredByLabel.hidden = NO;
        
        participationLabel.textColor = [LWConfiguration instance].textColor;
        participationLabel.hidden = NO;
    }

    imageView.hidden = NO;
    
    returnButton.frame = CGRectMake(0,
                                  self.view.bounds.size.height - 50,
                                  self.view.bounds.size.width,
                                  50);
    returnButton.layer.borderColor=[LWConfiguration instance].highlightColor.CGColor;
    returnButton.layer.backgroundColor=[LWConfiguration instance].highlightColor.CGColor;
    returnButton.layer.borderWidth=2.0f;
    [returnButton setTitleColor:[UIColor colorWithRed:255.0/255.0 green:255.0/255.0 blue:255.0/255.0 alpha:1.0] forState:UIControlStateNormal];
    [returnButton addTarget:self action:@selector(onReturnSelect) forControlEvents:UIControlEventTouchUpInside];
}

- (void)loadImage
{
    if (![LWConfiguration instance].logoUrl || ![LWConfiguration instance].logoImage)
        return;
    
    float height = 700;
    float width = ([LWConfiguration instance].logoImage.size.width*height)/[LWConfiguration instance].logoImage.size.height;
    imageView.frame = CGRectMake(self.view.frame.size.width/2 - width/2, self.view.frame.size.height/2 - height/2, width, height);
    imageView.image = [LWConfiguration instance].logoImage;
    imageView.alpha = .05;
    imageView.hidden = NO;
}

-(void)onImageSelect
{
    NSString *winnerURL = [[LWConfiguration instance].show valueForKey:@"winnerUrl"];
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
