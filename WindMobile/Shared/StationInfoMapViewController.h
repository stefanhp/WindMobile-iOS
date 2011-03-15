//
//  StationInfoMapViewController.h
//  WindMobile
//
//  Created by Stefan Hochuli Paychère on 10.02.11.
//  Copyright 2011 Pistache Software. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <MapKit/MapKit.h>

#import "WMReSTClient.h"
#import "StationInfo.h"

@class MapViewController;

@interface StationInfoMapViewController : UIViewController <WMReSTClientDelegate, MKMapViewDelegate, UITabBarControllerDelegate> {
	WMReSTClient *client;
	
	MKMapView *mapView;
	UIPopoverController *stationPopOver;
@protected
	StationInfo *selectedStation;
}
@property (retain) IBOutlet MKMapView *mapView;
@property (retain) UIPopoverController *stationPopOver;
@property (readonly) NSArray *stations;
- (StationInfo *) getSelectedStation;
- (void)selectStation:(StationInfo *)station;
- (void)refresh;
- (void)centerAroundAnnotations:(NSArray *)annotations;
- (void)centerAroundStation:(StationInfo *)station;
@end