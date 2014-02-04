//
//  StringCategories.h
//  Heleni
//
//  Created by Cicero Rolim on 06/05/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>


@interface NSString (StringCategories)

- (BOOL) isValidEmailAddress;

- (NSString*) leftSubstringWithLenght: (NSUInteger) size;

- (NSString*) rightSubstringWithLenght: (NSUInteger) size;

- (NSString*) escapeHTMLChars;



@end
