//
//  TwitterServices.m
//  Casual
//
//  Created by Vikas kumar on 09/02/14.
//  Copyright (c) 2014 Vikas kumar. All rights reserved.
//

#import "TwitterServices.h"


@interface TwitterServices()

@property (nonatomic, strong) STTwitterAPI *twitter;

@end

@implementation TwitterServices


+ (STTwitterAPI *) sharedTwitter
{
    static STTwitterAPI *sharedSingleton;
    @synchronized(self)
    {
        if (!sharedSingleton)
            sharedSingleton = [STTwitterAPI twitterAPIOSWithFirstAccount];
        return sharedSingleton;
    }
}

@end
