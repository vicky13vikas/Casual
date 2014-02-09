//
//  ActivityTableDatasource.m
//  Casual
//
//  Created by Vikas kumar on 08/02/14.
//  Copyright (c) 2014 Vikas kumar. All rights reserved.
//

#import "ActivityTableDatasource.h"
#import "ActivityTableLeftCell.h"
#import "ActivityTableRightCell.h"
#import "NSDate+NVTimeAgo.h"

@implementation ActivityTableDatasource

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if(_messageList && _messageList.count > 0)
       return _messageList.count;
    
    return 0;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSDictionary *cellData = _messageList[indexPath.row];
    NSString *cellIdentifier;
    if(indexPath.row % 2 == 0)
    {
        cellIdentifier = @"ActivityTableLeftCell";
        ActivityTableLeftCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
        cell.messageLabel.text = [cellData objectForKey:@"status"];
        cell.lblUserName.text = [cellData objectForKey:@"screenName"];
        
        if(_datasource == kStatustypeFacebook)
        {
            cell.FBProfilePicView.hidden = NO;
            cell.FBProfilePicView.profileID = [cellData objectForKey:@"imageURL_OR_ID"];
        }
        else
        {
            cell.FBProfilePicView.hidden = YES;
            cell.profileImageView.imageURL = [NSURL URLWithString:[cellData objectForKey:@"imageURL_OR_ID"]];
        }
        
        cell.lblDate.text = [self getParsedDateFromString:[cellData objectForKey:@"date"]];
        return cell;
    }
    else
    {
        cellIdentifier = @"ActivityTableRightCell";
        ActivityTableRightCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
        cell.messageLabel.text = [cellData objectForKey:@"status"];
        cell.lblUserName.text = [cellData objectForKey:@"screenName"];
        
        if(_datasource == kStatustypeFacebook)
        {
            cell.FBProfilePicView.hidden = NO;
            cell.FBProfilePicView.profileID = [cellData objectForKey:@"imageURL_OR_ID"];
        }
        else
        {
            cell.FBProfilePicView.hidden = YES;
            cell.profileImageView.imageURL = [NSURL URLWithString:[cellData objectForKey:@"imageURL_OR_ID"]];
        }
        
        cell.lblDate.text = [self getParsedDateFromString:[cellData objectForKey:@"date"]];
        return cell;
    }
}


-(NSString*)getParsedDateFromString:(NSString*)dateString;
{
    NSDateFormatter *df = [[[NSDateFormatter alloc] init] autorelease];
    //Wed Dec 01 17:08:03 +0000 2010
    if(_datasource == kStatustypeFacebook)
    {
        [df setDateFormat:@"yyyy-MM-dd'T'HH:mm:ssZZZZ"];
    }
    else
    {
        [df setDateFormat:@"eee MMM dd HH:mm:ss ZZZZ yyyy"];
    }
    NSDate *date = [df dateFromString:dateString];
    [df setDateFormat:@"MMM dd yyyy"];
    NSString *dateStr = [df stringFromDate:date];
    
    NSString *timeAgo = [date formattedAsTimeAgo];
    return timeAgo;
}

@end
