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

@interface iPadStationInfoMapVC : StationInfoMapViewController<IASKSettingsDelegate> {
	UIBarButtonItem *settingsItem;
	UIPopoverController *settingsPopOver;
	UIPopoverController *stationsPopOver;
}
@property (retain) UIPopoverController *settingsPopOver;
@property (retain) UIPopoverController *stationsPopOver;
- (void)showSettings:(id)sender;
- (void)settingsViewControllerDidEnd:(IASKAppSettingsViewController*)sender;

@end
