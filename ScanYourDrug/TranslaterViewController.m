//
//  TranslaterViewController.m
//  ScanYourDrug
//
//  Created by royhpr on 16/11/15.
//  Copyright © 2015 royhpr. All rights reserved.
//

#import "TranslaterViewController.h"

@interface TranslaterViewController ()

@property(nonatomic, strong)UIView *coverView;
@property(nonatomic, strong)UIPickerView *menuView;
@property(nonatomic)BOOL isMenuShown;

@property(nonatomic, strong)NSMutableArray *menuList;

@property(nonatomic)NSInteger selectedLanguageIndex;

@property(nonatomic, strong)NSMutableDictionary *drugDictionary;
@property(nonatomic, strong)NSMutableDictionary *menuMapping;
@property(nonatomic, strong)NSMutableArray *langCodeList;

@end

@implementation TranslaterViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self setupList];
    [self setupNav];
    [self setupHistoryButton];
    [self setupDrugDictionary];
    [self setupContent];
}

-(void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:YES];
    [self.navigationController setNavigationBarHidden:NO];
}

-(void)viewDidAppear:(BOOL)animated{
    [super viewDidAppear:YES];
    [self setupMenuView];
    [self loadContent];
}

-(void)viewDidLayoutSubviews{
    [super viewDidLayoutSubviews];
}

-(void)setupNav{
    UIImageView* backView =[[UIImageView alloc]initWithImage:[UIImage imageNamed:@"back.png"]];
    backView.frame=CGRectMake(0, 0, 35, 35);
    backView.userInteractionEnabled = YES;
    
    UITapGestureRecognizer* backSingleTap = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(goBackScanner)];
    [backSingleTap setNumberOfTapsRequired:1];
    [backSingleTap setNumberOfTouchesRequired:1];
    [backView addGestureRecognizer:backSingleTap];
    
    UIBarButtonItem* backButton = [[UIBarButtonItem alloc]initWithCustomView:backView];
    self.navigationItem.leftBarButtonItem = backButton;
    
    
    UIImageView* translateView =[[UIImageView alloc]initWithImage:[UIImage imageNamed:@"translate.png"]];
    translateView.frame=CGRectMake(0, 0, 35, 35);
    translateView.userInteractionEnabled = YES;
    
    UITapGestureRecognizer* translateSingleTap = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(switchLanguage)];
    [translateSingleTap setNumberOfTapsRequired:1];
    [translateSingleTap setNumberOfTouchesRequired:1];
    [translateView addGestureRecognizer:translateSingleTap];
    
    UIBarButtonItem* translateButton = [[UIBarButtonItem alloc]initWithCustomView:translateView];
    self.navigationItem.rightBarButtonItem = translateButton;
}

-(void)setupMenuView{
    if(_coverView == nil){
        _coverView = [[UIView alloc]initWithFrame:CGRectMake(0.0, 0.0, self.view.frame.size.width, self.view.frame.size.height)];
        [_coverView setBackgroundColor:[UIColor grayColor]];
        [_coverView setAlpha:0.9];
        [_coverView setUserInteractionEnabled:YES];
        
        UITapGestureRecognizer *coverViewTap = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(dismissMenu)];
        [coverViewTap setNumberOfTapsRequired:1];
        [coverViewTap setNumberOfTouchesRequired:1];
        
        [_coverView addGestureRecognizer:coverViewTap];
    }
    
    if(_menuView == nil){
        _menuView = [[UIPickerView alloc] initWithFrame:CGRectMake(0, self.view.frame.origin.y + (self.view.frame.size.height - _menuView.frame.size.height), self.view.frame.size.width, _menuView.frame.size.height)];
        _menuView.backgroundColor = [UIColor whiteColor];
        _menuView.delegate = self;
        _menuView.showsSelectionIndicator = YES;
    }
}

