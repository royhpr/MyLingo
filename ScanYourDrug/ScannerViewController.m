//
//  ScannerViewController.m
//  ScanYourDrug
//
//  Created by royhpr on 16/11/15.
//  Copyright © 2015 royhpr. All rights reserved.
//

#import "ScannerViewController.h"

@interface ScannerViewController ()

@property(nonatomic, strong)NSString *capturedText;
@property(nonatomic)BOOL isScanned;

@property (nonatomic, strong) AVCaptureSession *captureSession;
@property (nonatomic, strong) AVCaptureVideoPreviewLayer *videoPreviewLayer;

@property(nonatomic, strong)UIImageView *scannerContainer;

@property(nonatomic, strong)NSString *currentLatitude;
@property(nonatomic, strong)NSString *currentLongitude;
@property(nonatomic, strong)NSString *currentAddress;

@end

@implementation ScannerViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self setupHistoryButton];
    [self setupLocationManager];

    _isScanned = NO;
}

-(void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:YES];
    [self.navigationController setNavigationBarHidden:YES];
}

-(void)viewDidAppear:(BOOL)animated{
    [super viewDidAppear:YES];
    
    //Start reading
    [self showQRScanner];
    [self setupContainer];
    
    [locationManager startUpdatingLocation];
}

-(void)viewDidDisappear:(BOOL)animated{
    [super viewDidDisappear:YES];
    [locationManager stopUpdatingLocation];
}

-(void)setupLocationManager{
    locationManager = [[CLLocationManager alloc] init];
    locationManager.delegate = self;
    locationManager.desiredAccuracy = kCLLocationAccuracyBest;
    
    if ([locationManager respondsToSelector:@selector(requestWhenInUseAuthorization)]) {
        [locationManager requestWhenInUseAuthorization];
    }
    
    geocoder = [[CLGeocoder alloc] init];
}

-(void)setupHistoryButton{
    UITapGestureRecognizer *historySingleTap = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(showHistory)];
    [historySingleTap setNumberOfTapsRequired:1];
    [historySingleTap setNumberOfTouchesRequired:1];
    
    [_historyImageView addGestureRecognizer:historySingleTap];
}

-(void)setupContainer{
    if(_scannerContainer == nil){
        CGFloat containerSize = _myScannerView.frame.size.width * 0.8;
        _scannerContainer = [[UIImageView alloc]initWithFrame:CGRectMake((_myScannerView.frame.size.width - containerSize)/2.0, (_myScannerView.frame.size.height - containerSize)/2.0, containerSize, containerSize)];
        [_scannerContainer setImage:[UIImage imageNamed:@"qrcontainer"]];
        [_scannerContainer setContentMode:UIViewContentModeScaleAspectFit];
        
        [_myScannerView addSubview:_scannerContainer];
    }
    else{
//        CGFloat containerSize = _myScannerView.frame.size.width * 0.8;
//        [_scannerContainer setFrame:CGRectMake((_myScannerView.frame.size.width - containerSize)/2.0, (_myScannerView.frame.size.height - containerSize)/2.0, containerSize, containerSize)];
        [_myScannerView bringSubviewToFront:_scannerContainer];
    }
}

-(void)showHistory{
    [self performSegueWithIdentifier:@"FromScannerToHistory" sender:self];
}

