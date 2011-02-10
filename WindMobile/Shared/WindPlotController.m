//
//  WindPlotController.m
//  WindMobile
//
//  Created by Stefan Hochuli Paychère on 29.01.11.
//  Copyright 2011 Pistache Software. All rights reserved.
//

#import "WindPlotController.h"
#import "CPGraphHostingView.h"
#import "WMCellGraphTheme.h"

#define PLOT_WIND_AVERAGE_IDENTIFIER @"Wind Average"
#define PLOT_WIND_MAX_IDENTIFIER @"Wind Max"
#define PLOT_WIND_ORANGE_IDENTIFIER @"WARNING"
#define PLOT_WIND_RED_IDENTIFIER @"DANGER"

#define DEFAULT_DURATION @"14400"
#define DURATION_FORMAT @"DURATION%i"

#define ORANGE_LIMIT 15.0
#define RED_LIMIT 35.0

#define INTERVAL_4_HOURS 0
#define INTERVAL_6_HOURS 1
#define INTERVAL_12_HOURS 2
#define INTERVAL_24_HOURS 3
#define INTERVAL_2_DAYS 4
#define INTERVAL_3_DAYS 5

@implementation WindPlotController

@synthesize hostingView;
@synthesize scale;
@synthesize info;
@synthesize stationInfo;
@synthesize stationGraph;
@synthesize drawAxisSet;
@synthesize isInCell;


