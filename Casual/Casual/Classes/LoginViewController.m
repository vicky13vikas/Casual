//
//  LoginViewController.m
//  Casual
//
//  Created by Vikas Kumar on 05/02/14.
//  Copyright (c) 2014 Vikas kumar. All rights reserved.
//

#import "LoginViewController.h"
#import "AFHTTPClient.h"
#import "UIViewControllerCategories.h"

@interface LoginViewController ()
@property (strong, nonatomic) IBOutlet UITextField *tfUsername;
@property (strong, nonatomic) IBOutlet UITextField *tfPassword;
@property (weak, nonatomic) IBOutlet UISwitch *swtRememberMe;

@property (weak, nonatomic) IBOutlet UIScrollView *scrollView;


- (IBAction)btnLoginTapped:(id)sender;
- (IBAction)singleTap:(id)sender;

@end

@implementation LoginViewController

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
    NSString *savedUsername = [[NSUserDefaults standardUserDefaults] valueForKey:SAVED_USER_NAME];
    NSString *savedPassword = [[NSUserDefaults standardUserDefaults] valueForKey:SAVED_PASSWORD];
    
    if(savedUsername.length > 0 && savedPassword.length > 0)
    {
        _tfPassword.text = savedPassword;
        _tfUsername.text = savedUsername;
        [_swtRememberMe setOn:YES];
    }
    else
    {
        [_swtRememberMe setOn:NO];
    }
    
    [[NSUserDefaults standardUserDefaults] removeObjectForKey:SAVED_USER_NAME];
    [[NSUserDefaults standardUserDefaults] removeObjectForKey:SAVED_PASSWORD];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

- (void)viewDidLayoutSubviews
{
    [super viewDidLayoutSubviews];
    [self.scrollView setContentSize:CGSizeMake(_scrollView.frame.size.width, 380)];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)btnLoginTapped:(id)sender
{
    if([_tfPassword.text isEqualToString:@""] || [_tfUsername.text isEqualToString:@""])
    {
        [self showAlertWithMessage:@"Username or password not entered" andTitle:@"Error!"];
    }
    else
        [self sendRLoginRequest];
  
//  [self loginDoneSuccessfully];
}

- (IBAction)singleTap:(id)sender
{
    [_tfPassword resignFirstResponder];
    [_tfUsername resignFirstResponder];
}

#pragma -mark Server Requests

-(NSDictionary*)getParameters
{
  NSDictionary * parameters = [NSDictionary dictionaryWithObjectsAndKeys:
                               _tfUsername.text, @"email",
                               _tfPassword.text, @"password",
                               nil];
  
  return parameters;
}

-(NSDictionary*)checkResponseForNull:(NSDictionary*)response
{
    NSMutableArray *keys = [NSMutableArray arrayWithArray:[response allKeys]];
    NSMutableArray *values = [NSMutableArray arrayWithArray:[response allValues]];
    
    for (int i = 0; i < keys.count ; i++)
    {
        id key = keys[i];
        if ([key isKindOfClass:[NSNull class]])
        {
            [keys replaceObjectAtIndex:i withObject:@""];
        }
    }
    for (int i = 0; i < values.count ; i++)
    {
        id value = values[i];
        if ([value isKindOfClass:[NSNull class]])
        {
            [values replaceObjectAtIndex:i withObject:@""];
        }
    }
    
    NSDictionary *updatedDictionary = [NSDictionary dictionaryWithObjects:values forKeys:keys];
    return updatedDictionary;
}


-(void)sendRLoginRequest
{
  NSString *url = [NSString stringWithFormat:@"%@login.php",SERVER_URL];
  
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
        NSDictionary *updatedResponse = [self checkResponseForNull:response];
        [[NSUserDefaults standardUserDefaults] setObject:updatedResponse forKey:LOGGEDIN_USER_DETAILS];
        if(_swtRememberMe.isOn)
        {
            [[NSUserDefaults standardUserDefaults] setObject:_tfUsername.text forKey:SAVED_USER_NAME];
            [[NSUserDefaults standardUserDefaults] setObject:_tfPassword.text forKey:SAVED_PASSWORD];
        }
        [[NSUserDefaults standardUserDefaults] synchronize];
        [self loginDoneSuccessfully];
    }
    else
    {
      title = @"Error";
      mesage = @"Invalid username or password.";
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

-(UIView *)accessoryViewWithPreviousEnabled:(BOOL)previousEnabled nextEnabled:(BOOL)nextEnabled{
     UIButton *hide = [UIButton buttonWithType:UIButtonTypeCustom];
    hide.frame = CGRectMake(260, 2, 60, 30);
    [hide   setTitle:@"Hide" forState:UIControlStateNormal];
    hide.enabled = previousEnabled;
    [hide addTarget:self action:@selector(singleTap:) forControlEvents:UIControlEventTouchUpInside];
    
    UIView *transparentBlackView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 320, 34)];
    transparentBlackView.backgroundColor = [UIColor colorWithRed:0.f green:0.f blue:0.f alpha:0.6f];
    
    UIView *accessoryView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 320, 34)];
    [accessoryView addSubview:transparentBlackView];
    [accessoryView addSubview:hide];
    
    return accessoryView;
}

- (void)textFieldDidBeginEditing:(UITextField *)textField
{
    textField.inputAccessoryView = [self accessoryViewWithPreviousEnabled:YES nextEnabled:YES];
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
  if(textField == _tfUsername)
  {
    [_tfPassword becomeFirstResponder];
  }
  if(textField == _tfPassword)
  {
    [_tfPassword resignFirstResponder];
    [self btnLoginTapped:nil];
  }
  return YES;
}

@end
