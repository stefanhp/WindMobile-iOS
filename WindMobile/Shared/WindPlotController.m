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

#define DEFAULT_DURATION @"14400"
#define DURATION_FORMAT @"DURATION%i"

#define INTERVAL_4_HOURS 0
#define INTERVAL_6_HOURS 1
#define INTERVAL_12_HOURS 2
#define INTERVAL_24_HOURS 3
#define INTERVAL_2_DAYS 4

@implementation WindPlotController

@synthesize hostingView;
@synthesize scale;
@synthesize info;
@synthesize stationInfo;
@synthesize stationGraphData;
@synthesize activityIndicator;

- (void)viewDidLoad {
    [super viewDidLoad];
	
    [self setupButtons];
    info.hidden = NO;
    
    // Create graph from theme
    graph = [[CPXYGraph alloc] initWithFrame:CGRectZero];
	CPTheme *theme = [CPTheme themeNamed:kCPDarkGradientTheme];
    [graph applyTheme:theme];
    hostingView.collapsesLayers = NO; // Collapsing layers may improve performance in some cases
    hostingView.hostedGraph = graph;
	
    graph.paddingLeft = 0.0;
    graph.paddingTop = 0.0;
    graph.paddingRight = 0.0;
    graph.paddingBottom = 0.0;
    
    // Setup plot space
    CPXYPlotSpace *plotSpace = (CPXYPlotSpace *)graph.defaultPlotSpace;
	plotSpace.allowsUserInteraction = NO;
    axisSet = [(CPXYAxisSet *)(graph.axisSet) retain];
    // Put axis layer to front
    axisSet.zPosition = CPDefaultZPositionPlotGroup + 1;
    
    axisSet.xAxis.isFloatingAxis = NO;
    
    axisSet.yAxis.isFloatingAxis = NO;
    axisSet.yAxis.majorIntervalLength = CPDecimalFromString(@"10");
    axisSet.yAxis.minorTickLineStyle = nil;
	
	// Create a Wind Average plot area
	CPScatterPlot *averageLinePlot = [[[CPScatterPlot alloc] init] autorelease];
    averageLinePlot.identifier = PLOT_WIND_AVERAGE_IDENTIFIER;
    averageLinePlot.dataSource = self;

    CPMutableLineStyle *lineStyle = [CPMutableLineStyle lineStyle];
    lineStyle.miterLimit = 1.25f;
    lineStyle.lineWidth = 2.5f;
    
	lineStyle.lineColor = [CPColor colorWithComponentRed:0.65 green:0.66 blue:0.8 alpha:1.0];
    averageLinePlot.dataLineStyle = lineStyle;

	// White to blue gradient
	CPColor *gradientStart = [CPColor colorWithComponentRed:0.14 green:0.17 blue:0.8 alpha:1.0];
    CPColor *gradientEnd= [CPColor colorWithComponentRed:0.55 green:0.56 blue:0.8 alpha:1.0];
    CPGradient *areaGradient = [CPGradient gradientWithBeginningColor:gradientStart endingColor:gradientEnd];
    areaGradient.angle = 90.0f;
    CPFill *areaGradientFill = [CPFill fillWithGradient:areaGradient];
    averageLinePlot.areaFill = areaGradientFill;

    averageLinePlot.areaBaseValue = [[NSDecimalNumber zero] decimalValue];    

	[graph addPlot:averageLinePlot];
	
    // Create a Wind Max plot area
	CPScatterPlot *maxLinePlot = [[[CPScatterPlot alloc] init] autorelease];
    maxLinePlot.identifier = PLOT_WIND_MAX_IDENTIFIER;
    maxLinePlot.dataSource = self;

    lineStyle = [CPMutableLineStyle lineStyle];
    lineStyle.miterLimit = 1.25f;
    lineStyle.lineWidth = 2.5f;
    lineStyle.lineColor = [CPColor redColor];
    maxLinePlot.dataLineStyle = lineStyle;
	
    [graph addPlot:maxLinePlot];
	
    // Load data points
    self.duration = DEFAULT_DURATION; 
    [self refreshContent:self];
}

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
	[client release];
	[graph release];
	[hostingView release];
	[stationInfo release];
	[stationGraphData release];
	[axisSet release];
	[duration release];
	[scale release];
	[info release];
	
    [super dealloc];
}

