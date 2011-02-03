//
//  StationDetailViewController.h
//  WindMobile
//
//  Created by Stefan Hochuli Paychère on 14.05.10.
//  Copyright 2010 Pistache Software. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "WMReSTClient.h"
#import <MapKit/MapKit.h>

@class StationInfo;

@interface StationDetailViewController : UITableViewController <WMReSTClientDelegate> {
	WMReSTClient* client;

	StationInfo* stationInfo;
	StationData* stationData;
}
@property (retain) StationInfo* stationInfo; 
@property (retain) StationData* stationData; 
// Content
- (void)refreshContent:(id)sender;
// WMReSTClient delegate
- (void)stationData:(StationData*)stationData;
@end

@interface StationDetailViewController ()
- (void)startRefreshAnimation;
- (void)stopRefreshAnimation;
@end