//@synthesize dataForPlot;

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
	
	if(self.isInCell == NO){
		[self setupButtons];
		info.hidden = NO;
	}
	
	// Load data points
	self.duration = DEFAULT_DURATION; 
	[self refreshContent:self];

	
    // Create graph from theme
    graph = [[CPXYGraph alloc] initWithFrame:CGRectZero];
	CPTheme *theme;
	if(self.isInCell){
		theme = [[WMCellGraphTheme alloc]init];
		graph.fill = [CPFill fillWithColor:[CPColor whiteColor]];
	} else {
		theme = [CPTheme themeNamed:kCPDarkGradientTheme];
	}
    [graph applyTheme:theme];
    hostingView.collapsesLayers = NO; // Setting to YES reduces GPU memory usage, but can slow drawing/scrolling
    hostingView.hostedGraph = graph;
	
	if(self.isInCell){
		graph.paddingLeft = 0.0;
		graph.paddingTop = 2.0;
		graph.paddingRight = 0.0;
		graph.paddingBottom = 2.0;
	} else {
		graph.paddingLeft = 0.0;
		graph.paddingTop = 0.0;
		graph.paddingRight = 0.0;
		graph.paddingBottom = 0.0;
	}

    
    // Setup plot space
    CPXYPlotSpace *plotSpace = (CPXYPlotSpace *)graph.defaultPlotSpace;
    //plotSpace.allowsUserInteraction = !self.isInCell;
	plotSpace.allowsUserInteraction = NO;
	NSTimeInterval max = [[NSDate date]timeIntervalSince1970];
	NSTimeInterval min = [[[NSDate date] dateByAddingTimeInterval:-21600.0]timeIntervalSince1970]; // 6h back = 60 * 60 * 6 = 21'600
	NSTimeInterval length = max - min;
    plotSpace.xRange = [CPPlotRange plotRangeWithLocation:CPDecimalFromDouble(min) length:CPDecimalFromDouble(length)];
    plotSpace.yRange = [CPPlotRange plotRangeWithLocation:CPDecimalFromFloat(-5.0) length:CPDecimalFromFloat(25.0)];
	
    // Axes
	axisSet = [(CPXYAxisSet *)(graph.axisSet) retain];
    CPXYAxis *x = axisSet.xAxis;
	x.majorIntervalLength = CPDecimalFromDouble(7200.0); // 2h
	x.minorTicksPerInterval = 6; // 15 min
	x.labelingPolicy = CPAxisLabelingPolicyNone;
	x.isFloatingAxis = NO,
    x.orthogonalCoordinateDecimal = CPDecimalFromString(@"0");
	/*
 	NSArray *exclusionRanges = [NSArray arrayWithObjects:
								[CPPlotRange plotRangeWithLocation:CPDecimalFromDouble(min) length:CPDecimalFromDouble(max)], 
								nil];
	x.labelExclusionRanges = exclusionRanges;
	 */
	
    CPXYAxis *y = axisSet.yAxis;
    y.majorIntervalLength = CPDecimalFromString(@"10");
    y.minorTicksPerInterval = 10;
	y.isFloatingAxis = NO;
    y.orthogonalCoordinateDecimal = CPDecimalFromDouble(max);
	/*
	exclusionRanges = [NSArray arrayWithObjects:
					   [CPPlotRange plotRangeWithLocation:CPDecimalFromFloat(0.0) length:CPDecimalFromFloat(50.0)], 
					   nil];
	y.labelExclusionRanges = exclusionRanges;
	 */
	
	// Create a Wind Average plot area
	CPScatterPlot *averageLinePlot = [[[CPScatterPlot alloc] init] autorelease];
    averageLinePlot.identifier = PLOT_WIND_AVERAGE_IDENTIFIER;
    averageLinePlot.dataSource = self;

    CPMutableLineStyle *lineStyle = [CPMutableLineStyle lineStyle];
	if(self.isInCell){
		lineStyle.lineWidth = 1.0f;
	} else {
		lineStyle.miterLimit = 1.0f;
		lineStyle.lineWidth = 3.0f;
	}

	lineStyle.lineColor = [CPColor blueColor];
    averageLinePlot.dataLineStyle = lineStyle;

	// Do a blue gradient
	CPColor *areaColor1 = [CPColor colorWithComponentRed:0.0 green:0.0 blue:1.0 alpha:0.8];
	if (self.isInCell) {
		CPFill *areaColorFill = [CPFill fillWithColor:areaColor1];
		averageLinePlot.areaFill = areaColorFill;
	} else {
		CPGradient *areaGradient1 = [CPGradient gradientWithBeginningColor:areaColor1 endingColor:[CPColor clearColor]];
		areaGradient1.angle = -90.0f;
		CPFill *areaGradientFill = [CPFill fillWithGradient:areaGradient1];
		averageLinePlot.areaFill = areaGradientFill;
	}

    averageLinePlot.areaBaseValue = [[NSDecimalNumber zero] decimalValue];    
    //averageLinePlot.areaBaseValue = CPDecimalFromString(@"10.0");    
	
	// Add plot symbols
	/*
	CPMutableLineStyle *symbolLineStyle = [CPMutableLineStyle lineStyle];
	symbolLineStyle.lineColor = [CPColor blackColor];
	CPPlotSymbol *plotSymbol = [CPPlotSymbol ellipsePlotSymbol];
	plotSymbol.fill = [CPFill fillWithColor:[CPColor blueColor]];
	plotSymbol.lineStyle = symbolLineStyle;
    plotSymbol.size = CGSizeMake(10.0, 10.0);
    averageLinePlot.plotSymbol = plotSymbol;
	 */

	[graph addPlot:averageLinePlot];
	
    // Create a Wind Max plot area
	CPScatterPlot *maxLinePlot = [[[CPScatterPlot alloc] init] autorelease];
    maxLinePlot.identifier = PLOT_WIND_MAX_IDENTIFIER;
    maxLinePlot.dataSource = self;

    lineStyle = [CPMutableLineStyle lineStyle];
    lineStyle.lineWidth = 1.0f;
    lineStyle.lineColor = [CPColor redColor];
	//lineStyle.dashPattern = [NSArray arrayWithObjects:[NSNumber numberWithFloat:5.0f], [NSNumber numberWithFloat:5.0f], nil];
    maxLinePlot.dataLineStyle = lineStyle;
	
	
    [graph addPlot:maxLinePlot];
	
	// additional plots
	if(!self.isInCell){
		// Danger
		CPScatterPlot *dangerLinePlot = [[[CPScatterPlot alloc] init] autorelease];
		dangerLinePlot.identifier = PLOT_WIND_RED_IDENTIFIER;
		dangerLinePlot.dataSource = self;
		
		lineStyle = [CPMutableLineStyle lineStyle];
		lineStyle.lineWidth = 0.5f;
		lineStyle.lineColor = [CPColor redColor];
		dangerLinePlot.dataLineStyle = lineStyle;
		
		CPColor *areaColorRed = [CPColor colorWithComponentRed:1.0 green:0.0 blue:0.0 alpha:0.2];
		CPFill *areaColorFillRed = [CPFill fillWithColor:areaColorRed];
		dangerLinePlot.areaFill = areaColorFillRed;
		dangerLinePlot.areaBaseValue = CPDecimalFromDouble(RED_LIMIT+10.0);    

		[graph addPlot:dangerLinePlot];
		
		// Warning
		CPScatterPlot *warningLinePlot = [[[CPScatterPlot alloc] init] autorelease];
		warningLinePlot.identifier = PLOT_WIND_ORANGE_IDENTIFIER;
		warningLinePlot.dataSource = self;
		
		lineStyle = [CPMutableLineStyle lineStyle];
		lineStyle.lineWidth = 0.5f;
		lineStyle.lineColor = [CPColor orangeColor];
		warningLinePlot.dataLineStyle = lineStyle;
		
		CPColor *areaColorOrange = [CPColor colorWithComponentRed:1.0 green:0.5 blue:0.0 alpha:0.2];
		CPFill *areaColorFillOrange = [CPFill fillWithColor:areaColorOrange];
		warningLinePlot.areaFill = areaColorFillOrange;
		warningLinePlot.areaBaseValue = CPDecimalFromDouble(RED_LIMIT);    

		[graph addPlot:warningLinePlot];
		
	}


	if(!drawAxisSet){
		graph.axisSet = nil;
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
	[stationInfo release];
	[stationGraph release];
	[axisSet release];

    [super dealloc];
}

