//
//  HomeViewController.m
//  Casual
//
//  Created by Vikas kumar on 05/02/14.
//  Copyright (c) 2014 Vikas kumar. All rights reserved.
//

#import "HomeViewController.h"

@interface HomeViewController ()
@property (strong, nonatomic) IBOutlet UILabel *lblTotalScans;
@property (strong, nonatomic) IBOutlet UILabel *lblMutualScans;

@end

@implementation HomeViewController

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
    [self initFAcebook];
    [self initBottombarUI];
}

-(void) initBottombarUI
{
  
  UIImage *selectedImage0 = [UIImage imageNamed:@"BtnHome_Sel.png"];
  UIImage *unselectedImage0 = [UIImage imageNamed:@"BtnHome.png"];
  
  UIImage *selectedImage1 = [UIImage imageNamed:@"BtnScan_Sel.png"];
  UIImage *unselectedImage1 = [UIImage imageNamed:@"BtnScan.png"];
  
  UIImage *selectedImage2 = [UIImage imageNamed:@"BtnHistory_Sel.png"];
  UIImage *unselectedImage2 = [UIImage imageNamed:@"BtnHistory.png"];
  
  UIImage *selectedImage3 = [UIImage imageNamed:@"BtnActivites_Sel.png"];
  UIImage *unselectedImage3 = [UIImage imageNamed:@"BtnActivites.png"];
    
  UIImage *selectedImage4 = [UIImage imageNamed:@"btnInfo_Sel.png"];
  UIImage *unselectedImage4 = [UIImage imageNamed:@"btnInfo.png"];
  
  UITabBar *tabBar = self.tabBarController.tabBar;
  
  UITabBarItem *item0 = [tabBar.items objectAtIndex:0];
  UITabBarItem *item1 = [tabBar.items objectAtIndex:1];
  UITabBarItem *item2 = [tabBar.items objectAtIndex:2];
  UITabBarItem *item3 = [tabBar.items objectAtIndex:3];
  UITabBarItem *item4 = [tabBar.items objectAtIndex:4];
  
  [item0 setFinishedSelectedImage:selectedImage0 withFinishedUnselectedImage:unselectedImage0];
  [item1 setFinishedSelectedImage:selectedImage1 withFinishedUnselectedImage:unselectedImage1];
  [item2 setFinishedSelectedImage:selectedImage2 withFinishedUnselectedImage:unselectedImage2];
  [item3 setFinishedSelectedImage:selectedImage3 withFinishedUnselectedImage:unselectedImage3];
  [item4 setFinishedSelectedImage:selectedImage4 withFinishedUnselectedImage:unselectedImage4];
  
    
    item0.image = unselectedImage0;
//    item0.selectedImage = selectedImage0;
    
    item1.image = unselectedImage1;
//    item1.selectedImage = selectedImage1;
    
    item2.image = unselectedImage2;
//    item2.selectedImage = selectedImage2;
    
    item3.image = unselectedImage3;
//    item3.selectedImage = selectedImage3;
    
    item4.image = unselectedImage4;
//    item4.selectedImage = selectedImage4;
  
  item0.imageInsets = UIEdgeInsetsMake(6, 0, -6, 0);
  item1.imageInsets = UIEdgeInsetsMake(6, 0, -6, 0);
  item2.imageInsets = UIEdgeInsetsMake(6, 0, -6, 0);
  item3.imageInsets = UIEdgeInsetsMake(6, 0, -6, 0);
  item4.imageInsets = UIEdgeInsetsMake(6, 0, -6, 0);
  
  if ([tabBar respondsToSelector:@selector(setBackgroundImage:)])
  {
    // set it just for this instance
    [tabBar setBackgroundImage:[UIImage imageNamed:@"TabBarBG.png"]];
    
    // set for all
    // [[UITabBar appearance] setBackgroundImage: ...
  }
}

-(void)getLoginDetails
{
    NSDictionary *currentUser = [[NSUserDefaults standardUserDefaults] valueForKey:LOGGEDIN_USER_DETAILS];
    
    NSString *totalScans = [currentUser objectForKey:@"scan_count"];
    NSString *mutualScans = [currentUser objectForKey:@"mutualScans"];
    
    if(totalScans && ![totalScans isEqualToString:@""])
    {
        _lblTotalScans.text = totalScans;
    }
    else
    {
        _lblTotalScans.text = @"0";
    }
    
    if(mutualScans && ![mutualScans isEqualToString:@""])
    {
        _lblMutualScans.text = mutualScans;
    }
    else
    {
        _lblMutualScans.text = @"0";
    }
    
}

-(void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    if(![[NSUserDefaults standardUserDefaults] valueForKey:IS_LOGGED_IN] || ![[NSUserDefaults standardUserDefaults] valueForKey:LOGGEDIN_USER_DETAILS])
    {
        [self logout];
    }
    else
    {
        [self getLoginDetails];
    }
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

#pragma - INIT Facebook

-(void)fetchUserDetails
{
    [[FBRequest requestForMe]
     startWithCompletionHandler:
     ^(FBRequestConnection *connection, NSDictionary<FBGraphUser> *result, NSError *error)
     {
         // Did everything come back okay with no errors?
         if (!error && result) {
             [[NSUserDefaults standardUserDefaults] setObject:result forKey:FACEBOOK_DETAILS];
             [[NSUserDefaults standardUserDefaults] synchronize];
         }
         else {
             
         }
     }];
    
}

-(void) initFAcebook
{
    if([[FBSession activeSession] state] == FBSessionStateCreatedTokenLoaded)
    {
        [[FBSession activeSession] openWithCompletionHandler:^(FBSession *session, FBSessionState status, NSError *error) {
            
            if(status == FBSessionStateOpen)
            {
                if(![[NSUserDefaults standardUserDefaults] objectForKey:FACEBOOK_DETAILS])
                    [self fetchUserDetails];
            }
        }];
    }
}


@end
