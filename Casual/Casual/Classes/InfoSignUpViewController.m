//
//  InfoSignUpViewController.m
//  Casual
//
//  Created by Vikas Kumar on 10/02/14.
//  Copyright (c) 2014 Vikas kumar. All rights reserved.
//

#import "InfoSignUpViewController.h"
#import "AFHTTPClient.h"
#import "Base64.h"

@interface InfoSignUpViewController () <UIImagePickerControllerDelegate, UINavigationControllerDelegate>
{
    BOOL isKeyboardVisible;
}

@property (weak, nonatomic) IBOutlet UITextField *tfNutshell;
@property (weak, nonatomic) IBOutlet UITextField *tfSchool;
@property (weak, nonatomic) IBOutlet UITextField *tfOccupation;
@property (weak, nonatomic) IBOutlet UITextField *tfZodiacSign;
@property (weak, nonatomic) IBOutlet UITextField *tfMaritialStatus;
@property (weak, nonatomic) IBOutlet UITextField *tfPhoneNumber;
@property (weak, nonatomic) IBOutlet UITextField *tfDateOfBirth;
@property (weak, nonatomic) IBOutlet UITextField *tfLocation;
@property (weak, nonatomic) IBOutlet UIImageView *QRCodeImageView;
@property (weak, nonatomic) IBOutlet UIImageView *userImageView;

@property (weak, nonatomic) IBOutlet UIScrollView *scrollView;

@property (strong, nonatomic) UIImagePickerController *cameraPicker;


- (IBAction)btnSkipTapped:(id)sender;
- (IBAction)btnSaveTapped:(id)sender;
- (IBAction)userImageTapped:(UITapGestureRecognizer *)sender;

@end

@implementation InfoSignUpViewController

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
    [self setTextValues];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyBoardWillShow:) name:UIKeyboardWillShowNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyBoardWillHide:) name:UIKeyboardWillHideNotification object:nil];
}

-(void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIKeyboardWillShowNotification object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIKeyboardWillHideNotification object:nil];
}

-(void)keyBoardWillShow:(NSNotification*)notification
{
    if(!isKeyboardVisible)
    {
        isKeyboardVisible = YES;
        NSDictionary* keyboardInfo = [notification userInfo];
        NSValue* keyboardFrameBegin = [keyboardInfo valueForKey:UIKeyboardFrameBeginUserInfoKey];
        CGRect keyboardFrameBeginRect = [keyboardFrameBegin CGRectValue];
        
        CGRect frame = _scrollView.frame;
        frame.size.height = frame.size.height - keyboardFrameBeginRect.size.height;
        _scrollView.frame = frame;
    }
}

-(void)keyBoardWillHide:(NSNotification*)notification
{
    if(isKeyboardVisible)
    {
        isKeyboardVisible = NO;
        NSDictionary* keyboardInfo = [notification userInfo];
        NSValue* keyboardFrameBegin = [keyboardInfo valueForKey:UIKeyboardFrameBeginUserInfoKey];
        CGRect keyboardFrameBeginRect = [keyboardFrameBegin CGRectValue];
        
        CGRect frame = _scrollView.frame;
        frame.size.height = frame.size.height + keyboardFrameBeginRect.size.height;
        _scrollView.frame = frame;
    }
}

