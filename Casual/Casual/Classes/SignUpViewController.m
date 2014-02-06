//
//  SignUpViewController.m
//  Casual
//
//  Created by Vikas kumar on 04/02/14.
//  Copyright (c) 2014 Vikas kumar. All rights reserved.
//

#import "SignUpViewController.h"
#import "AFHTTPClient.h"
#import "UIViewControllerCategories.h"
#import <FacebookSDK/FacebookSDK.h>
#import <Twitter/Twitter.h>
#import "STTwitter.h"
#import <AudioToolbox/AudioToolbox.h>
#import <AVFoundation/AVFoundation.h>



@interface SignUpViewController () <UITextFieldDelegate, ZXCaptureDelegate>
{
    BOOL isFacebookLoggedin;
}

@property (nonatomic, strong) STTwitterAPI *twitter;
@property (nonatomic, strong) ZXCapture* capture;
@property (nonatomic, retain) NSString* unique_ID;

@property (weak, nonatomic) IBOutlet UITextField *tfFirstName;
@property (weak, nonatomic) IBOutlet UITextField *tfLastName;
@property (weak, nonatomic) IBOutlet UITextField *tfEmail;
@property (weak, nonatomic) IBOutlet UITextField *tfCreatePassword;
@property (weak, nonatomic) IBOutlet UITextField *tfConfirmPassord;
@property (weak, nonatomic) IBOutlet UIButton *btnFaceBook;
@property (weak, nonatomic) IBOutlet UIButton *btnTwitter;

- (IBAction)btnSignupClicked:(id)sender;
- (IBAction)singleTap:(id)sender;
- (IBAction)btnfaceBookTapped:(id)sender;
- (IBAction)btnTwitterTapped:(id)sender;
- (IBAction)scanQRCode:(id)sender;


@end

@implementation SignUpViewController

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

