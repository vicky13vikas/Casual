//
//  ActivityTableDatasource.h
//  Casual
//
//  Created by Vikas kumar on 08/02/14.
//  Copyright (c) 2014 Vikas kumar. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef enum
{
    kStatustypeFacebook,
    kStatustypeTwitter
}SelectedSource;

@interface ActivityTableDatasource : NSObject <UITableViewDataSource, UITableViewDelegate>

@property (nonatomic, retain)NSArray *messageList;

@property (nonatomic) SelectedSource datasource;

@end
