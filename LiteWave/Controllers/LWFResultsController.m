//
//  LWResultsController.m
//  LiteWave
//
//  Copyright (c) 2013 LiteWave. All rights reserved.
//

#import "LWFResultsController.h"
#import "LWFAppDelegate.h"
#import "LWFConfiguration.h"
#import "LWFUtility.h"

@implementation LWFResultsController

- (void)viewDidLoad
{
    [super viewDidLoad];

    self.appDelegate = (LWFAppDelegate *)[[UIApplication sharedApplication] delegate];
    created = NO;
    
    NSString *winnerID = [[LWFConfiguration instance].showData valueForKey:@"_winnerId"];
    if (winnerID != (id)[NSNull null] && [winnerID isEqualToString:[LWFConfiguration instance].userLocationID]) {
        isWinner=YES;
    } else {
        isWinner=NO;
    }
    self.view.backgroundColor = [UIColor blackColor];
    
    imageView.hidden = YES;
    participationLabel.hidden = YES;
    logoImageView.hidden = YES;
    poweredByLabel.hidden = YES;
    returnButton.hidden = YES;
}

-(void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear: animated];
    
    [self.navigationItem setHidesBackButton:YES animated:NO];
    
    appSize = [LWFUtility determineAppSize:self];
    if (!created) {
        created = YES;
        [self prepareView];
    }
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    
    [LWFConfiguration instance].show = nil;
    [LWFConfiguration instance].showData = nil;
    
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
    
    returnButton.frame = CGRectMake(0,
                                    appSize.height - 50,
                                    appSize.width,
                                    50);
    returnButton.layer.borderColor=[LWFConfiguration instance].highlightColor.CGColor;
    returnButton.layer.backgroundColor=[LWFConfiguration instance].highlightColor.CGColor;
    returnButton.layer.borderWidth=2.0f;
    returnButton.hidden = NO;
    [returnButton setTitleColor:[UIColor colorWithRed:255.0/255.0 green:255.0/255.0 blue:255.0/255.0 alpha:1.0] forState:UIControlStateNormal];
    [returnButton addTarget:self action:@selector(onReturnSelect) forControlEvents:UIControlEventTouchUpInside];
    
    float returnHeight = returnButton.frame.size.height;
    if (isWinner) {
        NSString *winnerImageURL = [[LWFConfiguration instance].show valueForKey:@"winnerImageUrl"];
        if (winnerImageURL != (id)[NSNull null]) {
            NSURL *url = [NSURL URLWithString:winnerImageURL];
            NSData *data = [NSData dataWithContentsOfURL:url];
            UIImage *image = [[UIImage alloc] initWithData:data];
            
            float newWidth = appSize.width;
            float newHeight = newWidth*image.size.height/image.size.width;
            imageView.frame = CGRectMake(appSize.width/2 - newWidth/2,
                                         (appSize.height-returnHeight/2)/2 - newHeight/2,
                                         newWidth,
                                         newHeight);
            
            imageView.image = image;
            imageView.hidden = NO;
            UITapGestureRecognizer *tapRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(onImageSelect)];
            [imageView addGestureRecognizer:tapRecognizer];
            imageView.userInteractionEnabled = YES;
            
            participationLabel.hidden = YES;
        }
    } else {
        self.view.backgroundColor = [LWFConfiguration instance].backgroundColor;
        [self loadImage];
        
        logoImageView.frame = CGRectMake(appSize.width/2 - logoImageView.frame.size.width/2,
                                         appSize.height - logoImageView.frame.size.height - 20 - returnHeight,
                                         logoImageView.frame.size.width,
                                         logoImageView.frame.size.height);
        logoImageView.hidden = NO;
        
        poweredByLabel.frame = CGRectMake(0,
                                          logoImageView.frame.origin.y - 20,
                                          appSize.width,
                                          poweredByLabel.frame.size.height);
        poweredByLabel.hidden = NO;

        [participationLabel setFont:[UIFont fontWithName:@"HelveticaNeue" size:appSize.width*.075]];
        participationLabel.textColor = [LWFConfiguration instance].textColor;
        participationLabel.hidden = NO;
        participationLabel.frame = CGRectMake(0,
                                     appSize.height*.04,
                                     appSize.width,
                                     participationLabel.frame.size.height);
    }
}

- (void)loadImage
{
    if (![LWFConfiguration instance].logoUrl || ![LWFConfiguration instance].logoImage)
        return;
    
    float height = appSize.height*1.18; // make image 118% of view
    float width = ([LWFConfiguration instance].logoImage.size.width*height)/[LWFConfiguration instance].logoImage.size.height;
    imageView.frame = CGRectMake(appSize.width/2 - width/2, appSize.height/2 - height/2, width, height);
    imageView.image = [LWFConfiguration instance].logoImage;
    imageView.alpha = .05;
    imageView.hidden = NO;
}

-(void)onImageSelect
{
    NSString *winnerURL = [[LWFConfiguration instance].show valueForKey:@"winnerUrl"];
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
