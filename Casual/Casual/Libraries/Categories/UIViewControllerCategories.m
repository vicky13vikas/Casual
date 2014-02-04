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

@end
