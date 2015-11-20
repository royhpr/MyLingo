//
//  TranslaterViewController.h
//  ScanYourDrug
//
//  Created by royhpr on 16/11/15.
//  Copyright © 2015 royhpr. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface TranslaterViewController : UIViewController<UIPickerViewDataSource, UIPickerViewDelegate, UIWebViewDelegate>

@property(nonatomic, strong)NSString *drugName;

@property (weak, nonatomic) IBOutlet UILabel *drugNameLabel;
@property (weak, nonatomic) IBOutlet UIImageView *historyImageView;
@property (weak, nonatomic) IBOutlet UIWebView *myWebView;

@end
