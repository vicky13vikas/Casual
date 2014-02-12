//
//  CheckInViewController.h
//  Casual
//
//  Created by Vikas Kumar on 07/02/14.
//  Copyright (c) 2014 Vikas kumar. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <MapKit/MapKit.h>

@interface CheckInViewController : UIViewController <MKAnnotation>

#pragma mark - MKAnnotation Protocol (for map pin)

@property (nonatomic, readonly) CLLocationCoordinate2D coordinate;
- (NSString *)title;

@end
