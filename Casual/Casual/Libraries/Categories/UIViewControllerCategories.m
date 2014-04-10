//
//  UIViewControllerCategories.m
//  HomeDemo
//
//  Created by Vikas Kumar on 12/09/13.
//  Copyright (c) 2013 Vikas Kumar. All rights reserved.
//

#import "UIViewControllerCategories.h"
#import "MBProgressHUD.h"

#define TAG_ACTIVITY_LABEL 9001

@implementation UIViewController (UIViewControllerCategories)

-(void)showLoadingScreenWithMessage:(NSString*)message
{
    
    MBProgressHUD *spinner = (MBProgressHUD*)[self.view viewWithTag:TAG_ACTIVITY_LABEL];
    
    if(!spinner)
    {
        
        spinner = [[MBProgressHUD alloc] initWithView:self.view];
        spinner.labelText = message;
        spinner.mode = MBProgressHUDModeIndeterminate;
        spinner.tag = TAG_ACTIVITY_LABEL;
        spinner.removeFromSuperViewOnHide = YES;
        
        [self.view addSubview:spinner];
        
        [spinner show:YES];
    }
    else
    {
        spinner.labelText = message;
    }

}

-(void)hideLoadingScreen
{
    MBProgressHUD *spinner = (MBProgressHUD*)[self.view viewWithTag:TAG_ACTIVITY_LABEL];
    if(spinner)
    {
        [spinner hide:YES];
    }
}

-(void)showAlertWithMessage: (NSString* )message andTitle : (NSString*)alertTitle
{
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:alertTitle
                                                    message:message
                                                   delegate:nil
                                          cancelButtonTitle:NSLocalizedString(@"OK", nil)
                                          otherButtonTitles:nil];
    [alert show];
}

- (void)hideTabBar:(UITabBarController *) tabbarcontroller
{
    [UIView beginAnimations:nil context:NULL];
    [UIView setAnimationDuration:0.1];
    
    for(UIView *view in tabbarcontroller.view.subviews)
    {
        if([view isKindOfClass:[UITabBar class]])
        {
            [view setFrame:CGRectMake(view.frame.origin.x, 568, view.frame.size.width, view.frame.size.height)];
        }
        else
        {
            [view setFrame:CGRectMake(view.frame.origin.x, view.frame.origin.y, view.frame.size.width, 568)];
        }
    }
    
    [UIView commitAnimations];
}

- (void)showTabBar:(UITabBarController *) tabbarcontroller
{
    [UIView beginAnimations:nil context:NULL];
    [UIView setAnimationDuration:0.5];
    for(UIView *view in tabbarcontroller.view.subviews)
    {
        NSLog(@"%@", view);
        
        if([view isKindOfClass:[UITabBar class]])
        {
            [view setFrame:CGRectMake(view.frame.origin.x, 431, view.frame.size.width, view.frame.size.height)];
            
        }
        else
        {
            [view setFrame:CGRectMake(view.frame.origin.x, view.frame.origin.y, view.frame.size.width, 431)];
        }
    }
    
    [UIView commitAnimations];
}
    
-(void)removeFacebook
{
    [[FBSession activeSession] closeAndClearTokenInformation];
    
    [[NSUserDefaults standardUserDefaults] removeObjectForKey:FACEBOOK_DETAILS];
    [[NSUserDefaults standardUserDefaults] removeObjectForKey:IS_FACEBOOK_ON];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

-(void)removeTwitter
{
    [[NSUserDefaults standardUserDefaults] removeObjectForKey:IS_TWITTER_ON];
    [[NSUserDefaults standardUserDefaults] synchronize];
}


- (void)logout
{
    UINavigationController* nc = [self.storyboard instantiateViewControllerWithIdentifier:@"LoginNavigationController"];
    [self.view.window setRootViewController:nc];
    [[NSUserDefaults standardUserDefaults] removeObjectForKey:IS_LOGGED_IN];
    [[NSUserDefaults standardUserDefaults] removeObjectForKey:LOCAL_SCANNED_COUNT];
    [[NSUserDefaults standardUserDefaults] synchronize];
    
    [self removeFacebook];
    [self removeTwitter];
}

-(void)loginDoneSuccessfully
{
    UITabBarController *tabBarCont = [self.storyboard instantiateViewControllerWithIdentifier:@"MainTabbarController"];
    [self.view.window setRootViewController:tabBarCont];
    [[NSUserDefaults standardUserDefaults] setBool:YES forKey:IS_LOGGED_IN];
    [[NSUserDefaults standardUserDefaults] synchronize];
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
    //  UITabBarItem *item4 = [tabBar.items objectAtIndex:4];
    
    [item0 setFinishedSelectedImage:selectedImage0 withFinishedUnselectedImage:unselectedImage0];
    [item1 setFinishedSelectedImage:selectedImage1 withFinishedUnselectedImage:unselectedImage1];
    [item2 setFinishedSelectedImage:selectedImage2 withFinishedUnselectedImage:unselectedImage2];
    [item3 setFinishedSelectedImage:selectedImage3 withFinishedUnselectedImage:unselectedImage3];
    //  [item4 setFinishedSelectedImage:selectedImage4 withFinishedUnselectedImage:unselectedImage4];
    
    
    item0.image = unselectedImage0;
    item0.selectedImage = selectedImage0;
    
    item1.image = unselectedImage1;
    item1.selectedImage = selectedImage1;
    
    item2.image = unselectedImage2;
    item2.selectedImage = selectedImage2;
    
    item3.image = unselectedImage3;
    item3.selectedImage = selectedImage3;
    
    //    item4.image = unselectedImage4;
    //    item4.selectedImage = selectedImage4;
    
    item0.imageInsets = UIEdgeInsetsMake(6, 0, -6, 0);
    item1.imageInsets = UIEdgeInsetsMake(6, 0, -6, 0);
    item2.imageInsets = UIEdgeInsetsMake(6, 0, -6, 0);
    item3.imageInsets = UIEdgeInsetsMake(6, 0, -6, 0);
    //  item4.imageInsets = UIEdgeInsetsMake(6, 0, -6, 0);
    
    if ([tabBar respondsToSelector:@selector(setBackgroundImage:)])
    {
        // set it just for this instance
        [tabBar setBackgroundImage:[UIImage imageNamed:@"TabBarBG.png"]];
        
        // set for all
        // [[UITabBar appearance] setBackgroundImage: ...
    }
}


@end
