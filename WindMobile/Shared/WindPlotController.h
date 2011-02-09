//
//  WindPlotController.h
//  WindMobile
//
//  Created by Stefan Hochuli Paychère on 29.01.11.
//  Copyright 2011 Pistache Software. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "CorePlot-CocoaTouch.h"
#import "WMReSTClient.h"
#import "StationInfo.h"


@interface WindPlotController : UIViewController <CPPlotDataSource,WMReSTClientDelegate>{
	WMReSTClient* client;
	CPXYGraph *graph;
	StationInfo *stationInfo;

	CPXYAxisSet *axisSet;
	BOOL drawAxisSet;
	BOOL isInCell;
}
@property(readwrite, retain) StationInfo *stationInfo;
@property(readwrite, retain) StationGraph *stationGraph;
@property(readwrite)BOOL drawAxisSet;
@property(readwrite)BOOL isInCell;

- (void)refreshContent:(id)sender;
- (void)stationGraph:(StationGraph*)dataPoints;

@end

@interface WindPlotController ()
- (void)startRefreshAnimation;
- (void)stopRefreshAnimation;
@end