-(BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation
{
	return YES;
}

#pragma mark -
#pragma mark Rest Graph Data

- (void)refreshContent:(id)sender{
	[self startRefreshAnimation];
	if(client == nil){
		client = [[[WMReSTClient alloc] init ]retain];
	}
	[client asyncGetStationGraph:stationInfo.stationID duration:self.duration forSender:self];
}

- (void)requestError:(NSString*) message details:(NSMutableDictionary *)error{
	[self stopRefreshAnimation];
}

- (void)stationGraph:(StationGraph*)graphs{
	self.stationGraph = graphs;
	
	// Adjust graph range
	CPXYPlotSpace *plotSpace = (CPXYPlotSpace *)graph.defaultPlotSpace;
	CPPlotRange *xRange = self.stationGraph.windMaxDateRange;
    plotSpace.xRange = xRange;
    plotSpace.yRange = self.stationGraph.windMaxValueRange;
	
	// move axis and update labels
	if(drawAxisSet){
		graph.axisSet = axisSet; // re-appy axis
		axisSet.yAxis.orthogonalCoordinateDecimal = CPDecimalFromDouble(xRange.locationDouble + xRange.lengthDouble - xRange.lengthDouble/50);

		// labeling range
		CPXYAxis *x = axisSet.xAxis;
		switch (scale.selectedSegmentIndex) {
			case INTERVAL_4_HOURS:
				x.majorIntervalLength = CPDecimalFromDouble(3600.0); // 1h
				x.minorTicksPerInterval = 3; // 15 min
				break;
			case INTERVAL_6_HOURS:
				x.majorIntervalLength = CPDecimalFromDouble(7200.0); // 2h
				x.minorTicksPerInterval = 6; // 15 min
				break;
			case INTERVAL_12_HOURS:
				x.majorIntervalLength = CPDecimalFromDouble(10800); // 3h
				x.minorTicksPerInterval = 9; // 15 min
				break;
			case INTERVAL_24_HOURS:
				x.majorIntervalLength = CPDecimalFromDouble(43200); // 12h
				x.minorTicksPerInterval = 11; // 1 h
				break;
			case INTERVAL_2_DAYS:
				x.majorIntervalLength = CPDecimalFromDouble(86400); // 24h
				x.minorTicksPerInterval = 23; // 1 h
				break;
			case INTERVAL_3_DAYS:
				x.majorIntervalLength = CPDecimalFromDouble(86400); // 24h
				x.minorTicksPerInterval = 23; // 1 h
				break;
			default:
				x.majorIntervalLength = CPDecimalFromDouble(7200.0);
				x.preferredNumberOfMajorTicks = 6;
				x.minorTicksPerInterval = 0;
				break;
		}
		x.labelingPolicy = CPAxisLabelingPolicyFixedInterval;
		[x relabel];
		
		// labels
		NSSet* labelCoordinates = x.majorTickLocations;
		x.labelingPolicy = CPAxisLabelingPolicyNone;
		NSMutableArray *customLabels = [[NSMutableArray alloc] initWithCapacity:[labelCoordinates count]];
		
		unsigned unitFlags = NSDayCalendarUnit;
		NSDate *startDate = [NSDate dateWithTimeIntervalSince1970:xRange.locationDouble];
		NSDate *endDate = [NSDate dateWithTimeIntervalSince1970:(xRange.locationDouble + xRange.lengthDouble)];
		NSDateComponents *startComps = [[NSCalendar currentCalendar] components:unitFlags fromDate:startDate];
		NSDateComponents *endComps = [[NSCalendar currentCalendar] components:unitFlags fromDate:endDate];
		BOOL showDate = [startComps day] != [endComps day];
		
		for (NSNumber* tickLocation in labelCoordinates){
			NSTimeInterval location = [tickLocation doubleValue];
			NSDate* date = [NSDate dateWithTimeIntervalSince1970:location];
			
			NSString* dateLabel;
			if(showDate){ // range crosses day boundary
				dateLabel = [NSDateFormatter localizedStringFromDate:date 
														   dateStyle:kCFDateFormatterShortStyle
														   timeStyle:kCFDateFormatterShortStyle];
			} else {
				dateLabel = [NSDateFormatter localizedStringFromDate:date 
														   dateStyle:kCFDateFormatterNoStyle
														   timeStyle:kCFDateFormatterShortStyle];
			}

			
			CPAxisLabel *newLabel = [[CPAxisLabel alloc] initWithText:dateLabel textStyle:x.labelTextStyle];
			newLabel.tickLocation = CPDecimalFromDouble(location);
			newLabel.offset = x.labelOffset + x.majorTickLength;
			[customLabels addObject:newLabel];
			[newLabel release];
		}
		x.axisLabels =  [NSSet setWithArray:customLabels];
	} else {
		graph.axisSet = nil;
	}

	[self stopRefreshAnimation];
	
	[graph reloadData];
}

- (void)startRefreshAnimation{
	// Remove refresh button
	self.navigationItem.rightBarButtonItem = nil;
	
	// activity indicator
	UIActivityIndicatorView *activityIndicator = [[UIActivityIndicatorView alloc] initWithFrame:CGRectMake(0, 0, 20, 20)];
	[activityIndicator startAnimating];
	UIBarButtonItem *activityItem = [[UIBarButtonItem alloc] initWithCustomView:activityIndicator];
	[activityIndicator release];
	self.navigationItem.rightBarButtonItem = activityItem;
}

- (void)stopRefreshAnimation{
	// Stop animation
	self.navigationItem.rightBarButtonItem = nil;
	
	// Put Refresh button on the top left
	//if([iPadHelper isIpad]){} else {
	UIBarButtonItem *refreshItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemRefresh
																				 target:self 
																				 action:@selector(refreshContent:)];
	self.navigationItem.rightBarButtonItem = refreshItem;
	//}
}