-(void)setupHistoryButton{
    UITapGestureRecognizer *historySingleTap = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(showHistory)];
    [historySingleTap setNumberOfTapsRequired:1];
    [historySingleTap setNumberOfTouchesRequired:1];
    
    [_historyImageView addGestureRecognizer:historySingleTap];
}

-(NSString*)getDeviceLanguage{
    return [[[NSLocale preferredLanguages] objectAtIndex:0]substringToIndex:2];
}

-(void)setupDrugDictionary{
    _drugDictionary = [[NSMutableDictionary alloc]initWithObjects:
                       [NSArray arrayWithObjects:@"Januvia_PI_Dutch",
                                                @"Januvia_PI_English",
                                                @"Januvia_PI_French",
                                                @"Januvia_PI_Chinese",
                                                @"Januvia_PI_Spainish",
                                                @"Singulair_PI_Dutch",
                                                @"Singulair_PI_English",
                                                @"Singulair_PI_French",
                                                @"Singulair_PI_Chinese",
                                                @"Singulair_PI_Spanish", nil]
                                                          forKeys:
                       [NSArray arrayWithObjects:@"Januvia_nl",
                                                @"Januvia_en",
                                                @"Januvia_fr",
                                                @"Januvia_zh",
                                                @"Januvia_es",
                                                @"Singulair_nl",
                                                @"Singulair_en",
                                                @"Singulair_fr",
                                                @"Singulair_zh",
                                                @"Singulair_es", nil]];
    
    _menuMapping = [[NSMutableDictionary alloc]initWithObjects:[NSArray arrayWithObjects:@"nl", @"en", @"fr", @"zh", @"es", nil] forKeys:[NSArray arrayWithObjects:@"Nederlands", @"English", @"français", @"中文", @"Español", nil]];
}

-(void)showHistory{
    [self performSegueWithIdentifier:@"FromTranslaterToHistory" sender:self];
}

-(void)setupContent{
    _myWebView.layer.cornerRadius = 5.0;
    _myWebView.layer.borderColor = [UIColor lightGrayColor].CGColor;
    _myWebView.layer.borderWidth = 3.0;
    _drugNameLabel.text = _drugName;
}

-(void)loadContent{
    NSString *fileName = (NSString*)[_drugDictionary objectForKey:[NSString stringWithFormat:@"%@_%@", _drugName, [self getDeviceLanguage]]];
    [self loadPDFContentWithFileName:fileName];
}

-(void)loadPDFContentWithFileName:(NSString*)fileName{
    NSString *path = [[NSBundle mainBundle] pathForResource:fileName ofType:@"pdf"];
    NSURL *url = [NSURL fileURLWithPath:path];
    NSURLRequest *request = [NSURLRequest requestWithURL:url];
    [_myWebView setScalesPageToFit:YES];
    [_myWebView loadRequest:request];
}

-(void)setupList{
    _isMenuShown = NO;
    _selectedLanguageIndex = 0;
    _menuList = [[NSMutableArray alloc]initWithObjects:@"Nederlands", @"English", @"français", @"中文", @"Español", nil];
    _langCodeList = [[NSMutableArray alloc]initWithObjects:@"nl", @"en", @"fr", @"zh", @"es", nil];
}

-(void)goBackScanner{
    [self.navigationController popViewControllerAnimated:YES];
}

-(void)switchLanguage{
    [self showMenu];
}

-(void)showMenu{
    if(!_isMenuShown){
        //Show menu
        [_coverView setFrame:CGRectMake(0.0, 0.0, self.view.frame.size.width, self.view.frame.size.height)];
        [self.view addSubview:_coverView];
        
        _menuView.frame = CGRectMake(0.0, self.view.frame.size.height, self.view.frame.size.width, self.view.frame.size.height / 3.5);
        
        [UIView animateWithDuration:0.3
                              delay:0.1
                            options: UIViewAnimationOptionCurveEaseIn
                         animations:^{
                             _menuView.frame = CGRectMake(0, self.view.frame.origin.y + (self.view.frame.size.height - _menuView.frame.size.height), self.view.frame.size.width, _menuView.frame.size.height);
                         }
                         completion:^(BOOL finished){
                         }];
        [_coverView addSubview:_menuView];
        
        //Select row
        NSInteger index = [self getIndexOfLangcode:[self getDeviceLanguage]];
        [_menuView selectRow:index inComponent:0 animated:YES];
        
        _isMenuShown = YES;
    }
}

