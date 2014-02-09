//
//  ActivityTableLeftCell.m
//  Casual
//
//  Created by Vikas kumar on 08/02/14.
//  Copyright (c) 2014 Vikas kumar. All rights reserved.
//

#import "ActivityTableLeftCell.h"

@implementation ActivityTableLeftCell

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        // Initialization code
    }
    return self;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

-(void)layoutSubviews
{
    [super layoutSubviews];
    
    if(!self.FBProfilePicView)
    {
        self.FBProfilePicView = [[FBProfilePictureView alloc] init];
        self.FBProfilePicView.frame = self.profileImageView.frame;
        self.FBProfilePicView.pictureCropping  = FBProfilePictureCroppingSquare;
        [self addSubview:self.FBProfilePicView];
    }
}

@end
