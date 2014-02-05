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

- (IBAction)btnLoginTapped:(id)sender;

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

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)btnLoginTapped:(id)sender {
}

#pragma -mark Server Requests

-(NSDictionary*)getParameters
{
  NSDictionary * parameters = [NSDictionary dictionaryWithObjectsAndKeys:
                               _tfUsername.text, @"username",
                               _tfPassword.text, @"passwprd",
                               nil];
  
  return parameters;
}

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

@end