#pragma mark -
#pragma mark Plot Data Source Methods

-(NSUInteger)numberOfRecordsForPlot:(CPPlot *)plot {
	if(stationGraph == nil){
		return 0;
	}
    return [[stationGraph windAveragePoints] count];
}

-(NSNumber *)numberForPlot:(CPPlot *)plot field:(NSUInteger)fieldEnum recordIndex:(NSUInteger)index {
	// Wind Average
	DataPoint* point = (DataPoint*)[[stationGraph windAveragePoints] objectAtIndex:index];
	if ([(NSString *)plot.identifier isEqualToString:PLOT_WIND_AVERAGE_IDENTIFIER]){
		if (fieldEnum == CPScatterPlotFieldX) {
			return [NSNumber numberWithDouble:[[point date] timeIntervalSince1970]];
		} else if(fieldEnum == CPScatterPlotFieldY){
			return [point value];
		}
	} else if ([(NSString *)plot.identifier isEqualToString:PLOT_WIND_MAX_IDENTIFIER]) { // Wind Max
		point = (DataPoint*)[[stationGraph windMaxPoints] objectAtIndex:index];
		if (fieldEnum == CPScatterPlotFieldX) {
			return [NSNumber numberWithDouble:[[point date] timeIntervalSince1970]];
		} else if(fieldEnum == CPScatterPlotFieldY){
			return [point value];
		}
	} else if([(NSString *)plot.identifier isEqualToString:PLOT_WIND_RED_IDENTIFIER]){
		if (fieldEnum == CPScatterPlotFieldX) {
			return [NSNumber numberWithDouble:[[point date] timeIntervalSince1970]];
		} else if(fieldEnum == CPScatterPlotFieldY){
			return [NSNumber numberWithDouble:RED_LIMIT];
		}
	} else if([(NSString *)plot.identifier isEqualToString:PLOT_WIND_ORANGE_IDENTIFIER]){
		if (fieldEnum == CPScatterPlotFieldX) {
			return [NSNumber numberWithDouble:[[point date] timeIntervalSince1970]];
		} else if(fieldEnum == CPScatterPlotFieldY){
			return [NSNumber numberWithDouble:ORANGE_LIMIT];
		}
	}
    return [NSNumber numberWithDouble:0.0];
}

