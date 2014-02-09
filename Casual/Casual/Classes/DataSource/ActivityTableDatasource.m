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
        return cell;
    }
}

@end
