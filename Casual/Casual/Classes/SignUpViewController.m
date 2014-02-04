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


@interface SignUpViewController () <UITextFieldDelegate>

@property (weak, nonatomic) IBOutlet UITextField *tfFirstName;
@property (weak, nonatomic) IBOutlet UITextField *tfLastName;
@property (weak, nonatomic) IBOutlet UITextField *tfEmail;
@property (weak, nonatomic) IBOutlet UITextField *tfCreatePassword;
@property (weak, nonatomic) IBOutlet UITextField *tfConfirmPassord;

- (IBAction)btnSignupClicked:(id)sender;
- (IBAction)singleTap:(id)sender;


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

@end
