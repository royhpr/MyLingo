//
//  HistoryViewController.h
//  ScanYourDrug
//
//  Created by royhpr on 19/11/15.
//  Copyright © 2015 royhpr. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "GlobalSharingCentre.h"
#import "HistoryModel.h"
#import "TranslaterViewController.h"

@interface HistoryViewController : UIViewController <UITableViewDataSource, UITableViewDelegate, UISearchBarDelegate>
@property (weak, nonatomic) IBOutlet UITableView *myTableView;
@property (weak, nonatomic) IBOutlet UISearchBar *mySearchBar;

@property(nonatomic)BOOL isFromScanner;

@end
