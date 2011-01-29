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

@interface StationInfoViewController : UITableViewController<WMReSTClientDelegate,IASKSettingsDelegate> {
	WMReSTClient* client;
	NSArray *stations;
	IASKAppSettingsViewController *appSettingsViewController;
}
@property (retain)NSArray *stations;
@property (nonatomic, retain) IASKAppSettingsViewController *appSettingsViewController;

// Content
- (void)refreshContent:(id)sender;
// WMReSTClient delegate
- (void)stationList:(NSArray*)stations;
// Settings
- (void)showSettings:(id)sender;

@end
