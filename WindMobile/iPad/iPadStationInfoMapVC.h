//
//  iPadStationInfoMapVC.h
//  WindMobile
//
//  Created by Stefan Hochuli Paychère on 11.02.11.
//  Copyright 2011 Pistache Software. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "StationInfoMapViewController.h"
#import "IASKAppSettingsViewController.h"
#import "iPadStationInfoViewController.h"

@interface iPadStationInfoMapVC : StationInfoMapViewController<IASKSettingsDelegate,iPadStationInfoDelegate> {
	UIPopoverController *settingsPopOver;
	UIPopoverController *stationsPopOver;
    
    UIToolbar *toolbar;
    UIBarButtonItem *settingsItem;
    UIBarButtonItem *titleItem;
	UIBarButtonItem *refreshItem;
    UIBarButtonItem *activityItem;    
    UIBarButtonItem *flexItem;
}
@property (retain) UIPopoverController *settingsPopOver;
@property (retain) UIPopoverController *stationsPopOver;
- (void)showSettings:(id)sender;
- (void)settingsViewControllerDidEnd:(IASKAppSettingsViewController*)sender;
- (void)titleAction:(id)sender;
@end
