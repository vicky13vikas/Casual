//
//  HistoryViewCell.m
//  Casual
//
//  Created by Vikas kumar on 08/02/14.
//  Copyright (c) 2014 Vikas kumar. All rights reserved.
//

#import "HistoryViewCell.h"

@interface HistoryViewCell()

@property (weak, nonatomic) IBOutlet UIImageView *userImageRight;
@property (weak, nonatomic) IBOutlet UILabel *lblMutualScansRight;
@property (weak, nonatomic) IBOutlet UILabel *lblTotalScansRight;
@property (weak, nonatomic) IBOutlet UILabel *lblDateRight;
@property (weak, nonatomic) IBOutlet UILabel *lblNameRight;

@property (weak, nonatomic) IBOutlet UIImageView *userImageLeft;
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
        [self setRightSideValues];
    else
        [self hideRightSide];
    
    if(self.leftSideData != nil)
        [self setLeftSideValues];
    else
        [self hideLeftSide];
}


-(void)hideLeftSide
{
    self.userImageLeft.hidden = YES;
    self.lblMutualScansLeft.hidden = YES;
    self.lblTotalScansLeft.hidden = YES;
    self.lblDateLeft.hidden = YES;
    self.branchImageLeft.hidden = YES;
    self.lblMutualLeft.hidden = YES;
    self.lblTotalLeft.hidden = YES;
    self.lblNametextLeft.hidden = YES;
    self.lblNameLeft.hidden = YES;
}

-(void)hideRightSide
{
    self.userImageRight.hidden = YES;
    self.lblMutualScansRight.hidden = YES;
    self.lblTotalScansRight.hidden = YES;
    self.lblDateRight.hidden = YES;
    self.branchImageRight.hidden = YES;
    self.lblMutualRight.hidden = YES;
    self.lblTotalRight.hidden = YES;
    self.lblNameRight.hidden = YES;
    self.lblNametextRight.hidden = YES;
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
}

@end
