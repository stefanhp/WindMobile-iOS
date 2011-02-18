//
//  WindTrendChartViewController.m
//  WindMobile
//
//  Created by Stefan Hochuli Paychère on 15.02.11.
//  Copyright 2011 Pistache Software. All rights reserved.
//

#import "WindTrendChartViewController.h"
#import "math.h"

#define TREND_CHART_PADDING 20.0 
#define DegreeToRadian(x) ((x) * M_PI / 180.0f)

@implementation WindTrendChartView

-(void)drawRect:(CGRect)rect
{
	CGContextRef context = UIGraphicsGetCurrentContext();
	CGFloat width = rect.size.width;
	if(rect.size.height < rect.size.width){
		width = rect.size.height;
	}

	// Circle
	CGContextSetRGBStrokeColor(context, 1.0, 1.0, 1.0, 1.0); // white
	CGContextAddEllipseInRect(context, CGRectMake(TREND_CHART_PADDING, TREND_CHART_PADDING, 
												  width -(2*TREND_CHART_PADDING),
												  width -(2*TREND_CHART_PADDING)));
	CGContextStrokePath(context);
	
	// Lines
	if (self.windData != nil && self.windData.dataPoints != nil && [self.windData.dataPoints count]>0) {
		CGContextSetCMYKStrokeColor(context, 0.0, 0.0, 0.67, 0.0, 1.0); // yellow
		CGContextSetLineWidth(context, 2.0);

		double radius = 0.0;
		double lineRadius = width/2 -(2*TREND_CHART_PADDING);
		
		CGContextMoveToPoint(context, width/2, width/2);

		for (DataPoint* point in self.windData.dataPoints) {
			CGFloat direction = [point.value floatValue];
			radius = radius + lineRadius / [self.windData.dataPoints count];
			
			double pointOffsetX = TREND_CHART_PADDING + (width - 2.0 * radius) / 2.0;
            double pointOffsetY = TREND_CHART_PADDING + (width - 2.0 * radius) / 2.0;
			
            double circleX = cos(DegreeToRadian(direction)) * radius;
            double circleY = sin(DegreeToRadian(direction)) * radius;
			
            CGFloat x = (CGFloat) (pointOffsetX + radius - circleX);
            CGFloat y = (CGFloat) (pointOffsetY + radius - circleY);
			
            CGContextAddLineToPoint(context, x, y);
		}
		CGContextStrokePath(context);
	}
}
@synthesize windData;
@end
	
@implementation WindTrendChartViewController
@dynamic windData;
- (GraphData*) windData{
	return windData;
}

- (void)setWindData:(GraphData*)newData{
	if(windData != newData){
		[windData release];
		windData = [newData retain];
		if(self.view != nil && [self.view isKindOfClass:[WindTrendChartView class]] && windData != nil){
			WindTrendChartView* myView = (WindTrendChartView*)self.view;
			myView.windData = windData;
			[self.view setNeedsDisplay];
		}
	}
}

// The designated initializer.  Override if you create the controller programmatically and want to perform customization that is not appropriate for viewDidLoad.
/*
- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization.
    }
    return self;
}
*/

// Implement viewDidLoad to do additional setup after loading the view, typically from a nib.
- (void)viewDidLoad {
    [super viewDidLoad];
	if(self.view != nil && [self.view isKindOfClass:[WindTrendChartView class]] && self.windData != nil){
		WindTrendChartView* myView = (WindTrendChartView*)self.view;
		myView.windData = self.windData;
	}		
}

/*
// Override to allow orientations other than the default portrait orientation.
- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
    // Return YES for supported orientations.
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}
*/

- (void)didReceiveMemoryWarning {
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Release any cached data, images, etc. that aren't in use.
}

- (void)viewDidUnload {
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}


- (void)dealloc {
    [super dealloc];
}


@end