-(BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation {
	return YES;
}

#pragma mark -
#pragma mark Rest Graph Data

- (void)refreshContent:(id)sender{
	[self startRefreshAnimation];
	if(client == nil){
		client = [[WMReSTClient alloc] init ];
	}
	[client asyncGetStationGraphData:stationInfo.stationID duration:self.duration forSender:self];
}

#pragma mark -
#pragma mark WMReSTClientDelegate

- (void)stationGraphData:(StationGraphData*)data{
	self.stationGraphData = data;
	CPXYPlotSpace *plotSpace = (CPXYPlotSpace *)graph.defaultPlotSpace;
    
    // Calculate graph range
    [graph reloadData];
    [plotSpace scaleToFitPlots:[graph allPlots]];
    CPPlotRange* xRange = plotSpace.xRange;
    CPPlotRange* yRange = plotSpace.yRange;
    
    double maxValue = [yRange locationDouble] + [yRange lengthDouble];
    double viewHeight = hostingView.bounds.size.height;
    double scaleFactor = maxValue / viewHeight;
    
    // Y scale : 10 km/h minumum
    if (maxValue < 10) {
        maxValue = 10;
    }
    
    // Add an upper margin : ~7 pixels
    maxValue += 7 * scaleFactor;
    
    // Add a lower margin to have enough space to draw the x axis
    double location = -40 * scaleFactor;
    
    // Update yRange
    yRange = [CPPlotRange plotRangeWithLocation:CPDecimalFromDouble(location) length:CPDecimalFromDouble(maxValue - location)];
    
    // Put the y axis on the left of the view
    axisSet.yAxis.orthogonalCoordinateDecimal = CPDecimalFromDouble(xRange.locationDouble + xRange.lengthDouble - xRange.lengthDouble/50);
    axisSet.yAxis.visibleRange = [CPPlotRange plotRangeWithLocation:CPDecimalFromDouble(0) length:CPDecimalFromDouble(maxValue)];
    
    // Setup the "zoomed" range
    plotSpace.xRange = xRange;
    plotSpace.yRange = yRange;
    
    // Setup the global range
    /*
    plotSpace.globalXRange = xRange;
    plotSpace.globalYRange = yRange;   
    */
    
    // X interval customization
    switch (scale.selectedSegmentIndex) {
        case INTERVAL_4_HOURS:
            axisSet.xAxis.majorIntervalLength = CPDecimalFromDouble(3600.0); // 1h
            axisSet.xAxis.minorTicksPerInterval = 1; // 30 min
            break;
        case INTERVAL_6_HOURS:
            axisSet.xAxis.majorIntervalLength = CPDecimalFromDouble(7200.0); // 2h
            axisSet.xAxis.minorTicksPerInterval = 3; // 30 min
            break;
        case INTERVAL_12_HOURS:
            axisSet.xAxis.majorIntervalLength = CPDecimalFromDouble(14400); // 4h
            axisSet.xAxis.minorTicksPerInterval = 3; // 1 h
            break;
        case INTERVAL_24_HOURS:
            axisSet.xAxis.majorIntervalLength = CPDecimalFromDouble(28800); // 8h
            axisSet.xAxis.minorTicksPerInterval = 7; // 1 h
            break;
        case INTERVAL_2_DAYS:
            axisSet.xAxis.majorIntervalLength = CPDecimalFromDouble(28800); // 8h
            axisSet.xAxis.minorTicksPerInterval = 7; // 1 h
            break;
        default:
            axisSet.xAxis.majorIntervalLength = CPDecimalFromDouble(14400); // 4h
            axisSet.xAxis.minorTicksPerInterval = 3; // 1 h
            break;
    }
    axisSet.xAxis.labelingPolicy = CPAxisLabelingPolicyFixedInterval;
    [axisSet.xAxis relabel];
    
    // X label customization
    NSSet* labelCoordinates = axisSet.xAxis.majorTickLocations;
    axisSet.xAxis.labelingPolicy = CPAxisLabelingPolicyNone;
    NSMutableArray *customLabels = [[NSMutableArray alloc] initWithCapacity:[labelCoordinates count]];
    
    NSDateFormatter* dateFormatter = [[NSDateFormatter alloc]init];
    [dateFormatter setDateFormat:@"EEE HH:mm"];
    
    for (NSNumber* tickLocation in labelCoordinates){
        NSTimeInterval location = [tickLocation doubleValue];
        NSDate* date = [NSDate dateWithTimeIntervalSince1970:location];
        
        NSString* dateLabel = [dateFormatter stringFromDate:date];
        
        CPAxisLabel *newLabel = [[CPAxisLabel alloc] initWithText:dateLabel textStyle:axisSet.xAxis.labelTextStyle];
        newLabel.alignment = CPAlignmentRight;
        newLabel.tickLocation = CPDecimalFromDouble(location);
        newLabel.offset = axisSet.xAxis.labelOffset + axisSet.xAxis.majorTickLength;
        [customLabels addObject:newLabel];
        [newLabel release];
    }
    [dateFormatter release];
    
    axisSet.xAxis.axisLabels =  [NSSet setWithArray:customLabels];
    [customLabels release];
    
	[self stopRefreshAnimation];
}

- (void)serverError:(NSString *)title message:(NSString *)message{
	[self stopRefreshAnimation];
    [WMReSTClient showError:title message:message];
}

- (void)connectionError:(NSString *)title message:(NSString *)message{
	[self stopRefreshAnimation];
    [WMReSTClient showError:title message:message];
}

- (void)startRefreshAnimation{
	// Remove refresh button
	self.navigationItem.rightBarButtonItem = nil;
	
	// activity indicator
	info.hidden = YES;
	[activityIndicator startAnimating];
}

- (void)stopRefreshAnimation{
	// Stop animation
	[activityIndicator stopAnimating];
	info.hidden = NO;
	
	// Put Refresh button on the top left
	UIBarButtonItem *refreshItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemRefresh
																				 target:self 
																				 action:@selector(refreshContent:)];
	self.navigationItem.rightBarButtonItem = refreshItem;
	[refreshItem release];
}

