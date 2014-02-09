//
//  InfoViewController.m
//  Casual
//
//  Created by Vikas kumar on 09/02/14.
//  Copyright (c) 2014 Vikas kumar. All rights reserved.
//

#import "InfoViewController.h"

@interface InfoViewController ()

@property (weak, nonatomic) IBOutlet UITextView *tvInfo;
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
    
    [self setInitialInfo];
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

    
    self.tvInfo.text = userDetailsString;

}

@end
