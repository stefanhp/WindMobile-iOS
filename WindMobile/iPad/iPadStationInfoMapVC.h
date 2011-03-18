//
//  iPadStationInfoMapVC.h
//  WindMobile
//
//  Created by Stefan Hochuli Paychère on 11.02.11.
//  Copyright 2011 Pistache Software. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "IASKAppSettingsViewController.h"

#import "StationInfoMapViewController.h"
#import "iPadStationInfoViewController.h"

@interface iPadStationInfoMapVC : StationInfoMapViewController<IASKSettingsDelegate, iPadStationInfoDelegate> {
	UIPopoverController *settingsPopover;
	UIPopoverController *stationsPopover;
    
    UIToolbar *toolbar;
    UIBarButtonItem *settingsItem;
    UIBarButtonItem *stationsItem;
	UIBarButtonItem *refreshItem;
    UIBarButtonItem *activityItem;    
    UIBarButtonItem *flexItem;
}
@property (retain) UIPopoverController *settingsPopover;
@property (retain) UIPopoverController *stationsPopover;
- (void)showSettingsPopover:(id)sender;
- (void)showStationsPopover:(id)sender;
@end
