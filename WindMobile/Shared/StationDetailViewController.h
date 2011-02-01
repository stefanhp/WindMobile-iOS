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

@interface StationDetailViewController : UITableViewController {
	WMReSTClient* client;

	StationInfo* stationInfo;
	NSDictionary *stationData;
}
@property (retain) StationInfo *stationInfo; 
@property (retain) NSDictionary *stationData; 
+ (NSDate*)decodeDateFromString:(NSString*)stringDate;
+ (NSString*)naturalTimeSinceDate:(NSDate*)date;
// Content
- (void)refreshContent:(id)sender;
// WMReSTClient delegate
- (void)stationData:(NSDictionary*)stationData;
@end