#pragma mark -
#pragma mark Buttons
@synthesize duration;

- (IBAction)setInterval:(id)sender{
	// new duration
	NSString* newDuration;
	switch (scale.selectedSegmentIndex) {
		case INTERVAL_4_HOURS:
			newDuration = @"14400"; // 4h = 60 * 60 * 4 seconds
			break;
		case INTERVAL_6_HOURS:
			newDuration = @"21600"; // 6h = 60 * 60 * 6 seconds
			break;
		case INTERVAL_12_HOURS:
			newDuration = @"43200"; // 12h = 60 * 60 * 12 seconds
			break;
		case INTERVAL_24_HOURS:
			newDuration = @"86400"; // 1d = 24h = 60 * 60 * 24 seconds
			break;
		case INTERVAL_2_DAYS:
			newDuration = @"172800"; // 2d = 48h = 60 * 60 * 48 seconds
			break;
		case INTERVAL_3_DAYS:
			newDuration = @"259200"; // 3d = 48h = 60 * 60 * 48 seconds
			break;
		default:
			newDuration = DEFAULT_DURATION;
			break;
	}
	
	// Swap buttons
	scale.hidden = YES;
	info.hidden = NO;
	
	// apply new duration
	if([newDuration compare:self.duration] !=  NSOrderedSame){
		self.duration = newDuration;
		[self refreshContent:sender];
	}
}

- (IBAction)showScale:(id)sender{
	info.hidden = YES;
	scale.hidden = NO;
}


- (void)setupButtons{
	NSString *value;
	for (int i=0; i<scale.numberOfSegments; i++) {
		value = [NSString stringWithFormat:DURATION_FORMAT, i];
		[scale setTitle:NSLocalizedStringFromTable(value, @"WindMobile", nil) forSegmentAtIndex:i];
	}
	
}

@end
