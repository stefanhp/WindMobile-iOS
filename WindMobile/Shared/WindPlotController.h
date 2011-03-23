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
#import "StationDetailMeteoViewController.h"


@interface WindPlotController : UIViewController <CPPlotDataSource, WMReSTClientDelegate> {
	WMReSTClient* client;
	
	CPXYGraph *graph;
	CPGraphHostingView *hostingView;
	
	StationInfo *stationInfo;
	StationGraphData *stationGraphData;
	
	CPXYAxisSet *axisSet;
	
	NSString *duration;
    UIButton *info;
	UISegmentedControl *scale;
    StationDetailMeteoViewController *masterController;
}
@property(retain) IBOutlet CPGraphHostingView* hostingView;
@property(retain) StationInfo* stationInfo;
@property(retain) StationGraphData* stationGraphData;
@property(retain) NSString* duration;
@property(retain) IBOutlet UIButton *info;
@property(retain) IBOutlet UISegmentedControl *scale;
@property(retain) StationDetailMeteoViewController *masterController;

- (void)refreshContent:(id)sender;
- (IBAction)setInterval:(id)sender;
- (IBAction)showInfo:(id)sender;
- (IBAction)showScale:(id)sender;
- (NSUInteger)numberOfRecordsForPlot:(CPPlot *)plot;
@end

@interface WindPlotController ()
- (void)startRefreshAnimation;
- (void)stopRefreshAnimation;
- (void)setupButtons;
@end
