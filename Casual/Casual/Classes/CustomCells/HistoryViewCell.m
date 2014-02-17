//
//  HistoryViewCell.m
//  Casual
//
//  Created by Vikas kumar on 08/02/14.
//  Copyright (c) 2014 Vikas kumar. All rights reserved.
//

#import "HistoryViewCell.h"
#import "AsyncImageView.h"

@interface HistoryViewCell()

@property (weak, nonatomic) IBOutlet AsyncImageView *userImageRight;
@property (weak, nonatomic) IBOutlet UILabel *lblMutualScansRight;
@property (weak, nonatomic) IBOutlet UILabel *lblTotalScansRight;
@property (weak, nonatomic) IBOutlet UILabel *lblDateRight;
@property (weak, nonatomic) IBOutlet UILabel *lblNameRight;

@property (weak, nonatomic) IBOutlet AsyncImageView *userImageLeft;
@property (weak, nonatomic) IBOutlet UILabel *lblMutualScansLeft;
@property (weak, nonatomic) IBOutlet UILabel *lblTotalScansLeft;
@property (weak, nonatomic) IBOutlet UILabel *lblDateLeft;
@property (weak, nonatomic) IBOutlet UILabel *lblNameLeft;

@property (weak, nonatomic) IBOutlet UIImageView *branchImageRight;
@property (weak, nonatomic) IBOutlet UILabel *lblMutualRight;
@property (weak, nonatomic) IBOutlet UILabel *lblTotalRight;
@property (weak, nonatomic) IBOutlet UILabel *lblNametextRight;

@property (weak, nonatomic) IBOutlet UIImageView *branchImageLeft;
@property (weak, nonatomic) IBOutlet UILabel *lblMutualLeft;
@property (weak, nonatomic) IBOutlet UILabel *lblTotalLeft;
@property (weak, nonatomic) IBOutlet UILabel *lblNametextLeft;



@end

@implementation HistoryViewCell

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

-(void) layoutSubviews
{
    [super layoutSubviews];
    if(self.rightSideData != nil)
    {
        [self setRightSideValues];
        [self hideRightSide:NO];
    }
    else
    {
        [self hideRightSide:YES];
    }
    
    if(self.leftSideData != nil)
    {
        [self setLeftSideValues];
        [self hideLeftSide:NO];
    }
    else
    {
        [self hideLeftSide:YES];
    }
}


-(void)hideLeftSide:(BOOL)shouldHide
{
    self.userImageLeft.hidden = shouldHide;
    self.lblMutualScansLeft.hidden = shouldHide;
    self.lblTotalScansLeft.hidden = shouldHide;
    self.lblDateLeft.hidden = shouldHide;
    self.branchImageLeft.hidden = shouldHide;
    self.lblMutualLeft.hidden = shouldHide;
    self.lblTotalLeft.hidden = shouldHide;
    self.lblNametextLeft.hidden = shouldHide;
    self.lblNameLeft.hidden = shouldHide;
}

-(void)hideRightSide:(BOOL)shouldHide
{
    self.userImageRight.hidden = shouldHide;
    self.lblMutualScansRight.hidden = shouldHide;
    self.lblTotalScansRight.hidden = shouldHide;
    self.lblDateRight.hidden = shouldHide;
    self.branchImageRight.hidden = shouldHide;
    self.lblMutualRight.hidden = shouldHide;
    self.lblTotalRight.hidden = shouldHide;
    self.lblNameRight.hidden = shouldHide;
    self.lblNametextRight.hidden = shouldHide;
}

-(void)setRightSideValues
{
    self.lblMutualScansRight.text = [NSString stringWithFormat:@"%@",(NSNumber*)[_rightSideData objectForKey:@"mutual_scan"]];
    self.lblTotalScansRight.text = [NSString stringWithFormat:@"%@",(NSNumber*)[_rightSideData objectForKey:@"scan_count"]];
    
    NSString *name = [NSString stringWithFormat:@"%@ %@", [_rightSideData objectForKey:@"firstName"], [_rightSideData objectForKey:@"lastName"]];
    self.lblNameRight.text = name;
    
    NSString *dateStr = [_rightSideData objectForKey:@"scanned_date"];
    
    NSDateFormatter *dateFormat = [[NSDateFormatter alloc] init];
    [dateFormat setDateFormat:@"yyyy-MM-dd"];
    NSDate *date = [dateFormat dateFromString:dateStr];
    
    [dateFormat setDateFormat:@"MMM d"];
    self.lblDateRight.text = [dateFormat stringFromDate:date];
    
    NSString *imageURL = [NSString stringWithFormat:@"%@%@",IMAGE_SERVER_URL, [_rightSideData objectForKey:@"image_name"]];
    _userImageRight.imageURL = [NSURL URLWithString:imageURL];
    
    UITapGestureRecognizer *tapgesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(rightSideImageTapped:)];
    [_userImageRight addGestureRecognizer:tapgesture];
    
}

-(void)setLeftSideValues
{
    self.lblMutualScansLeft.text = [NSString stringWithFormat:@"%@",(NSNumber*)[_leftSideData objectForKey:@"mutual_scan"]];
    self.lblTotalScansLeft.text = [NSString stringWithFormat:@"%@",(NSNumber*)[_leftSideData objectForKey:@"scan_count"]];

    NSString *name = [NSString stringWithFormat:@"%@ %@", [_rightSideData objectForKey:@"firstName"], [_rightSideData objectForKey:@"lastName"]];
    self.lblNameLeft.text = name;
    
    NSString *dateStr = [_leftSideData objectForKey:@"scanned_date"];
    
    NSDateFormatter *dateFormat = [[NSDateFormatter alloc] init];
    [dateFormat setDateFormat:@"yyyy-MM-dd"];
    NSDate *date = [dateFormat dateFromString:dateStr];
    
    [dateFormat setDateFormat:@"MMM d"];
    self.lblDateLeft.text = [dateFormat stringFromDate:date];
    
    NSString *imageURL = [NSString stringWithFormat:@"%@%@",IMAGE_SERVER_URL, [_leftSideData objectForKey:@"image_name"]];
    _userImageLeft.imageURL = [NSURL URLWithString:imageURL];
    
    UITapGestureRecognizer *tapgesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(leftSideImageTapped:)];
    [_userImageLeft addGestureRecognizer:tapgesture];
}

-(void)rightSideImageTapped:(id)gestureRecognizer
{
    
    [[NSNotificationCenter defaultCenter] postNotificationName:SHOW_USER_INFO_NOTIFICATION object:self.rightSideData];
}

-(void)leftSideImageTapped:(id)gestureRecognizer
{
    [[NSNotificationCenter defaultCenter] postNotificationName:SHOW_USER_INFO_NOTIFICATION object:self.leftSideData];
}

@end
