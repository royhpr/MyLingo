//
//  HistoryViewController.m
//  ScanYourDrug
//
//  Created by royhpr on 19/11/15.
//  Copyright © 2015 royhpr. All rights reserved.
//

#import "HistoryViewController.h"

@interface HistoryViewController ()

@property(nonatomic, strong)NSMutableArray *historyList;
@property(nonatomic, strong)NSMutableArray *searchList;

@property(nonatomic, strong)HistoryModel *selectedHistory;

@end

@implementation HistoryViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self setupNav];
    [self setupList];
    [self registerKeyBoardNotification];
}

-(void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:YES];
    [self.navigationController setNavigationBarHidden:NO];
}

-(void)setupList{
    _historyList = [[NSMutableArray alloc]init];
    _searchList = [[NSMutableArray alloc]init];
    
    //Get data from local storage instead
    NSArray *historyData = [GlobalSharingCentre getHistoryData];
    if(historyData != nil){
        [_historyList addObjectsFromArray:historyData];
        NSSortDescriptor *sd = [NSSortDescriptor sortDescriptorWithKey:@"timestamp" ascending:NO];
        [_historyList sortUsingDescriptors:@[sd]];
    }
}

-(void)setupNav{
    if(!_isFromScanner){
        UIImageView* qrcodeView =[[UIImageView alloc]initWithImage:[UIImage imageNamed:@"qrcode.png"]];
        qrcodeView.frame=CGRectMake(0, 0, 35, 35);
        qrcodeView.userInteractionEnabled = YES;
        
        UITapGestureRecognizer* qrcodeSingleTap = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(showScanner)];
        [qrcodeSingleTap setNumberOfTapsRequired:1];
        [qrcodeSingleTap setNumberOfTouchesRequired:1];
        [qrcodeView addGestureRecognizer:qrcodeSingleTap];
        
        UIBarButtonItem* qrcodeButton = [[UIBarButtonItem alloc]initWithCustomView:qrcodeView];
        self.navigationItem.rightBarButtonItem = qrcodeButton;
    }
    
    UIImageView* backView =[[UIImageView alloc]initWithImage:[UIImage imageNamed:@"back.png"]];
    backView.frame=CGRectMake(0, 0, 35, 35);
    backView.userInteractionEnabled = YES;
    
    UITapGestureRecognizer* backSingleTap = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(goBackOneLevel)];
    [backSingleTap setNumberOfTapsRequired:1];
    [backSingleTap setNumberOfTouchesRequired:1];
    [backView addGestureRecognizer:backSingleTap];
    
    UIBarButtonItem* backButton = [[UIBarButtonItem alloc]initWithCustomView:backView];
    self.navigationItem.leftBarButtonItem = backButton;
}

-(void)goBackOneLevel{
    [self.navigationController popViewControllerAnimated:YES];
}

-(void)showScanner{
    [self performSegueWithIdentifier:@"FromHistoryToScanner" sender:self];
}

-(void)registerKeyBoardNotification{
    //Initialize keyboard observation
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(keyboardWillShow:)
                                                 name:UIKeyboardWillShowNotification
                                               object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(keyboardWillHide:)
                                                 name:UIKeyboardWillHideNotification
                                               object:nil];

}

-(void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender{
    if([[segue identifier]isEqualToString:@"FromHistoryToTranslater"]){
        TranslaterViewController *translaterController = (TranslaterViewController*)[segue destinationViewController];
        [translaterController setDrugName:_selectedHistory.drugName];
    }
}

#pragma mark - table view delegates
-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    return 1;
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return _historyList.count;
}

