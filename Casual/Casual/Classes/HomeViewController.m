//
//  HomeViewController.m
//  Casual
//
//  Created by Vikas kumar on 05/02/14.
//  Copyright (c) 2014 Vikas kumar. All rights reserved.
//

#import "HomeViewController.h"

@interface HomeViewController ()

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
    
    UIImage *selectedImage0 = [UIImage imageNamed:@"BtnHome.png"];
    UIImage *unselectedImage0 = [UIImage imageNamed:@"BtnHome.png"];
    
    UIImage *selectedImage1 = [UIImage imageNamed:@"BtnScan.png"];
    UIImage *unselectedImage1 = [UIImage imageNamed:@"BtnScan.png"];
    
    UIImage *selectedImage2 = [UIImage imageNamed:@"BtnHistory.png"];
    UIImage *unselectedImage2 = [UIImage imageNamed:@"BtnHistory.png"];
    
    UIImage *selectedImage3 = [UIImage imageNamed:@"BtnActivites.png"];
    UIImage *unselectedImage3 = [UIImage imageNamed:@"BtnActivites.png"];
    
    UITabBar *tabBar = self.tabBarController.tabBar;
    
    UITabBarItem *item0 = [tabBar.items objectAtIndex:0];
    UITabBarItem *item1 = [tabBar.items objectAtIndex:1];
    UITabBarItem *item2 = [tabBar.items objectAtIndex:2];
    UITabBarItem *item3 = [tabBar.items objectAtIndex:3];
    
    [item0 setFinishedSelectedImage:selectedImage0 withFinishedUnselectedImage:unselectedImage0];
    [item1 setFinishedSelectedImage:selectedImage1 withFinishedUnselectedImage:unselectedImage1];
    [item2 setFinishedSelectedImage:selectedImage2 withFinishedUnselectedImage:unselectedImage2];
    [item3 setFinishedSelectedImage:selectedImage3 withFinishedUnselectedImage:unselectedImage3];
    
    item0.imageInsets = UIEdgeInsetsMake(6, 0, -6, 0);
    item1.imageInsets = UIEdgeInsetsMake(6, 0, -6, 0);
    item2.imageInsets = UIEdgeInsetsMake(6, 0, -6, 0);
    item3.imageInsets = UIEdgeInsetsMake(6, 0, -6, 0);
    
    if ([tabBar respondsToSelector:@selector(setBackgroundImage:)])
    {
        // set it just for this instance
        [tabBar setBackgroundImage:[UIImage imageNamed:@"TabBarBG.png"]];
        
        // set for all
        // [[UITabBar appearance] setBackgroundImage: ...
    }
    
    [super viewDidLoad];
	// Do any additional setup after loading the view.
}

-(void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    if(![[NSUserDefaults standardUserDefaults] valueForKey:IS_LOGGED_IN])
    {
        [self logout];
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
@end
