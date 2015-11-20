//
//  ScannerViewController.h
//  ScanYourDrug
//
//  Created by royhpr on 16/11/15.
//  Copyright © 2015 royhpr. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <AVFoundation/AVFoundation.h>
#import <CoreLocation/CoreLocation.h>
#import "TranslaterViewController.h"
#import "GlobalSharingCentre.h"
#import "HistoryViewController.h"

@interface ScannerViewController : UIViewController<AVCaptureMetadataOutputObjectsDelegate, UIAlertViewDelegate, CLLocationManagerDelegate>{
    CLLocationManager *locationManager;
    CLGeocoder *geocoder;
    CLPlacemark *placemark;
}

@property (weak, nonatomic) IBOutlet UIView *myScannerView;
@property (weak, nonatomic) IBOutlet UIImageView *historyImageView;

@end