-(void)showQRScanner{
    NSError *error;
    
    // Get an instance of the AVCaptureDevice class to initialize a device object and provide the video
    // as the media type parameter.
    AVCaptureDevice *captureDevice = [AVCaptureDevice defaultDeviceWithMediaType:AVMediaTypeVideo];
    
    // Get an instance of the AVCaptureDeviceInput class using the previous device object.
    AVCaptureDeviceInput *input = [AVCaptureDeviceInput deviceInputWithDevice:captureDevice error:&error];
    
    if (!input) {
        // If any error occurs, simply log the description of it and don't continue any more.
        UIAlertController * alert=   [UIAlertController
                                      alertControllerWithTitle:@"Ooops, we have problem in accessing your device's camera"
                                      message:nil
                                      preferredStyle:UIAlertControllerStyleAlert];
        
        UIAlertAction* yesButton = [UIAlertAction
                                    actionWithTitle:@"Got it"
                                    style:UIAlertActionStyleDefault
                                    handler:^(UIAlertAction * action){
                                        //Handel your yes please button action here
                                        [alert dismissViewControllerAnimated:YES completion:nil];
                                    }];
        
        [alert addAction:yesButton];
        [self presentViewController:alert animated:YES completion:nil];
        return;
    }
    
    if(_captureSession == nil){
        // Initialize the captureSession object.
        _captureSession = [[AVCaptureSession alloc] init];
        // Set the input device on the capture session.
        [_captureSession addInput:input];
        
        // Initialize a AVCaptureMetadataOutput object and set it as the output device to the capture session.
        AVCaptureMetadataOutput *captureMetadataOutput = [[AVCaptureMetadataOutput alloc] init];
        [_captureSession addOutput:captureMetadataOutput];
        
        // Create a new serial dispatch queue.
        dispatch_queue_t dispatchQueue;
        dispatchQueue = dispatch_queue_create("myQueue", NULL);
        [captureMetadataOutput setMetadataObjectsDelegate:self queue:dispatchQueue];
        
        NSArray *barCodeTypes = @[AVMetadataObjectTypeUPCECode, AVMetadataObjectTypeCode39Code, AVMetadataObjectTypeCode39Mod43Code,
                                  AVMetadataObjectTypeEAN13Code, AVMetadataObjectTypeEAN8Code, AVMetadataObjectTypeCode93Code, AVMetadataObjectTypeCode128Code,
                                  AVMetadataObjectTypePDF417Code, AVMetadataObjectTypeQRCode, AVMetadataObjectTypeAztecCode];
        [captureMetadataOutput setMetadataObjectTypes:barCodeTypes];
        
        // Initialize the video preview layer and add it as a sublayer to the viewPreview view's layer.
        _videoPreviewLayer = [[AVCaptureVideoPreviewLayer alloc] initWithSession:_captureSession];
        [_videoPreviewLayer setVideoGravity:AVLayerVideoGravityResizeAspectFill];
        [_videoPreviewLayer setFrame:_myScannerView.layer.bounds];
        [_myScannerView.layer addSublayer:_videoPreviewLayer];
        
        // Start video capture.
        [_captureSession startRunning];
    }
}

-(void)hideQRScanner{
    // Stop video capture and make the capture session object nil.
    [_captureSession stopRunning];
    _captureSession = nil;
    
    // Remove the video preview layer from the viewPreview view's layer.
    [_videoPreviewLayer removeFromSuperlayer];
    _videoPreviewLayer = nil;
}

#pragma mark - AVCaptureMetadataOutputObjectsDelegate method implementation
-(void)captureOutput:(AVCaptureOutput *)captureOutput didOutputMetadataObjects:(NSArray *)metadataObjects fromConnection:(AVCaptureConnection *)connection{
    if(!_isScanned){
        dispatch_async(dispatch_get_main_queue(), ^{
            _isScanned = YES;
        });
        // Check if the metadataObjects array is not nil and it contains at least one object.
        if (metadataObjects != nil && [metadataObjects count] > 0) {
            NSArray *barCodeTypes = @[AVMetadataObjectTypeUPCECode, AVMetadataObjectTypeCode39Code, AVMetadataObjectTypeCode39Mod43Code,
                                      AVMetadataObjectTypeEAN13Code, AVMetadataObjectTypeEAN8Code, AVMetadataObjectTypeCode93Code, AVMetadataObjectTypeCode128Code,
                                      AVMetadataObjectTypePDF417Code, AVMetadataObjectTypeQRCode, AVMetadataObjectTypeAztecCode];
            NSString *detectedString = nil;
            
            for (AVMetadataObject *metadata in metadataObjects) {
                for (NSString *type in barCodeTypes) {
                    if ([metadata.type isEqualToString:type]){
                        detectedString = [(AVMetadataMachineReadableCodeObject *)metadata stringValue];
                        break;
                    }
                }
                
                if (detectedString != nil){
                    dispatch_async(dispatch_get_main_queue(), ^{
                        _capturedText = [NSString stringWithString:detectedString];
                        NSLog(@"%@", _capturedText);
                        [self hideQRScanner];
                        [self recordHistoryData];
                        [self performSegueWithIdentifier:@"FromScannerToTranslater" sender: self];
                        _isScanned = NO;
                    });
                    break;
                }
            }
        }
        else{
            dispatch_async(dispatch_get_main_queue(), ^{
                _isScanned = NO;
            });
        }
    }
}