-(void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(NSDictionary*)getParameters
{
    NSDictionary * parameters = [NSDictionary dictionaryWithObjectsAndKeys:
                                  _tfFirstName.text, @"firstName",
                                  _tfLastName.text, @"lastName",
                                  _tfEmail.text, @"email",
                                  _tfCreatePassword.text, @"password",
                                 nil];
    
    return parameters;
}


#pragma -mark Server Requests

-(void)sendRegisterRequest
{
    NSString *url = [NSString stringWithFormat:@"%@register.php",SERVER_URL];
    
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
            mesage = @"Successfully Registered";
        }
        else if ([[response objectForKey:@"status"] isEqualToString:@"busy"])
        {
            title = @"Error";
            mesage = @"Email already registerd";
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

- (BOOL) isValidEmailAddress
{
    NSString *emailRegex = @"[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,4}";
    NSPredicate *emailTest = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", emailRegex];
    
    return [emailTest evaluateWithObject:_tfEmail.text];
}

-(BOOL)checkEnteredValues
{
    BOOL isEnteredValesOK = NO;
    NSString * message = nil;
    
    if([_tfFirstName.text isEqualToString:@""])
    {
        message = @"First name cannot be empty";
    }
    else if([_tfLastName.text isEqualToString:@""])
    {
        message = @"Last name cannot be empty";
    }
    else if([_tfEmail.text isEqualToString:@""])
    {
        message = @"Email cannot be empty";
    }
    else if([_tfCreatePassword.text isEqualToString:@""])
    {
        message = @"Password cannot be empty";
    }
    else if(![_tfCreatePassword.text isEqualToString:_tfConfirmPassord.text])
    {
        message = @"Passwords donot match";
    }
    else if(![self isValidEmailAddress])
    {
        message = @"Invalid Email-ID";
    }
    
    if(message == nil)
    {
        isEnteredValesOK = YES;
    }
    else
    {
        [[[UIAlertView alloc] initWithTitle:@"Casual"
                                   message:message
                                  delegate:nil
                         cancelButtonTitle:NSLocalizedString(@"OK", nil)
                          otherButtonTitles:nil] show];
    }
    
    return isEnteredValesOK;
}

- (IBAction)btnSignupClicked:(id)sender
{
    [self singleTap:nil];
    
    BOOL IsEntertedValuesOK = [self checkEnteredValues];
    if(IsEntertedValuesOK)
    {
        [self sendRegisterRequest];
    }
}

- (IBAction)singleTap:(id)sender
{
    [_tfFirstName resignFirstResponder];
    [_tfLastName resignFirstResponder];
    [_tfCreatePassword resignFirstResponder];
    [_tfConfirmPassord resignFirstResponder];
    [_tfEmail resignFirstResponder];
}

- (IBAction)btnfaceBookTapped:(id)sender
{
    [self CreateNewSession];
    [self OpenSession];
}

- (IBAction)btnTwitterTapped:(id)sender
{
  self.twitter = [STTwitterAPI twitterAPIOSWithFirstAccount];
  
  [self loginInSafariAction];
  
/*  [_twitter verifyCredentialsWithSuccessBlock:^(NSString *username) {
    NSLog(@"%@", username);
    
  } errorBlock:^(NSError *error) {
    NSLog(@"%@", error);

  }];
 */
}

- (IBAction)scanQRCode:(id)sender
{
    [self scanQRCode];
}

#pragma -mark UItextFieldDelegate

- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    if(textField == _tfFirstName)
    {
        [_tfLastName becomeFirstResponder];
    }
    if(textField == _tfLastName)
    {
        [_tfEmail becomeFirstResponder];
    }
    if(textField == _tfEmail)
    {
        [_tfCreatePassword becomeFirstResponder];
    }
    if(textField == _tfCreatePassword)
    {
        [_tfConfirmPassord resignFirstResponder];
        [self btnSignupClicked:nil];
    }

    return NO;
}


#pragma -mark FaceBook

-(void)CreateNewSession
{
    FBSession *activeSession = [[FBSession alloc] init];
    [FBSession setActiveSession: activeSession];
}

-(void)OpenSession
{
    NSArray *permissions = [[NSArray alloc] initWithObjects:
                            @"email",
                            nil];
    // Attempt to open the session. If the session is not open, show the user the Facebook login UX
    [FBSession openActiveSessionWithReadPermissions:permissions allowLoginUI:YES completionHandler:^(FBSession *session, FBSessionState status, NSError *error) {
        
        // Did something go wrong during login? I.e. did the user cancel?
        if(!error)
        {
            if (status == FBSessionStateClosedLoginFailed || status == FBSessionStateClosed || status == FBSessionStateCreatedOpening) {
                isFacebookLoggedin = false;
            }
            else {
                isFacebookLoggedin = true;
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
             _tfFirstName.text = result.first_name;
             _tfLastName.text = result.last_name;
             _tfEmail.text = [result objectForKey:@"email"];
             _btnFaceBook.enabled = NO;
         }
         else {
             [self faceBookErrorMessage];
         }
     }];
    
}

-(void)faceBookErrorMessage
{
    UIAlertView *errorAlert = [[UIAlertView alloc] initWithTitle:ALERT_TITLE message:@"Error Connecting To Facebook" delegate:nil cancelButtonTitle:ALERT_OK otherButtonTitles:nil];
    [errorAlert show];
    
}

#pragma mark - Twitter

- (void)setOAuthToken:(NSString *)token oauthVerifier:(NSString *)verifier {
  
  [_twitter postAccessTokenRequestWithPIN:verifier successBlock:^(NSString *oauthToken, NSString *oauthTokenSecret, NSString *userID, NSString *screenName) {
    NSLog(@"-- screenName: %@", screenName);
    
    
  } errorBlock:^(NSError *error) {
    
    NSLog(@"-- %@", [error localizedDescription]);
  }];
}

- (void)loginInSafariAction
{
  self.twitter = [STTwitterAPI twitterAPIWithOAuthConsumerKey:TWITTER_CONSUMER_KEY
                                               consumerSecret:TWITTER_SECRET_KEY];
  
  [_twitter postTokenRequest:^(NSURL *url, NSString *oauthToken) {
    NSLog(@"-- url: %@", url);
    NSLog(@"-- oauthToken: %@", oauthToken);
    
    [[UIApplication sharedApplication] openURL:url];
    
  } oauthCallback:@"myapp://twitter_access_tokens/"
                  errorBlock:^(NSError *error) {
                    NSLog(@"-- error: %@", error);
                  }];
}



#pragma -mark QR Code Scan

-(void)scanQRCode
{
    self.capture = [[ZXCapture alloc] init];
    self.capture.rotation = 90.0f;
    
    // Use the back camera
    self.capture.camera = self.capture.back;
    
    self.capture.layer.frame = self.view.bounds;
    [self.view.layer addSublayer:self.capture.layer];
    self.capture.delegate = self;
}

#pragma mark - ZXCaptureDelegate Methods

#pragma mark - Private Methods

- (NSString*)displayForResult:(ZXResult*)result {
    NSString *formatString;
    switch (result.barcodeFormat) {
        case kBarcodeFormatAztec:
            formatString = @"Aztec";
            break;
            
        case kBarcodeFormatCodabar:
            formatString = @"CODABAR";
            break;
            
        case kBarcodeFormatCode39:
            formatString = @"Code 39";
            break;
            
        case kBarcodeFormatCode93:
            formatString = @"Code 93";
            break;
            
        case kBarcodeFormatCode128:
            formatString = @"Code 128";
            break;
            
        case kBarcodeFormatDataMatrix:
            formatString = @"Data Matrix";
            break;
            
        case kBarcodeFormatEan8:
            formatString = @"EAN-8";
            break;
            
        case kBarcodeFormatEan13:
            formatString = @"EAN-13";
            break;
            
        case kBarcodeFormatITF:
            formatString = @"ITF";
            break;
            
        case kBarcodeFormatPDF417:
            formatString = @"PDF417";
            break;
            
        case kBarcodeFormatQRCode:
            formatString = @"QR Code";
            break;
            
        case kBarcodeFormatRSS14:
            formatString = @"RSS 14";
            break;
            
        case kBarcodeFormatRSSExpanded:
            formatString = @"RSS Expanded";
            break;
            
        case kBarcodeFormatUPCA:
            formatString = @"UPCA";
            break;
            
        case kBarcodeFormatUPCE:
            formatString = @"UPCE";
            break;
            
        case kBarcodeFormatUPCEANExtension:
            formatString = @"UPC/EAN extension";
            break;
            
        default:
            formatString = @"Unknown";
            break;
    }
    
    return [NSString stringWithFormat:@"Scanned!\n\nFormat: %@\n\nContents:\n%@", formatString, result.text];
}

- (void)captureResult:(ZXCapture*)capture result:(ZXResult*)result {
    if (result) {
        // We got a result. Display information about the result onscreen.
//        [self.decodedLabel performSelectorOnMainThread:@selector(setText:) withObject:[self displayForResult:result] waitUntilDone:YES];
        
        // Vibrate
//        NSLog(@"Scanned QR Code : %@",[self displayForResult:result]);
        
        if(result.barcodeFormat == kBarcodeFormatQRCode)
            self.unique_ID = result.text;
        else
            [self showAlertWithMessage:@"Invalid QR Code" andTitle:@"Error"];
        AudioServicesPlaySystemSound(kSystemSoundID_Vibrate);
    }
}

- (void)captureSize:(ZXCapture*)capture width:(NSNumber*)width height:(NSNumber*)height {
}

@end
