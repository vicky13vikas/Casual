//
//  ActivityTableLeftCell.h
//  Casual
//
//  Created by Vikas kumar on 08/02/14.
//  Copyright (c) 2014 Vikas kumar. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "AsyncImageView.h"

@interface ActivityTableLeftCell : UITableViewCell

@property (weak, nonatomic) IBOutlet UILabel *messageLabel;
@property (weak, nonatomic) IBOutlet AsyncImageView *profileImageView;
@property (weak, nonatomic) IBOutlet UILabel *lblUserName;
@property (nonatomic, retain)FBProfilePictureView *FBProfilePicView;

@end
