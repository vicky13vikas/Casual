//
//  ActivitiesViewController.m
//  Casual
//
//  Created by Vikas kumar on 07/02/14.
//  Copyright (c) 2014 Vikas kumar. All rights reserved.
//

#import "ActivitiesViewController.h"
#import "ActivityTableDatasource.h"

@interface ActivitiesViewController ()
{
    NSMutableArray *messageList;
}


@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (nonatomic, strong) ActivityTableDatasource *tableDataSource;
@property (weak, nonatomic) IBOutlet UIButton *btnFacebook;
@property (weak, nonatomic) IBOutlet UIButton *btnTwitter;

- (IBAction)faceBookTapped:(id)sender;
- (IBAction)twitterTapped:(id)sender;

@end

@implementation ActivitiesViewController

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
    
    messageList = [[NSMutableArray alloc] init];
    
    _tableDataSource = [[ActivityTableDatasource alloc] init];
    _tableView.dataSource = _tableDataSource;
}

-(void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    
    if([[FBSession activeSession] state] != FBSessionStateOpen)
    {
        _btnFacebook.enabled = NO;
    }
    else
    {
        [self loadStatusFromFacebook];
    }
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

-(IBAction)unwindActivitiesSegue:(UIStoryboardSegue*)segue
{
  
}


- (IBAction)faceBookTapped:(id)sender
{
    [self loadStatusFromFacebook];
}

- (IBAction)twitterTapped:(id)sender
{
    [_tableView reloadData];
}

#pragma -mark FaceBook

- (void) loadStatusFromFacebook
{
    [FBRequestConnection startWithGraphPath:[NSString stringWithFormat:@"me/statuses?fields=message"] parameters:nil HTTPMethod:@"GET" completionHandler:^(FBRequestConnection *connection, id result, NSError *error) {
        
        if(!error)
        {
            [self parseFacebookStatusMessage:result];
        }
        else{
            [self showAlertWithMessage:@"Error loading staus" andTitle:@"Error"];
        }
    }];
}

-(void)parseFacebookStatusMessage :(NSDictionary*)result
{
    [messageList removeAllObjects];
    NSArray *dataList = [result objectForKey:@"data"];
    for(int i = 0; i< dataList.count ; i++)
    {
        NSString *message = [dataList[i] objectForKey:@"message"];
        if(message)
            [messageList addObject:message];
    }
    _tableDataSource.messageList = messageList;
    [_tableView reloadData];
}
@end
