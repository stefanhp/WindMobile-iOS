//
//  WindTrendChartViewController.h
//  WindMobile
//
//  Created by Stefan Hochuli Paychère on 15.02.11.
//  Copyright 2011 Pistache Software. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "GraphData.h"

@interface WindTrendChartView : UIView
{
	GraphData *windData;
}
@property (retain) GraphData *windData;
@end

@interface WindTrendChartViewController : UIViewController {
	GraphData *windData;
}
@property (retain) GraphData *windData;
@end