- (void)viewDidLayoutSubviews
{
    [super viewDidLayoutSubviews];
    [self.scrollView setContentSize:CGSizeMake(_scrollView.frame.size.width, 500)];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


-(void)setTextValues
{
    NSDictionary *currentUser = [[NSUserDefaults standardUserDefaults] valueForKey:LOGGEDIN_USER_DETAILS];
    
    
    _tfNutshell.text = [currentUser objectForKey:@"bio"];
    _tfSchool.text = [currentUser objectForKey:@"school"];
    _tfOccupation.text = [currentUser objectForKey:@"occupation"];
    _tfZodiacSign.text = [currentUser objectForKey:@"zodiac"];
    _tfMaritialStatus.text = [currentUser objectForKey:@"matrial"];
    _tfPhoneNumber.text = [currentUser objectForKey:@"phnumber"];
    _tfDateOfBirth.text = [currentUser objectForKey:@"dob"];
    _tfLocation.text = [currentUser objectForKey:@"location"];
    
    
    NSString *data = [currentUser objectForKey:@"unique_id"];
    if (data && ![data isEqualToString:@""]) {
        
        ZXMultiFormatWriter *writer = [[ZXMultiFormatWriter alloc] init];
        ZXBitMatrix *result = [writer encode:data format:kBarcodeFormatQRCode width:self.QRCodeImageView.frame.size.width height:self.QRCodeImageView.frame.size.width error:nil];
        if (result) {
            self.QRCodeImageView.image = [UIImage imageWithCGImage:[ZXImage imageWithMatrix:result].cgimage];
        } else {
            self.QRCodeImageView.image = nil;
        }
    }
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
    else
    {
        isEnteredValesOK = YES;
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
    if (_userImageView.image) {
        NSData *fileData = UIImageJPEGRepresentation(_userImageView.image, 0.30);
        NSString *encodedString = [fileData base64EncodedString];
        
        [parameters setObject:encodedString forKey:@"imgdata"];
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
            [[NSUserDefaults standardUserDefaults] setObject:response forKey:LOGGEDIN_USER_DETAILS];
            [[NSUserDefaults standardUserDefaults] synchronize];
            [self loginDoneSuccessfully];
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

-(UIView *)accessoryView {
    UIButton *hide = [UIButton buttonWithType:UIButtonTypeCustom];
    hide.frame = CGRectMake(260, 2, 60, 30);
    [hide   setTitle:@"Hide" forState:UIControlStateNormal];
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
    textField.inputAccessoryView = [self accessoryView];
}

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

- (IBAction)singleTap:(id)sender
{
    [_tfNutshell resignFirstResponder];
    [_tfSchool resignFirstResponder];
    [_tfOccupation resignFirstResponder];
    [_tfZodiacSign resignFirstResponder];
    [_tfMaritialStatus resignFirstResponder];
    [_tfPhoneNumber resignFirstResponder];
    [_tfDateOfBirth resignFirstResponder];
    [_tfLocation resignFirstResponder];
}


- (IBAction)btnSkipTapped:(id)sender
{
    [self loginDoneSuccessfully];
}

- (IBAction)btnSaveTapped:(id)sender
{
    if([self checkEnteredValues])
        [self sendInfoToServer];
    else
        [self showAlertWithMessage:@"Please enter the values" andTitle:@"Error"];
}

- (IBAction)userImageTapped:(UITapGestureRecognizer *)sender
{
    if(_cameraPicker == nil)
    {
        _cameraPicker = [[UIImagePickerController alloc] init];
        _cameraPicker.delegate = self;
    }
    
    if ([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera])
    {
        [_cameraPicker setSourceType:UIImagePickerControllerSourceTypeCamera];
    }
    else
    {
        [_cameraPicker setSourceType:UIImagePickerControllerSourceTypePhotoLibrary];
    }
    [_cameraPicker setAllowsEditing:YES];

    [self presentViewController:_cameraPicker animated:YES completion:nil];
}

#pragma -mark UIImagePickerController Delegates

- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info
{

    [_cameraPicker dismissViewControllerAnimated:NO completion:nil];
    
    UIImage *_pickedAvatar;
    
    if([picker sourceType] == UIImagePickerControllerSourceTypePhotoLibrary)
    {
        _pickedAvatar = [info objectForKey:@"UIImagePickerControllerEditedImage"];
    }
    else
    {
        _pickedAvatar = [info objectForKey:@"UIImagePickerControllerOriginalImage"];
    }
    
    _userImageView.image = _pickedAvatar;
}

- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker
{
    if([picker sourceType] == UIImagePickerControllerSourceTypePhotoLibrary)
    {
        [self dismissViewControllerAnimated:NO completion:nil];
    }
}

@end
