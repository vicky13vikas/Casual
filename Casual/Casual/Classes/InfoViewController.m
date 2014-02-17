//
//  InfoViewController.m
//  Casual
//
//  Created by Vikas kumar on 09/02/14.
//  Copyright (c) 2014 Vikas kumar. All rights reserved.
//

#import "InfoViewController.h"
#import "AsyncImageView.h"

@interface InfoViewController ()
{
    BOOL isLoggedinUser;
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

@property (weak, nonatomic) IBOutlet UIScrollView *scrollView;
@property (weak, nonatomic) IBOutlet AsyncImageView *userImageView;
@property (weak, nonatomic) IBOutlet UIButton *btnLogout;

@end

@implementation InfoViewController

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
    
    if(_userDetail)
    {
        isLoggedinUser = NO;
        _btnLogout.titleLabel.text = @"Cancel";
    }
    else
        isLoggedinUser = YES;
}

-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    if(_userDetail == nil)
        [self setTextValuesForLoggedInUser];
    else
        [self setTextValuesForOtherUser];
}

- (void)viewDidLayoutSubviews
{
    [super viewDidLayoutSubviews];
    [self.scrollView setContentSize:CGSizeMake(_scrollView.frame.size.width, 568)];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)logoutTapped:(id)sender
{
    if(isLoggedinUser)
        [self logout];
    else
        [self.navigationController popViewControllerAnimated:YES];
}

-(void)setTextValuesForLoggedInUser
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
    
    NSString *imageURL = [NSString stringWithFormat:@"%@%@",IMAGE_SERVER_URL, [currentUser objectForKey:@"image_name"]];
    _userImageView.imageURL = [NSURL URLWithString:imageURL];
    
    
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


-(void)setTextValuesForOtherUser
{
    _tfNutshell.text = [_userDetail objectForKey:@"bio"];
    _tfSchool.text = [_userDetail objectForKey:@"school"];
    _tfOccupation.text = [_userDetail objectForKey:@"occupation"];
    _tfZodiacSign.text = [_userDetail objectForKey:@"zodiac"];
    _tfMaritialStatus.text = [_userDetail objectForKey:@"matrial"];
    _tfPhoneNumber.text = [_userDetail objectForKey:@"phnumber"];
    _tfDateOfBirth.text = [_userDetail objectForKey:@"dob"];
    _tfLocation.text = [_userDetail objectForKey:@"location"];
    
    NSString *imageURL = [NSString stringWithFormat:@"%@%@",IMAGE_SERVER_URL, [_userDetail objectForKey:@"image_name"]];
    _userImageView.imageURL = [NSURL URLWithString:imageURL];
    
    
    NSString *data = [_userDetail objectForKey:@"unique_id"];
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



-(void)setInitialInfo
{
    NSDictionary *currentUser = [[NSUserDefaults standardUserDefaults] valueForKey:LOGGEDIN_USER_DETAILS];
    
    NSMutableString *userDetailsString = [[NSMutableString alloc] init];
    
    [userDetailsString appendFormat:@" First Name  :  %@", [currentUser objectForKey:@"firstName"]];
    [userDetailsString appendFormat:@"\n\n Last Name  :  %@", [currentUser objectForKey:@"lastName"]];
    [userDetailsString appendFormat:@"\n\n Email  :  %@", [currentUser objectForKey:@"email"]];
    [userDetailsString appendFormat:@"\n\n Nutshell  :  %@", [currentUser objectForKey:@"bio"]];
    [userDetailsString appendFormat:@"\n\n Date Of Birth  :  %@", [currentUser objectForKey:@"dob"]];
    [userDetailsString appendFormat:@"\n\n School  :  %@", [currentUser objectForKey:@"school"]];
    [userDetailsString appendFormat:@"\n\n Occupation  :  %@", [currentUser objectForKey:@"occupation"]];
    [userDetailsString appendFormat:@"\n\n Zodiac Sign  :  %@", [currentUser objectForKey:@"zodiac"]];
    [userDetailsString appendFormat:@"\n\n Maritial Status  :  %@", [currentUser objectForKey:@"matrial"]];
    [userDetailsString appendFormat:@"\n\n Phone Number  :  %@", [currentUser objectForKey:@"phnumber"]];
    [userDetailsString appendFormat:@"\n\n Location  :  %@", [currentUser objectForKey:@"location"]];

}

@end
