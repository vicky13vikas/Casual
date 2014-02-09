//
//  ScanViewController.m
//  Casual
//
//  Created by Vikas kumar on 07/02/14.
//  Copyright (c) 2014 Vikas kumar. All rights reserved.
//

#import "ScanViewController.h"
#import <AudioToolbox/AudioToolbox.h>
#import "AFHTTPClient.h"

@interface ScanViewController () <ZXCaptureDelegate>
{
    BOOL isRequesting;
}

@property (nonatomic, strong) ZXCapture* capture;
@property (nonatomic, retain) NSString* scannedUniqueID;
@property (weak, nonatomic) IBOutlet UITextView *tvUserDetails;
@property (weak, nonatomic) IBOutlet UIImageView *qrImageView;

- (IBAction)onSingleTap:(id)sender;

@end

@implementation ScanViewController

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

    [self scanQRCode];
}

-(void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
}

-(void)viewDidDisappear:(BOOL)animated
{
    [super viewDidDisappear:animated];
    [self.capture.layer removeFromSuperlayer];
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


#pragma -mark QR Code Scan

-(void)scanQRCode
{
    self.capture = [[ZXCapture alloc] init];
    self.capture.rotation = 90.0f;
    
    // Use the back camera
    self.capture.camera = self.capture.back;
    
    self.capture.layer.frame = CGRectMake(5, 70, 310, self.view.frame.size.height - self.tabBarController.tabBar.frame.size.height - 80);
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
        {
            self.scannedUniqueID = result.text;
            [self.capture.layer removeFromSuperlayer];
            [self sendDetailsRequestFromServer];
            [self.capture stop];
        }
        else
            [self showAlertWithMessage:@"Invalid QR Code" andTitle:@"Error"];
        AudioServicesPlaySystemSound(kSystemSoundID_Vibrate);
    }
}

- (void)captureSize:(ZXCapture*)capture width:(NSNumber*)width height:(NSNumber*)height {
}



#pragma -mark Server Requests


-(NSString*)showUserDetails:(NSDictionary*)result
{
    NSString *userdata = [NSString stringWithFormat:@"You are now connected with:\n\n First name : %@\n Last name : %@\n Email : %@",
                                                    [result objectForKey:@"connected_to_firstName"],
                                                    [result objectForKey:@"connected_to_lastName"],
                                                    [result objectForKey:@"connected_to_email"]];
    
//    _tvUserDetails.text = userdata;
//    _tvUserDetails.hidden = NO;
//    _qrImageView.hidden = YES;
    return  userdata;
}

-(NSDictionary*)getParameters
{
    NSDictionary *currentUser = [[NSUserDefaults standardUserDefaults] valueForKey:LOGGEDIN_USER_DETAILS];
    NSString *user_id = [currentUser objectForKey:@"user_id"];
    
    NSDictionary * parameters = [NSDictionary dictionaryWithObjectsAndKeys:
                                 user_id, @"user_id",
                                 _scannedUniqueID, @"qr_code",
                                 nil];
    
    return parameters;
}



-(void)sendDetailsRequestFromServer
{
    
    if (!isRequesting)
    {
        isRequesting = YES;
    
    NSString *url = [NSString stringWithFormat:@"%@qrScan.php",SERVER_URL];
    
    AFHTTPClient * Client = [[AFHTTPClient alloc] initWithBaseURL:[NSURL URLWithString:url]];
    
    
    [Client setParameterEncoding:AFJSONParameterEncoding];
    [Client postPath:@"" parameters:[self getParameters] success:^(AFHTTPRequestOperation *operation, id responseObject){
        
        [self hideLoadingScreen];
        isRequesting = NO;
        
        NSError *error = nil;
        NSDictionary *response = [NSJSONSerialization JSONObjectWithData:responseObject options:kNilOptions error:&error];
        
        
//        NSDictionary *test = [NSDictionary dictionaryWithObjectsAndKeys:@"true", @"status", @"12", @"connected_to_userID", @"AB123", @"connected_to_unique_id", @"anu" , @"connected_to_firstName", @"as", @"connected_to_lastName", @"rin@gmail.com", @"connected_to_email", nil];
//        [self showUserDetails:test];

        
        NSString *mesage = nil;
        NSString *title = nil;
        
        if (error) {
            title = @"Error";
            mesage = [error localizedDescription];
        }
        else if ([[response objectForKey:@"status"] boolValue] == 1)
        {
            title = @"Congrats!";
            mesage = [self showUserDetails:response];
        }
        else if ([[response objectForKey:@"status"] isEqualToString:@"qr_invalid"])
        {
            title = @"Error";
            mesage = @"QR Code not registered.";
        }
        else if ([[response objectForKey:@"status"] isEqualToString:@"already_connected"])
        {
            title = @"Casual";
            mesage = @"You are already connected to this user.";
        }
        else
        {
            title = @"Error";
            mesage = @"Some error occured.";
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
    
}



- (IBAction)onSingleTap:(id)sender
{
    [self.view.layer addSublayer:self.capture.layer];
    [self.capture start];
}
@end
