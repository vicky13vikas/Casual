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
@end
