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

@interface StationDetailViewController : UITableViewController {
	WMReSTClient* client;
	NSString *stationID;
	NSString *stationName;
	NSString *altitude;
	NSDictionary *stationData;
	CLLocationCoordinate2D coordinate;
}
@property (retain) NSString *stationID; 
@property (retain) NSString *stationName; 
@property (retain) NSString *altitude; 
@property (retain) NSDictionary *stationData; 
@property (nonatomic) CLLocationCoordinate2D coordinate; 
+ (NSDate*)decodeDateFromString:(NSString*)stringDate;
+ (NSString*)naturalTimeSinceDate:(NSDate*)date;
// Content
- (void)refreshContent:(id)sender;
// WMReSTClient delegate
- (void)stationData:(NSDictionary*)stationData;
@end
