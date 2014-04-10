//
//  UIViewControllerCategories.h
//  HomeDemo
//
//  Created by Vikas Kumar on 12/09/13.
//  Copyright (c) 2013 Vikas Kumar. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UIViewController (UIViewControllerCategories)

-(void)showLoadingScreenWithMessage:(NSString*)message;

-(void)hideLoadingScreen;

-(void)showAlertWithMessage: (NSString* )message andTitle : (NSString*)alertTitle;

- (void)hideTabBar:(UITabBarController *) tabbarcontroller;
- (void)showTabBar:(UITabBarController *) tabbarcontroller;


-(void)logout;
-(void)loginDoneSuccessfully;

-(void)removeFacebook;
-(void)removeTwitter;

-(void) initBottombarUI;

@end