-(void)dismissMenu{
    [UIView animateWithDuration:0.3
                          delay:0.1
                        options: UIViewAnimationOptionCurveEaseIn
                     animations:^{
                         _menuView.frame = CGRectMake(0, self.view.frame.origin.y + self.view.frame.size.height, self.view.frame.size.width, _menuView.frame.size.height);
                     }
                     completion:^(BOOL finished){
                         if (finished)
                             [_menuView removeFromSuperview];
                     }];
    
    [self performSelector:@selector(removeGrayCoverView) withObject:self afterDelay:0.5];
}

-(void)removeGrayCoverView{
    [_coverView removeFromSuperview];
    _isMenuShown = NO;
}

-(NSInteger)getIndexOfLangcode:(NSString*)string{
    NSInteger index = -1;
    for(NSInteger i=0; i<_langCodeList.count; i++){
        NSString *langCode = [_langCodeList objectAtIndex:i];
        if([langCode isEqualToString:string]){
            index = i;
            break;
        }
    }
    return index;
}

#pragma mark - picker delegate
- (void)pickerView:(UIPickerView *)pickerView didSelectRow: (NSInteger)row inComponent:(NSInteger)component {
    NSString *langCode = (NSString*)[_menuMapping objectForKey:[_menuList objectAtIndex:row]];
    NSString *fileName = [_drugDictionary objectForKey:[NSString stringWithFormat:@"%@_%@", _drugName, langCode]];
    [self loadPDFContentWithFileName:fileName];
}

- (NSInteger)pickerView:(UIPickerView *)pickerView numberOfRowsInComponent:(NSInteger)component {
    return _menuList.count;
}

- (NSInteger)numberOfComponentsInPickerView:(UIPickerView *)pickerView {
    return 1;
}

- (NSString *)pickerView:(UIPickerView *)pickerView titleForRow:(NSInteger)row forComponent:(NSInteger)component {
    return [_menuList objectAtIndex:row];
}

- (CGFloat)pickerView:(UIPickerView *)pickerView widthForComponent:(NSInteger)component {
    return self.view.frame.size.width;
}

#pragma mark - webview delegate
- (void)webViewDidStartLoad:(UIWebView *)webView{
    // starting the load, show the activity indicator in the status bar
    [UIApplication sharedApplication].networkActivityIndicatorVisible = YES;
}

- (void)webViewDidFinishLoad:(UIWebView *)webView{
    // finished loading, hide the activity indicator in the status bar
    [UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
}

- (void)webView:(UIWebView *)webView didFailLoadWithError:(NSError *)error{
    // load error, hide the activity indicator in the status bar
    [UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
    
    // report the error inside the webview
    NSString* errorString = [NSString stringWithFormat:
                             
                             @"<html><center><font size=+1 color='black'><br><br><br>An error occurred:<br>%@</font></center></html>",
                             
                             error.localizedDescription];
    
    [self.myWebView loadHTMLString:errorString baseURL:nil];
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

//- (UIInterfaceOrientationMask)supportedInterfaceOrientations{
//    return UIInterfaceOrientationMaskPortrait | UIInterfaceOrientationMaskLandscapeLeft | UIInterfaceOrientationMaskLandscapeRight;
//}
//
//- (UIInterfaceOrientation)preferredInterfaceOrientationForPresentation{
//    return UIInterfaceOrientationPortrait | UIInterfaceOrientationLandscapeLeft | UIInterfaceOrientationLandscapeRight;
//}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
