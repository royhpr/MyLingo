//
//  TCViewController.h
//  ScanYourDrug
//
//  Created by royhpr on 18/11/15.
//  Copyright © 2015 royhpr. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "GlobalSharingCentre.h"

@interface TCViewController : UIViewController

@property (weak, nonatomic) IBOutlet UIButton *acceptButton;
- (IBAction)acceptTC:(id)sender;
@property (weak, nonatomic) IBOutlet UITextView *tcTextView;

@end
