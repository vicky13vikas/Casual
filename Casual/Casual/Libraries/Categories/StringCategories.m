//
//  StringCategories.m
//  Heleni
//
//  Created by Cicero Rolim on 06/05/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "StringCategories.h"


@implementation NSString (StringCategories)

- (BOOL) isValidEmailAddress
{
    NSString *emailRegex = @"[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,4}"; 
    NSPredicate *emailTest = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", emailRegex]; 
    
    return [emailTest evaluateWithObject:self];
}

- (NSString*) leftSubstringWithLenght: (NSUInteger) size
{
    if (size > [self length])
        return nil;
    else
        return [self substringWithRange:NSMakeRange(0, size)];
    
}

- (NSString*) rightSubstringWithLenght: (NSUInteger) size
{
    if (size > [self length])
        return nil;
    else
        return [self substringWithRange:NSMakeRange([self length] -size, size)];
}

- (NSString*) escapeHTMLChars
{
    return [self stringByReplacingOccurrencesOfString:@"&" withString:@"&amp;"];
}



@end
