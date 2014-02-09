//
//  TwitterServices.h
//  Casual
//
//  Created by Vikas kumar on 09/02/14.
//  Copyright (c) 2014 Vikas kumar. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "STTwitter.h"

@interface TwitterServices : NSObject

+ (STTwitterAPI *) sharedTwitter;

@end
