//
//  iPadStationInfoMapVC.h
//  WindMobile
//
//  Created by Stefan Hochuli Paychère on 11.02.11.
//  Copyright 2011 Pistache Software. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "StationInfoMapViewController.h"

@interface iPadStationInfoMapVC : StationInfoMapViewController {
	UIBarButtonItem *settingsItem;

}
- (void)showSettings:(id)sender;
@end
