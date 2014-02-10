//
//  InfoViewController.m
//  Casual
//
//  Created by Vikas kumar on 09/02/14.
//  Copyright (c) 2014 Vikas kumar. All rights reserved.
//

#import "InfoViewController.h"

@interface InfoViewController ()

@property (weak, nonatomic) IBOutlet UITextField *tfNutshell;
@property (weak, nonatomic) IBOutlet UITextField *tfSchool;
@property (weak, nonatomic) IBOutlet UITextField *tfOccupation;
@property (weak, nonatomic) IBOutlet UITextField *tfZodiacSign;
@property (weak, nonatomic) IBOutlet UITextField *tfMaritialStatus;
@property (weak, nonatomic) IBOutlet UITextField *tfPhoneNumber;
@property (weak, nonatomic) IBOutlet UITextField *tfDateOfBirth;
@property (weak, nonatomic) IBOutlet UITextField *tfLocation;
@property (weak, nonatomic) IBOutlet UIImageView *QRCodeImageView;

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
}

-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [self setTextValues];
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