-(UITableViewCell*)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    static NSString *CellIdentifier = @"drugcell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    
    if(cell == nil){
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
        
        [cell.textLabel setNumberOfLines:0];
        [cell.textLabel setLineBreakMode:NSLineBreakByWordWrapping];
    }
    
    NSInteger row = [indexPath row];
    HistoryModel *historyItem = [_historyList objectAtIndex:row];
    
    cell.textLabel.text = historyItem.drugName;
    cell.detailTextLabel.text = historyItem.timestamp;
    
    return cell;
}

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return 60.0;
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    //Show the drug detail
    _selectedHistory = (HistoryModel*)[_historyList objectAtIndex:[indexPath row]];
    [self performSegueWithIdentifier:@"FromHistoryToTranslater" sender:self];
}

-(NSArray *)tableView:(UITableView *)tableView editActionsForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewRowAction *deleteAction = [UITableViewRowAction rowActionWithStyle:UITableViewRowActionStyleDefault title:@"Delete" handler:^(UITableViewRowAction *action, NSIndexPath *indexPath){
        NSInteger row = [indexPath row];
        HistoryModel *history = (HistoryModel*)[_historyList objectAtIndex:row];
        [_historyList removeObjectAtIndex:row];
        [GlobalSharingCentre deleteHistoryDataWithDrugName:history.drugName Timestamp:history.timestamp];
        
        [tableView reloadData];
    }];
    deleteAction.backgroundColor = [UIColor redColor];
    
    return @[deleteAction];
}

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    
}

- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath{
    return YES;
}

#pragma mark - Search bar delegate methods
-(void)searchBarTextDidBeginEditing:(UISearchBar *)searchBar{
    searchBar.showsCancelButton = YES;
    
    [_searchList addObjectsFromArray:_historyList];
    [_historyList removeAllObjects];
    
    [_myTableView reloadData];
}

-(void)searchBar:(UISearchBar *)searchBar textDidChange:(NSString *)searchText{
    [self filterContentForSearchText:searchText];
}

-(void)searchBarTextDidEndEditing:(UISearchBar *)searchBar{
    //Called when resign first respondant
    searchBar.showsCancelButton = NO;
    searchBar.text = @"";
    
    //Put back previous search list if it is not empty
    if(_searchList.count != 0){
        [_historyList removeAllObjects];
        [_historyList addObjectsFromArray:_searchList];
    }
    
    //Clear search list
    [_searchList removeAllObjects];
}

-(void)searchBarCancelButtonClicked:(UISearchBar *)searchBar{
    [searchBar resignFirstResponder];
    [_myTableView reloadData];
}

-(void)searchBarSearchButtonClicked:(UISearchBar *)searchBar{
    
}

- (void)filterContentForSearchText:(NSString*)searchText{
    NSPredicate *resultPredicate = [NSPredicate
                                    predicateWithFormat:@"SELF.drugName contains[cd] %@ OR SELF.timestamp contains[cd] %@",
                                    searchText, searchText];
    
    [_historyList removeAllObjects];
    [_historyList addObjectsFromArray: [_searchList filteredArrayUsingPredicate:resultPredicate]];
    
    [_myTableView reloadData];
}

#pragma mark - keyboard delegates
- (void)keyboardWillShow:(NSNotification *)notification{
    CGSize keyboardSize = [[[notification userInfo] objectForKey:UIKeyboardFrameBeginUserInfoKey] CGRectValue].size;
    
    UIEdgeInsets contentInsets;
    if (UIInterfaceOrientationIsPortrait([[UIApplication sharedApplication] statusBarOrientation])) {
        contentInsets = UIEdgeInsetsMake(0.0, 0.0, (keyboardSize.height), 0.0);
    } else {
        contentInsets = UIEdgeInsetsMake(0.0, 0.0, (keyboardSize.width), 0.0);
    }
    
    _myTableView.contentInset = contentInsets;
    _myTableView.scrollIndicatorInsets = contentInsets;
}

- (void)keyboardWillHide:(NSNotification *)notification{
    _myTableView.contentInset = UIEdgeInsetsZero;
    _myTableView.scrollIndicatorInsets = UIEdgeInsetsZero;
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
