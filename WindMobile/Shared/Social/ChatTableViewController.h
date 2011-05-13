//
//  TableViewController.h
//  
//
//  Created by David on 5/11/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "ChatViewController.h"
#import "StationViewDatasource.h"

@interface ChatTableViewController : UITableViewController <UITableViewDataSource> {
    NSArray *stationList;
    ChatViewController *chatViewController;
    id<StationViewDatasource> stationViewDatasource;
    Boolean refreshing;
}


@property(nonatomic,retain) NSArray *stationList;
@property(nonatomic,retain) IBOutlet id<StationViewDatasource> stationViewDatasource;
@property(nonatomic,retain) IBOutlet  ChatViewController *chatViewController;

@property() Boolean refreshing;

-(void)refreshContent:(id)sender;

- (void)startRefreshAnimation;
- (void)stopRefreshAnimation;


@end
