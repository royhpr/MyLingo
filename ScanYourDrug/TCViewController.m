//
//  TCViewController.m
//  ScanYourDrug
//
//  Created by royhpr on 18/11/15.
//  Copyright © 2015 royhpr. All rights reserved.
//

#import "TCViewController.h"

@interface TCViewController ()

@end

@implementation TCViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self setupContent];
}

-(void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:YES];
    [self.navigationController setNavigationBarHidden:YES];
}

-(void)viewDidLayoutSubviews{
    [super viewDidLayoutSubviews];
    [_tcTextView setContentOffset:CGPointZero animated:NO];
}

-(void)setupContent{
    _tcTextView.layer.cornerRadius = 5.0;
    _tcTextView.layer.borderColor = [UIColor lightGrayColor].CGColor;
    _tcTextView.layer.borderWidth = 2.0;
    
    _acceptButton.layer.cornerRadius = 5.0;
    _acceptButton.layer.borderColor = [UIColor lightGrayColor].CGColor;
    _acceptButton.layer.borderWidth = 2.0;
}

- (IBAction)acceptTC:(id)sender {
    [self performSegueWithIdentifier:@"FromTCToScanner" sender:self];
}

-(void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender{
    if([[segue identifier]isEqualToString:@"FromTCToScanner"]){
        //Store the T&C to local storage
        [GlobalSharingCentre agreeToTC];
    }
}

#pragma mark - for interface rotation
- (BOOL)shouldAutorotate{
    return YES;
}

- (UIInterfaceOrientationMask)supportedInterfaceOrientations{
    return UIInterfaceOrientationMaskPortrait;
}

- (UIInterfaceOrientation)preferredInterfaceOrientationForPresentation{
    return UIInterfaceOrientationPortrait;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
