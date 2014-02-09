//
//  SettingsViewController.m
//  Casual
//
//  Created by Vikas kumar on 09/02/14.
//  Copyright (c) 2014 Vikas kumar. All rights reserved.
//

#import "SettingsViewController.h"
#import "UIViewControllerCategories.h"

@interface SettingsViewController ()

@property (weak, nonatomic) IBOutlet UIButton *btnFacebookSwitch;
@property (weak, nonatomic) IBOutlet UIButton *btnTwitterSwitch;

- (IBAction)backButtonClicked:(id)sender;

@end

@implementation SettingsViewController

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
    [self setIntialButtonStates];
}

-(void)setIntialButtonStates
{
    if ([[NSUserDefaults standardUserDefaults] valueForKey:IS_FACEBOOK_ON])
    {
        [_btnFacebookSwitch setImage:[UIImage imageNamed:@"btnON.png"] forState:UIControlStateNormal];
    }
    else
    {
        [_btnFacebookSwitch setImage:[UIImage imageNamed:@"btnOff.png"] forState:UIControlStateNormal];
    }
    
    if ([[NSUserDefaults standardUserDefaults] valueForKey:IS_TWITTER_ON])
    {
        [_btnTwitterSwitch setImage:[UIImage imageNamed:@"btnON.png"] forState:UIControlStateNormal];
    }
    else
    {
        [_btnTwitterSwitch setImage:[UIImage imageNamed:@"btnOff.png"] forState:UIControlStateNormal];
    }
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)backButtonClicked:(id)sender
{
    [self.navigationController popViewControllerAnimated:YES];
}

- (IBAction)btnFacebookToggle:(UIButton*)sender
{
    if ([[NSUserDefaults standardUserDefaults] valueForKey:IS_FACEBOOK_ON])
    {
        [self removeFacebook];
        [sender setImage:[UIImage imageNamed:@"btnOff.png"] forState:UIControlStateNormal];
    }
    else
    {
        [[NSUserDefaults standardUserDefaults] setValue:@"1" forKey:IS_FACEBOOK_ON];
        [[NSUserDefaults standardUserDefaults] synchronize];
        [self CreateNewSession];
        [self OpenSession];
        [sender setImage:[UIImage imageNamed:@"btnON.png"] forState:UIControlStateNormal];
    }
}

- (IBAction)btnTwitter:(id)sender
{
    if ([[NSUserDefaults standardUserDefaults] valueForKey:IS_TWITTER_ON])
    {
        [self removeTwitter];
        [_btnTwitterSwitch setImage:[UIImage imageNamed:@"btnOff.png"] forState:UIControlStateNormal];
    }
    else
    {
        [[NSUserDefaults standardUserDefaults] setValue:@"1" forKey:IS_TWITTER_ON];
        [[NSUserDefaults standardUserDefaults] synchronize];
        [_btnTwitterSwitch setImage:[UIImage imageNamed:@"btnON.png"] forState:UIControlStateNormal];
    }
}

#pragma -mark FaceBook

-(void)CreateNewSession
{
    FBSession *activeSession = [[FBSession alloc] init];
    [FBSession setActiveSession: activeSession];
}

-(void)OpenSession
{
    
    [self showLoadingScreenWithMessage:@"Loading..."];
    NSArray *permissions = [[NSArray alloc] initWithObjects:
                            @"email",
                            @"user_status",
                            nil];
    // Attempt to open the session. If the session is not open, show the user the Facebook login UX
    [FBSession openActiveSessionWithReadPermissions:permissions allowLoginUI:YES completionHandler:^(FBSession *session, FBSessionState status, NSError *error) {
        // Did something go wrong during login? I.e. did the user cancel?
        if(!error)
        {
            if (status == FBSessionStateClosedLoginFailed || status == FBSessionStateCreatedOpening) {
                [self faceBookErrorMessage];
            }
            if(status == FBSessionStateClosed)
            {
                
            }
            else {
                [self fetchUserDetails];
            }
        }
        else
        {
            [self faceBookErrorMessage];
        }
        
        
    }];
}

-(void)fetchUserDetails
{
    [[FBRequest requestForMe]
     startWithCompletionHandler:
     ^(FBRequestConnection *connection, NSDictionary<FBGraphUser> *result, NSError *error)
     {
         // Did everything come back okay with no errors?
         if (!error && result) {
             [self hideLoadingScreen];

             [[NSUserDefaults standardUserDefaults] setObject:result forKey:FACEBOOK_DETAILS];
             [[NSUserDefaults standardUserDefaults] synchronize];
         }
         else {
             [self faceBookErrorMessage];
         }
     }];
}

-(void)faceBookErrorMessage
{
    [self hideLoadingScreen];
    [self removeFacebook];
    [_btnFacebookSwitch setImage:[UIImage imageNamed:@"btnOff.png"] forState:UIControlStateNormal];

    UIAlertView *errorAlert = [[UIAlertView alloc] initWithTitle:ALERT_TITLE message:@"Make sure you have allowed Casuals in the Facebook settings." delegate:nil cancelButtonTitle:ALERT_OK otherButtonTitles:nil];
    [errorAlert show];
}




@end
