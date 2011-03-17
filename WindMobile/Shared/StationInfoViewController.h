//
//  StationInfoViewController.h
//  WindMobile
//
//  Created by Stefan Hochuli Paychère on 14.05.10.
//  Copyright 2010 Pistache Software. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "WMReSTClient.h"
#import "IASKAppSettingsViewController.h"

@interface StationInfoViewController : UITableViewController<WMReSTClientDelegate> {
	WMReSTClient* client;
	NSArray *stations;
}
@property (retain)NSArray *stations;

// Content
- (void)refreshContent:(id)sender;
@end

@interface StationInfoViewController ()
- (void)startRefreshAnimation;
- (void)stopRefreshAnimation;
@end