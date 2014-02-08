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
    NSString *cellIdentifier;
    if(indexPath.row % 2 == 0)
    {
        cellIdentifier = @"ActivityTableLeftCell";
        ActivityTableLeftCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
        cell.messagelabel.text  = _messageList[indexPath.row];
        
        return cell;
    }
    else
    {
        cellIdentifier = @"ActivityTableRightCell";
        ActivityTableRightCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
        cell.messageLabel.text  = _messageList[indexPath.row];
        
        return cell;
    }
}

@end
