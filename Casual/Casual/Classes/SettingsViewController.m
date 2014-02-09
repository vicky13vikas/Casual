//
//  SettingsViewController.m
//  Casual
//
//  Created by Vikas kumar on 09/02/14.
//  Copyright (c) 2014 Vikas kumar. All rights reserved.
//

#import "SettingsViewController.h"
#import "UIViewControllerCategories.h"
#import "AFHTTPClient.h"

@interface SettingsViewController () <UITextFieldDelegate>

@property (weak, nonatomic) IBOutlet UIButton *btnFacebookSwitch;
@property (weak, nonatomic) IBOutlet UIButton *btnTwitterSwitch;

@property (weak, nonatomic) IBOutlet UITextField *tfNutshell;
@property (weak, nonatomic) IBOutlet UITextField *tfSchool;
@property (weak, nonatomic) IBOutlet UITextField *tfOccupation;
@property (weak, nonatomic) IBOutlet UITextField *tfZodiacSign;
@property (weak, nonatomic) IBOutlet UITextField *tfMaritialStatus;
@property (weak, nonatomic) IBOutlet UITextField *tfPhoneNumber;
@property (weak, nonatomic) IBOutlet UITextField *tfDateOfBirth;
@property (weak, nonatomic) IBOutlet UITextField *tfLocation;


- (IBAction)backButtonClicked:(id)sender;
- (IBAction)saveButtonTapped:(id)sender;

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

- (IBAction)saveButtonTapped:(id)sender
{
    if([self checkEnteredValues])
        [self sendInfoToServer];
    else
        [self showAlertWithMessage:@"Please enter the values" andTitle:@"Error"];
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

#pragma -mark Server Requests

-(BOOL)checkEnteredValues
{
    BOOL isEnteredValesOK = NO;
    NSDictionary *parameters = [self getParameters];
    if(parameters.count <= 1)
    {
        isEnteredValesOK = NO;
    }
    return isEnteredValesOK;
}

-(NSDictionary*)getParameters
{
    NSDictionary *currentUser = [[NSUserDefaults standardUserDefaults] valueForKey:LOGGEDIN_USER_DETAILS];
    NSString *user_id = [currentUser objectForKey:@"user_id"];
    
    NSString *nutShell = _tfNutshell.text;
    NSString *school = _tfSchool.text;
    NSString *occupation = _tfOccupation.text;
    NSString *zodiacSign = _tfZodiacSign.text;
    NSString *maritialStatus = _tfMaritialStatus.text;
    NSString *phnNumber = _tfPhoneNumber.text;
    NSString *dob = _tfDateOfBirth.text;
    NSString *location = _tfLocation.text;
    
    NSMutableDictionary *parameters = [[NSMutableDictionary alloc] init];
    
    if(nutShell.length > 0)
    {
        [parameters setObject:nutShell forKey:@"bio"];
    }
    if(school.length > 0)
    {
        [parameters setObject:school forKey:@"school"];
    }
    if(occupation.length > 0)
    {
        [parameters setObject:occupation forKey:@"occupation"];
    }
    if(zodiacSign.length > 0)
    {
        [parameters setObject:zodiacSign forKey:@"zodiac"];
    }
    if(maritialStatus.length > 0)
    {
        [parameters setObject:maritialStatus forKey:@"matrial"];
    }
    if(phnNumber.length > 0)
    {
        [parameters setObject:phnNumber forKey:@"phnumber"];
    }
    if(dob.length > 0)
    {
        [parameters setObject:dob forKey:@"dob"];
    }
    if(location.length > 0)
    {
        [parameters setObject:location forKey:@"location"];
    }
    
    
    [parameters setObject:user_id forKey:@"user_id"];

    
    return parameters;
}

-(void)sendInfoToServer
{
    NSString *url = [NSString stringWithFormat:@"%@biodata.php",SERVER_URL];
    
    AFHTTPClient * Client = [[AFHTTPClient alloc] initWithBaseURL:[NSURL URLWithString:url]];
    
    
    [Client setParameterEncoding:AFJSONParameterEncoding];
    [Client postPath:@"users/login.json" parameters:[self getParameters] success:^(AFHTTPRequestOperation *operation, id responseObject){
        
        [self hideLoadingScreen];
        
        NSError *error = nil;
        NSDictionary *response = [NSJSONSerialization JSONObjectWithData:responseObject options:kNilOptions error:&error];
        
        NSString *mesage = nil;
        NSString *title = nil;
        
        if (error) {
            title = @"Error";
            mesage = [error localizedDescription];
        }
        else if ([[response objectForKey:@"status"] integerValue] == 1)
        {
            title = @"Casual";
            mesage = @"Successfully Updated";
        }
        else
        {
            title = @"Error";
            mesage = @"Some error occured";
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

#pragma -mark UItextFieldDelegate

- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    if(textField == _tfNutshell)
    {
        [_tfSchool becomeFirstResponder];
    }
    if(textField == _tfSchool)
    {
        [_tfOccupation becomeFirstResponder];
    }
    if(textField == _tfOccupation)
    {
        [_tfZodiacSign becomeFirstResponder];
    }
    if(textField == _tfZodiacSign)
    {
        [_tfMaritialStatus becomeFirstResponder];
    }
    if(textField == _tfMaritialStatus)
    {
        [_tfPhoneNumber becomeFirstResponder];
    }
    if(textField == _tfPhoneNumber)
    {
        [_tfDateOfBirth becomeFirstResponder];
    }
    if(textField == _tfDateOfBirth)
    {
        [_tfLocation becomeFirstResponder];
    }
    if(textField == _tfLocation)
    {
        [_tfLocation resignFirstResponder];
        if([self checkEnteredValues])
            [self sendInfoToServer];
        else
            [self showAlertWithMessage:@"Please enter the values" andTitle:@"Error"];
    }
    return YES;
}

@end