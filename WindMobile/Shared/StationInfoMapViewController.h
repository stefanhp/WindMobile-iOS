//
//  StationInfoMapViewController.h
//  WindMobile
//
//  Created by Stefan Hochuli Paychère on 10.02.11.
//  Copyright 2011 Pistache Software. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "WMReSTClient.h"
#import "StationListViewController.h"

@class MapViewController;

@interface StationInfoMapViewController : UIViewController <WMReSTClientDelegate, StationListDelegate,MKMapViewDelegate,UITabBarControllerDelegate> {
	UIToolbar *toolBar;
	UIBarButtonItem *titleItem;
	UIBarButtonItem *flexItem;
	UIBarButtonItem *refreshItem;
	UIBarButtonItem *activityItem;
	
	WMReSTClient *client;
	NSArray *stations;
	NSMutableArray *visibleStations;
	
	UIView *mainView;
	UIView *mapView;
	MapViewController *map;
	UIPopoverController *stationPopOver;
}
@property (retain) IBOutlet UIToolbar *toolBar;
@property (retain) NSArray *stations;
@property (retain) NSMutableArray *visibleStations;
@property (retain) IBOutlet UIView *mainView;
@property (retain) IBOutlet UIView *mapView;
@property (retain) UIPopoverController *stationPopOver;
@property (readonly) MapViewController *map;
// Content
- (void)refreshContent:(id)sender;
// WMReSTClient delegate
- (void)stationList:(NSArray*)stations;
- (void)requestError:(NSString*) message details:(NSMutableDictionary *)error;

- (void)titleAction:(id)sender;
@end

@interface StationInfoMapViewController ()
- (void)startRefreshAnimation;
- (void)stopRefreshAnimation;
- (void)showStationDetail:(id)sender;
@end