#pragma mark -
#pragma mark Plot Data Source Methods

- (NSUInteger)numberOfRecordsForPlot:(CPPlot *)plot {
	if(stationGraphData == nil){
		return 0;
	}
    return [stationGraphData.windAverage dataPointCount];
}

- (NSNumber *)numberForPlot:(CPPlot *)plot field:(NSUInteger)fieldEnum recordIndex:(NSUInteger)index {
	if ([(NSString *)plot.identifier isEqualToString:PLOT_WIND_AVERAGE_IDENTIFIER]) {
        // Wind Average
		if (fieldEnum == CPScatterPlotFieldX) {
			return [NSNumber numberWithDouble:[stationGraphData.windAverage timeIntervalForPointAtIndex:index]];
		} else if(fieldEnum == CPScatterPlotFieldY){
			return [stationGraphData.windAverage valueForPointAtIndex:index];
		}
	} else if ([(NSString *)plot.identifier isEqualToString:PLOT_WIND_MAX_IDENTIFIER]) { 
        // Wind Max
		if (fieldEnum == CPScatterPlotFieldX) {
			return [NSNumber numberWithDouble:[stationGraphData.windMax timeIntervalForPointAtIndex:index]];
		} else if(fieldEnum == CPScatterPlotFieldY){
			return [stationGraphData.windMax valueForPointAtIndex:index];
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
