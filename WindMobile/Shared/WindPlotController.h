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
	CPGraphHostingView *hostingView;
	StationInfo *stationInfo;

	CPXYAxisSet *axisSet;
	BOOL drawAxisSet;
	BOOL isInCell;
	
	NSString *duration;
	UISegmentedControl *scale;
	UIButton *info;
}
@property(readwrite, retain) IBOutlet CPGraphHostingView *hostingView;
@property(readwrite, retain) StationInfo *stationInfo;
@property(readwrite, retain) StationGraph *stationGraph;
@property(readwrite)BOOL drawAxisSet;
@property(readwrite)BOOL isInCell;
@property(readwrite, retain) NSString* duration;
@property(readwrite, retain) IBOutlet UISegmentedControl *scale;
@property(readwrite, retain) IBOutlet UIButton *info;

- (void)refreshContent:(id)sender;
- (void)stationGraph:(StationGraph*)dataPoints;
- (IBAction)setInterval:(id)sender;
- (IBAction)showScale:(id)sender;
- (NSUInteger)numberOfRecordsForPlot:(CPPlot *)plot;
@end

@interface WindPlotController ()
- (void)startRefreshAnimation;
- (void)stopRefreshAnimation;
- (void)setupButtons;
@end
