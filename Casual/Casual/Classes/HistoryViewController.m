//
//  HistoryViewController.m
//  Casual
//
//  Created by Vikas kumar on 07/02/14.
//  Copyright (c) 2014 Vikas kumar. All rights reserved.
//

#import "HistoryViewController.h"
#import "HistoryViewCell.h"
#import "AFHTTPClient.h"
#import "InfoViewController.h"


@interface HistoryViewController () <UITableViewDataSource, UITableViewDelegate>
{
    NSArray *      _historyList;
}
@property (weak, nonatomic) IBOutlet UITableView *tableView;

@end

@implementation HistoryViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.
    
}

-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [self sendHistoryRequestToServer];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(showUserInfo:) name:SHOW_USER_INFO_NOTIFICATION object:nil];
}

-(void) viewDidDisappear:(BOOL)animated
{
    [super viewDidDisappear:animated];
    
    [[NSNotificationCenter defaultCenter] removeObserver:self name:SHOW_USER_INFO_NOTIFICATION object:nil];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)logoutTapped:(id)sender
{
    [self logout];
}

#pragma -mark UItableViewdatasource

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    double numbrOfRows = [_historyList count] / 2.0;
    return ceil(numbrOfRows);
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    HistoryViewCell *cell = (HistoryViewCell*)[tableView dequeueReusableCellWithIdentifier:@"HistoryTableViewCell" forIndexPath:indexPath];
    
    NSDictionary *rightSideData = _historyList[indexPath.row * 2];
    NSDictionary *leftSideData;
    if(indexPath.row * 2 + 1 < _historyList.count)
    {
        leftSideData = _historyList[indexPath.row * 2 +1];
    }
    
    cell.rightSideData = rightSideData;
    cell.leftSideData = leftSideData;
    
    return cell;
}


#pragma -mark Server Requests

-(NSDictionary*)getParameters
{
    NSDictionary *currentUser = [[NSUserDefaults standardUserDefaults] valueForKey:LOGGEDIN_USER_DETAILS];
    NSString *user_id = [currentUser objectForKey:@"user_id"];
    
    NSDictionary * parameters = [NSDictionary dictionaryWithObjectsAndKeys:
                                 user_id, @"user_id",
                                 nil];
    
    return parameters;
}



-(void)sendHistoryRequestToServer
{
        NSString *url = [NSString stringWithFormat:@"%@getHistory.php",SERVER_URL];
        
        AFHTTPClient * Client = [[AFHTTPClient alloc] initWithBaseURL:[NSURL URLWithString:url]];
        
        
        [Client setParameterEncoding:AFJSONParameterEncoding];
        [Client postPath:@"users/login.json" parameters:[self getParameters] success:^(AFHTTPRequestOperation *operation, id responseObject){
            
            [self hideLoadingScreen];
            
            NSError *error = nil;
            NSDictionary *response = [NSJSONSerialization JSONObjectWithData:responseObject options:kNilOptions error:&error];
            
            
            //        NSDictionary *test = [NSDictionary dictionaryWithObjectsAndKeys:@"true", @"status", @"12", @"connected_to_userID", @"AB123", @"connected_to_unique_id", @"anu" , @"connected_to_firstName", @"as", @"connected_to_lastName", @"rin@gmail.com", @"connected_to_email", nil];
            //        [self showUserDetails:test];
            
            
            NSString *mesage = nil;
            NSString *title = nil;
            
            if (error) {
                title = @"Error";
                mesage = [error localizedDescription];
            }
            else if ([[response objectForKey:@"status"] integerValue] == 1)
            {
                
                _historyList = [[NSArray alloc] initWithArray:(NSArray*)[response objectForKey:@"scanned_persons"]];
                [self.tableView reloadData];
            }
            else
            {
                title = @"Error";
                mesage = @"No history available";
            }
            
            if(mesage != nil)
            {
                UIAlertView *alert = [[UIAlertView alloc] initWithTitle:title
                                                                message:mesage
                                                               delegate:nil
                                                      cancelButtonTitle:NSLocalizedString(@"OK", nil)
                                                      otherButtonTitles:nil];
                [alert show];
            }
            
        }
                 failure:^(AFHTTPRequestOperation *operation, NSError *error) {
                     UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Error"
                                                                     message:[error localizedDescription]
                                                                    delegate:self
                                                           cancelButtonTitle:NSLocalizedString(@"OK", nil)
                                                           otherButtonTitles:nil];
                     [alert show];
                     [self hideLoadingScreen];
                     
                 }];
        
        [self showLoadingScreenWithMessage:@"Loading"];
}


-(void)showUserInfo:(NSNotification*)notification
{
    InfoViewController *vc = [self.storyboard instantiateViewControllerWithIdentifier:@"InfoViewController"];
    vc.userDetail = (NSDictionary*)notification.object;
    [self.navigationController pushViewController:vc animated:YES];
}

@end
