  //
//  PostViewController.m
//  Casual
//
//  Created by Vikas Kumar on 07/02/14.
//  Copyright (c) 2014 Vikas kumar. All rights reserved.
//

#import "PostViewController.h"

@interface PostViewController ()<UIActionSheetDelegate, UIImagePickerControllerDelegate, UINavigationControllerDelegate>

@property (strong, nonatomic) IBOutlet UITextView *tfPostStatus;
@property (strong, nonatomic) FBProfilePictureView *profilePciView;
@property (strong, nonatomic) IBOutlet UIImageView *userImageView;
@property (weak, nonatomic) IBOutlet UIImageView *imageToPost;

@property (strong, nonatomic) UIImagePickerController *cameraPicker;



- (IBAction)postToFacebook:(id)sender;
- (IBAction)attachImageClicked:(id)sender;

@end

@implementation PostViewController

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
    
    NSString *userID = [[[NSUserDefaults standardUserDefaults] objectForKey:FACEBOOK_DETAILS] objectForKey:@"id"];
    _profilePciView = [[FBProfilePictureView alloc] initWithProfileID:userID pictureCropping:FBProfilePictureCroppingSquare];
    _profilePciView.frame = _userImageView.frame;
    [self.view addSubview:_profilePciView];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


#pragma -mark Facebook Posting

- (IBAction)postToFacebook:(id)sender
{
    [_tfPostStatus resignFirstResponder];
    if([_tfPostStatus.text isEqualToString:@""])
    {
        [self showAlertWithMessage:@"Please write your status before posting." andTitle:@"Empty status"];
    }
    else
    {
        if([[FBSession activeSession] isOpen])
        {
            if (([[[FBSession activeSession]permissions]indexOfObject:@"publish_actions"] == NSNotFound))
            {
                [self RequestWritePermissions];
            }
            else
                [self post];
        }
        else if([[FBSession activeSession] state] == FBSessionStateCreatedTokenLoaded)
        {
            [[FBSession activeSession] openWithCompletionHandler:^(FBSession *session, FBSessionState status, NSError *error) {
                if (([[[FBSession activeSession]permissions]indexOfObject:@"publish_actions"] == NSNotFound))
                {
                    [self RequestWritePermissions];
                }
                else
                    [self post];
            }];
        }
        else
        {
            [self showAlertWithMessage:@"Please allow Facebook in settings page" andTitle:@"Facebook not signed In"];
        }
   
    }
}

- (IBAction)attachImageClicked:(id)sender
{
    [_tfPostStatus resignFirstResponder];
    UIActionSheet *actionSheet = [[UIActionSheet alloc] initWithTitle:@"Choose image from" delegate:self cancelButtonTitle:@"Cancel" destructiveButtonTitle:nil otherButtonTitles:@"Camera", @"Saved images", nil];
    [actionSheet showInView:[self.view window]];
}

- (void) post
{
    [self showLoadingScreenWithMessage:@"Posting..."];
/*  [[FBRequest requestForPostStatusUpdate:_tfPostStatus.text]
   startWithCompletionHandler:
   ^(FBRequestConnection *connection, NSDictionary<FBGraphUser> *result, NSError *error)
   {
       [self hideLoadingScreen];
     // Did everything come back okay with no errors?
     if (!error && result) {
       [self showAlertWithMessage:@"Posted Successfully" andTitle:nil];
       [self.navigationController popViewControllerAnimated:YES];
     }
     else {
       [self showAlertWithMessage:@"Error Posting to Facebook" andTitle:@"Error"];
     }
   }];   */
    
    NSDictionary *params = [NSDictionary dictionaryWithObjectsAndKeys:_tfPostStatus.text, @"message",
                                                                      _imageToPost.image, @"source",
                                                                    nil];
    
    [FBRequestConnection startWithGraphPath:@"/me/photos"
                                 parameters:params
                                 HTTPMethod:@"POST"
                          completionHandler:^(
                                              FBRequestConnection *connection,
                                              id result,
                                              NSError *error
                                              ) {
                              [self hideLoadingScreen];
                              // Did everything come back okay with no errors?
                              if (!error && result) {
                                  [self showAlertWithMessage:@"Posted Successfully" andTitle:nil];
                                  [self.navigationController popViewControllerAnimated:YES];
                              }
                              else {
                                  [self showAlertWithMessage:@"Error Posting to Facebook" andTitle:@"Error"];
                              }
                          }];
}

-(void)faceBookErrorMessage
{
  UIAlertView *errorAlert = [[UIAlertView alloc] initWithTitle:ALERT_TITLE message:@"Error Connecting To Facebook" delegate:nil cancelButtonTitle:ALERT_OK otherButtonTitles:nil];
  [errorAlert show];
  
}

-(void)RequestWritePermissions
{
    NSArray *permissions = [[NSArray alloc] initWithObjects:
                            @"publish_actions", nil];
    
    [[FBSession activeSession] requestNewPublishPermissions:permissions defaultAudience:FBSessionDefaultAudienceFriends completionHandler:^(FBSession *session, NSError *error)
      {
        if (!error) {
          [self post];
        }
        else
        {
          [self showAlertWithMessage:@"Error Posting to Facebook" andTitle:@"Error"];
        }
    }];
}


#pragma -mark UIActionsheetDelegate

- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if(buttonIndex == 0)
    {
        [self showImagePickerWithSourceType:UIImagePickerControllerSourceTypeCamera];
    }
    else if(buttonIndex == 1)
    {
        [self showImagePickerWithSourceType:UIImagePickerControllerSourceTypePhotoLibrary];
    }
}

- (void)showImagePickerWithSourceType:(UIImagePickerControllerSourceType)imageSource
{
    if(_cameraPicker == nil)
    {
        _cameraPicker = [[UIImagePickerController alloc] init];
        _cameraPicker.delegate = self;
    }
    
    [_cameraPicker setSourceType:imageSource];

    [_cameraPicker setAllowsEditing:YES];
    
    [self presentViewController:_cameraPicker animated:YES completion:nil];
}


#pragma -mark UIImagePickerController Delegates

- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info
{
    
    [_cameraPicker dismissViewControllerAnimated:NO completion:nil];
    
    UIImage *_pickedAvatar;
    _pickedAvatar = [info objectForKey:@"UIImagePickerControllerEditedImage"];
    _imageToPost.image = _pickedAvatar;
}

- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker
{
    if([picker sourceType] == UIImagePickerControllerSourceTypePhotoLibrary)
    {
        [self dismissViewControllerAnimated:NO completion:nil];
    }
}


@end