-(void)recordHistoryData{
    NSDate *currentDate = [NSDate date];
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:@"YYYY-MM-dd HH:mm:ss"];
    NSString *timestamp = [dateFormatter stringFromDate:currentDate];
    
    NSLog(@"Recording the scan: %@, %@, %@, %@, %@", _capturedText, timestamp, _currentLatitude, _currentLongitude, _currentAddress);
    [GlobalSharingCentre insertHistoryDataWithDrugName:_capturedText Timestamp:timestamp Latitude:_currentLatitude Longitude:_currentLongitude Address:_currentAddress];
}

-(void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender{
    NSString *identifier = [segue identifier];
    if([identifier isEqualToString:@"FromScannerToTranslater"]){
        TranslaterViewController *tranController = (TranslaterViewController*)[segue destinationViewController];
        [tranController setDrugName:_capturedText];
    }
    else if([identifier isEqualToString:@"FromScannerToHistory"]){
        HistoryViewController *historyController = (HistoryViewController*)[segue destinationViewController];
        [historyController setIsFromScanner:YES];
    }
}

#pragma mark - CLLocationManagerDelegate
- (void)locationManager:(CLLocationManager *)manager didFailWithError:(NSError *)error{
    NSLog(@"didFailWithError: %@", error);
    
    UIAlertController * alert = [UIAlertController
                                  alertControllerWithTitle:@"Ooops, we have problem in accessing your location"
                                  message:nil
                                  preferredStyle:UIAlertControllerStyleAlert];
    
    UIAlertAction* yesButton = [UIAlertAction
                                actionWithTitle:@"Got it"
                                style:UIAlertActionStyleDefault
                                handler:^(UIAlertAction * action){
                                    //Handel your yes please button action here
                                    [alert dismissViewControllerAnimated:YES completion:nil];
                                }];
    
    [alert addAction:yesButton];
    [self presentViewController:alert animated:YES completion:nil];
}

- (void)locationManager:(CLLocationManager *)manager didUpdateToLocation:(CLLocation *)newLocation fromLocation:(CLLocation *)oldLocation{
    NSLog(@"didUpdateToLocation: %@", newLocation);
    CLLocation *currentLocation = newLocation;
    
    if (currentLocation != nil) {
        _currentLatitude = [NSString stringWithFormat:@"%.8f", currentLocation.coordinate.latitude];
        _currentLongitude = [NSString stringWithFormat:@"%.8f", currentLocation.coordinate.longitude];
    }
    
    // Reverse Geocoding
    [geocoder reverseGeocodeLocation:currentLocation completionHandler:^(NSArray *placemarks, NSError *error) {
        //NSLog(@"Found placemarks: %@, error: %@", placemarks, error);
        if (error == nil && [placemarks count] > 0) {
            placemark = [placemarks lastObject];
            _currentAddress = [NSString stringWithFormat:@"%@ %@\n%@ %@\n%@\n%@",
                                 placemark.subThoroughfare, placemark.thoroughfare,
                                 placemark.postalCode, placemark.locality,
                                 placemark.administrativeArea,
                                 placemark.country];
        } else {
            NSLog(@"%@", error.debugDescription);
        }
    } ];
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
