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
    [[NSUserDefaults standardUserDefaults] synchronize];
}

-(void)loginDoneSuccessfully
{
    UITabBarController *tabBarCont = [self.storyboard instantiateViewControllerWithIdentifier:@"MainTabbarController"];
    [self.view.window setRootViewController:tabBarCont];
    [[NSUserDefaults standardUserDefaults] setBool:YES forKey:IS_LOGGED_IN];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

@end
