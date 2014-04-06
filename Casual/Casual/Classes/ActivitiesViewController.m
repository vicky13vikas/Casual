//
//  ActivitiesViewController.m
//  Casual
//
//  Created by Vikas kumar on 07/02/14.
//  Copyright (c) 2014 Vikas kumar. All rights reserved.
//

#import "ActivitiesViewController.h"
#import "ActivityTableDatasource.h"
#import "TwitterServices.h"

@interface ActivitiesViewController ()
{
    NSMutableArray *messageList;
}


@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (nonatomic, strong) ActivityTableDatasource *tableDataSource;
@property (weak, nonatomic) IBOutlet UIButton *btnFacebook;
@property (weak, nonatomic) IBOutlet UIButton *btnTwitter;
@property (weak, nonatomic) IBOutlet UIButton *btnCheckin;

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
    _tableView.delegate = _tableDataSource;
}

-(void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];

    [messageList removeAllObjects];
    _tableDataSource.messageList = messageList;
    [_tableView reloadData];
    
    if (![[NSUserDefaults standardUserDefaults] valueForKey:IS_FACEBOOK_ON])
    {
        _btnFacebook.enabled = NO;
        if ([[NSUserDefaults standardUserDefaults] valueForKey:IS_TWITTER_ON])
        {
            [self twitterTapped:nil];
        }
    }
    else
    {
        _btnFacebook.enabled = YES;
        [self faceBookTapped:nil];
    }
    
    if (![[NSUserDefaults standardUserDefaults] valueForKey:IS_TWITTER_ON])
    {
        _btnTwitter.enabled = NO;
    }
    else
    {
        _btnTwitter.enabled = YES;
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

- (IBAction)faceBookTapped:(id)sender
{
    [self showLoadingScreenWithMessage:@"Loading..."];
    _tableDataSource.datasource = kStatustypeFacebook;
    [self loadStatusFromFacebook];
}

- (IBAction)twitterTapped:(id)sender
{
    [self showLoadingScreenWithMessage:@"Loading..."];
    _tableDataSource.datasource = kStatustypeTwitter;
    [self loadStatusFromTwitter];
}

#pragma -mark segue


-(IBAction)unwindActivitiesSegue:(UIStoryboardSegue*)segue
{
    
}

-(void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    
}

- (BOOL)shouldPerformSegueWithIdentifier:(NSString *)identifier sender:(id)sender NS_AVAILABLE_IOS(6_0)
{
    if([identifier isEqualToString:@"CheckInSegue"])
    {
        if (![[NSUserDefaults standardUserDefaults] valueForKey:IS_FACEBOOK_ON])
        {
            [self showAlertWithMessage:@"Please switch on Facebook in the settings page." andTitle:@"Error"];
            return NO;
        }
    }
    return YES;
}

#pragma -mark FaceBook

- (void) loadStatusFromFacebook
{
    if ([[NSUserDefaults standardUserDefaults] valueForKey:IS_FACEBOOK_ON])
    {
        [FBRequestConnection startWithGraphPath:[NSString stringWithFormat:@"me/home?limit=200"] parameters:nil HTTPMethod:@"GET" completionHandler:^(FBRequestConnection *connection, id result, NSError *error) {
            [self hideLoadingScreen];
            if(!error)
            {
                [self parseFacebookStatusMessage:result];
            }
            else{
                [self showAlertWithMessage:@"Error loading staus" andTitle:@"Error"];
            }
        }];
    }
    else
    {
        [self showAlertWithMessage:@"Please switch on Facebook in the settings page." andTitle:@"Error"];
    }
}

-(void)parseFacebookStatusMessage :(NSDictionary*)result
{
    [messageList removeAllObjects];
    NSArray *dataList = [result objectForKey:@"data"];
    for(int i = 0; i< dataList.count ; i++)
    {
        NSMutableDictionary *facebookDetail = [[NSMutableDictionary alloc] init];
        
        NSString *status = [dataList[i] valueForKey:@"message"];
        NSString *picture = [dataList[i] valueForKey:@"picture"];

        if(status || picture)
        {
            if (status)
            {
                [facebookDetail setObject:status forKey:@"status"];
            }
            if (picture)
            {
                [facebookDetail setObject:picture forKey:@"picture"];
            }
            [facebookDetail setObject:[dataList[i] valueForKeyPath:@"from.name"] forKey:@"screenName"];
            [facebookDetail setObject:[dataList[i] valueForKeyPath:@"from.id"] forKey:@"imageURL_OR_ID"];
            [facebookDetail setObject:[dataList[i] valueForKey:@"created_time"] forKey:@"date"];
            
            [messageList addObject:facebookDetail];
        }
    }
    _tableDataSource.messageList = [messageList copy];
    [_tableView reloadData];
}

#pragma -mark Twitter

- (void) loadStatusFromTwitter
{
    if ([[NSUserDefaults standardUserDefaults] valueForKey:IS_TWITTER_ON])
    {
        STTwitterAPI *twitter = [TwitterServices sharedTwitter];
        [twitter verifyCredentialsWithSuccessBlock:^(NSString *username) {
            
            [self getTwitterTimeline];
            
        } errorBlock:^(NSError *error) {
            [self hideLoadingScreen];
            
            [self showAlertWithMessage:@"Make sure you have allowed Casuals in the twitter settings." andTitle:@"Error"];
        }];
    }
    else
    {
        [self showAlertWithMessage:@"Please switch on Twitter in the settings page." andTitle:@"Error"];
    }
}

-(void)getTwitterTimeline
{
    STTwitterAPI *twitter = [TwitterServices sharedTwitter];

    [twitter getHomeTimelineSinceID:nil
                              count:20
                       successBlock:^(NSArray *statuses) {
                           [self hideLoadingScreen];

                           [self parseTwitterStatusMessage:statuses];
                           
                       } errorBlock:^(NSError *error) {
                           [self hideLoadingScreen];

                           [self showAlertWithMessage:@"Error Fetching twiter data" andTitle:@"Error"];
                       }];
}

-(void)parseTwitterStatusMessage:(NSArray*)result
{
    NSArray *text = [result valueForKey:@"text"];
    NSArray *screenName = [result valueForKeyPath:@"user.screen_name"];
    NSArray *profileImageUrl = [result valueForKeyPath:@"user.profile_image_url"];
    NSArray *dateString = [result valueForKey:@"created_at"];
    
    [messageList removeAllObjects];
    
    for (int i = 0; i<result.count; i++)
    {
        NSMutableDictionary *twitterDetail = [[NSMutableDictionary alloc] init];
        
        if(text[i])
        {
            [twitterDetail setObject:text[i] forKey:@"status"];
            [twitterDetail setObject:screenName[i] forKey:@"screenName"];
            [twitterDetail setObject:profileImageUrl[i] forKey:@"imageURL_OR_ID"];
            [twitterDetail setObject:dateString[i] forKey:@"date"];
            
            [messageList addObject:twitterDetail];
        }
    }
    
    _tableDataSource.messageList = [messageList copy];
    [_tableView reloadData];
}

@end
