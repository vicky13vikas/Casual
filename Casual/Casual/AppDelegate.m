//
//  AppDelegate.m
//  Casual
//
//  Created by Vikas kumar on 04/02/14.
//  Copyright (c) 2014 Vikas kumar. All rights reserved.
//

#import "AppDelegate.h"
#import "SignUpViewController.h"
#import "TestFlight.h"

@implementation AppDelegate

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    if(![[NSUserDefaults standardUserDefaults] valueForKey:IS_LOGGED_IN] || ![[NSUserDefaults standardUserDefaults] valueForKey:LOGGEDIN_USER_DETAILS])
    {
        UINavigationController* nc = [[UIStoryboard storyboardWithName:@"Main_iPhone" bundle:nil] instantiateViewControllerWithIdentifier:@"LoginNavigationController"];
        self.window.rootViewController = nc;
    }
 

    
    // Override point for customization after application launch.
    [TestFlight takeOff:@"c9307895-8ab9-4fb0-8414-b43c2af349d2"];
    
    return YES;
}
							
- (void)applicationWillResignActive:(UIApplication *)application
{
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
}

- (void)applicationDidEnterBackground:(UIApplication *)application
{
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later. 
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
}

- (void)applicationWillEnterForeground:(UIApplication *)application
{
    // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
}

- (void)applicationDidBecomeActive:(UIApplication *)application
{
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
    [FBAppCall handleDidBecomeActive];
    [[FBSession activeSession] handleDidBecomeActive];
}

- (void)applicationWillTerminate:(UIApplication *)application
{
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
}


- (NSDictionary *)parametersDictionaryFromQueryString:(NSString *)queryString {
  
  NSMutableDictionary *md = [NSMutableDictionary dictionary];
  
  NSArray *queryComponents = [queryString componentsSeparatedByString:@"&"];
  
  for(NSString *s in queryComponents) {
    NSArray *pair = [s componentsSeparatedByString:@"="];
    if([pair count] != 2) continue;
    
    NSString *key = pair[0];
    NSString *value = pair[1];
    
    md[key] = value;
  }
  
  return md;
}

- (BOOL)application:(UIApplication *)application openURL:(NSURL *)url
  sourceApplication:(NSString *)sourceApplication annotation:(id)annotation {
    
    [[FBSession activeSession] handleOpenURL:url];
  
  if ([[url scheme] isEqualToString:@"myapp"] == NO) return NO;
  
  NSDictionary *d = [self parametersDictionaryFromQueryString:[url query]];
  
  NSString *token = d[@"oauth_token"];
  NSString *verifier = d[@"oauth_verifier"];
  
  SignUpViewController *vc = (SignUpViewController *)[(UINavigationController*)[[self window] rootViewController] topViewController];
  [vc setOAuthToken:token oauthVerifier:verifier];
  
  return YES;
}


@end
