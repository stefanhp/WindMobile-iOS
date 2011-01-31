//
//  WindPlotController.h
//  WindMobile
//
//  Created by Stefan Hochuli Paychère on 29.01.11.
//  Copyright 2011 Pistache Software. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "CorePlot-CocoaTouch.h"


@interface WindPlotController : UIViewController <CPPlotDataSource>{
	CPXYGraph *graph;
	NSMutableArray *dataForPlot;
}
@property(readwrite, retain, nonatomic) NSMutableArray *dataForPlot;

@end
