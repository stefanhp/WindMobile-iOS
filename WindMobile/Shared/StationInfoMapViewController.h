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
	WMReSTClient *client;
	NSString *selectedStation;
	
	MKMapView *mapView;
	UIPopoverController *stationPopOver;
}
@property (retain) NSString *selectedStation;
@property (retain) IBOutlet MKMapView *mapView;
@property (retain) UIPopoverController *stationPopOver;
// Content
- (void)refreshContent:(id)sender;
// WMReSTClient delegate
- (void)stationList:(NSArray*)stations;
- (void)requestError:(NSString*) message details:(NSMutableDictionary *)error;

- (void)centerToLocation:(CLLocationCoordinate2D)coordinate;
- (void)centerMapAroundAnnotations:(NSArray*)annotations;
@end

@interface StationInfoMapViewController ()
- (void)startRefreshAnimation;
- (void)stopRefreshAnimation;
- (void)showStationDetail:(id)sender;
@end