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
#import "iPadHelper.h"
#import "WindMobileHelper.h"

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
@synthesize stationInfo;
@synthesize stationGraphData;
@synthesize duration;
@synthesize info;
@synthesize scale;
@synthesize masterController;

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self setupButtons];
    self.info.hidden = NO;
    
    // Create graph from theme
    graph = [[CPXYGraph alloc] initWithFrame:CGRectZero];
	CPTheme *theme = [CPTheme themeNamed:kCPDarkGradientTheme];
    [graph applyTheme:theme];
    self.hostingView.collapsesLayers = NO; // Collapsing layers may improve performance in some cases
    self.hostingView.hostedGraph = graph;
	
    graph.paddingLeft = 0.0;
    graph.paddingTop = 0.0;
    graph.paddingRight = 0.0;
    graph.paddingBottom = 0.0;
    
    // Add a bottom and right margin to have enough space to draw the axis
    graph.plotAreaFrame.paddingBottom = 30;
    graph.plotAreaFrame.paddingRight = 40;
    
    // Setup plot space
    CPXYPlotSpace *plotSpace = (CPXYPlotSpace *)graph.defaultPlotSpace;
	plotSpace.allowsUserInteraction = NO;
    axisSet = [(CPXYAxisSet *)(graph.axisSet) retain];
    // Put axis layer to front
    //axisSet.zPosition = CPDefaultZPositionPlotGroup + 1;
    
    axisSet.xAxis.isFloatingAxis = NO;
    
    axisSet.yAxis.isFloatingAxis = NO;
    axisSet.yAxis.tickDirection = CPSignPositive;
    axisSet.yAxis.majorIntervalLength = CPDecimalFromString(@"10");
    NSNumberFormatter *windFormatter = [[NSNumberFormatter alloc]init];
    [windFormatter setNumberStyle:NSNumberFormatterDecimalStyle];
    axisSet.yAxis.labelFormatter = windFormatter;
    [windFormatter release];
    CPMutableLineStyle *gridLineStyle = [CPMutableLineStyle lineStyle];
    gridLineStyle.lineWidth = 1;
    gridLineStyle.lineColor = [CPColor grayColor];
    axisSet.yAxis.majorGridLineStyle = gridLineStyle;
    axisSet.yAxis.minorTickLineStyle = nil;
    NSString *unit = NSLocalizedStringFromTable(@"WIND_FORMAT", @"WindMobile", nil);
    axisSet.yAxis.title = [NSString stringWithFormat:unit, NSLocalizedStringFromTable(@"CHART_YAXIS_TITLE", @"WindMobile", nil)];
    axisSet.yAxis.titleLocation = CPDecimalFromInteger(0);
    CPMutableTextStyle *textStyle = [[CPMutableTextStyle alloc] init];
    textStyle.color = [CPColor lightGrayColor];
    textStyle.fontSize = 11;
    axisSet.yAxis.titleOffset = 35;
    axisSet.yAxis.titleTextStyle = textStyle;
    [textStyle release];
	
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
	[masterController release];
	
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
	[client asyncGetStationGraphData:self.stationInfo.stationID duration:self.duration forSender:self];
}

#pragma mark -
#pragma mark WMReSTClientDelegate

- (void)stationGraphData:(StationGraphData*)data {
    [self performSelectorOnMainThread:@selector(setupChart:) withObject:data waitUntilDone:true];
}

- (void)setupChart:(StationGraphData*)data {
	self.stationGraphData = data;
    
    [self stopRefreshAnimation];
    
    if (([self.stationGraphData.windAverage count] > 0) && ([self.stationGraphData.windMax count] > 0)) {
        CPXYPlotSpace *plotSpace = (CPXYPlotSpace *)graph.defaultPlotSpace;
        
        // Calculate graph range
        [graph reloadData];
        [plotSpace scaleToFitPlots:[graph allPlots]];
        CPPlotRange *xRange = plotSpace.xRange;
        CPPlotRange *yRange = plotSpace.yRange;
        
        double maxValue = [yRange locationDouble] + [yRange lengthDouble];
        // 10 km/h minumum
        if (maxValue < 10) {
            maxValue = 10;
        }
        
        double viewHeight = self.hostingView.bounds.size.height;
        double scaleFactor = maxValue / viewHeight;
        
        // Added space to display wind direction labels : ~30 pixels
        maxValue += 30 * scaleFactor;;
        
        // Update yRange
        yRange = [CPPlotRange plotRangeWithLocation:CPDecimalFromDouble(0) length:CPDecimalFromDouble(maxValue)];
        
        // Put the y axis on the left of the view
        axisSet.yAxis.orthogonalCoordinateDecimal = CPDecimalFromDouble(xRange.locationDouble + xRange.lengthDouble);
        
        // Setup the "zoomed" range
        plotSpace.xRange = xRange;
        plotSpace.yRange = yRange;
        
        // Setup the global range
        /*
         plotSpace.globalXRange = xRange;
         plotSpace.globalYRange = yRange;   
         */
        
        // X interval customization
        switch (self.scale.selectedSegmentIndex) {
            case INTERVAL_4_HOURS:
                axisSet.xAxis.majorIntervalLength = CPDecimalFromInteger(3600); // 1h
                axisSet.xAxis.minorTicksPerInterval = 1; // 30 min
                break;
            case INTERVAL_6_HOURS:
                axisSet.xAxis.majorIntervalLength = CPDecimalFromInteger(7200); // 2h
                axisSet.xAxis.minorTicksPerInterval = 3; // 30 min
                break;
            case INTERVAL_12_HOURS:
                axisSet.xAxis.majorIntervalLength = CPDecimalFromInteger(14400); // 4h
                axisSet.xAxis.minorTicksPerInterval = 3; // 1 h
                break;
            case INTERVAL_24_HOURS:
                axisSet.xAxis.majorIntervalLength = CPDecimalFromInteger(28800); // 8h
                axisSet.xAxis.minorTicksPerInterval = 7; // 1 h
                break;
            case INTERVAL_2_DAYS:
                axisSet.xAxis.majorIntervalLength = CPDecimalFromInteger(36000); // 10h
                axisSet.xAxis.minorTicksPerInterval = 9; // 1 h
                break;
            default:
                axisSet.xAxis.majorIntervalLength = CPDecimalFromInteger(14400); // 4h
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
            newLabel.tickLocation = CPDecimalFromDouble(location);
            newLabel.offset = axisSet.xAxis.labelOffset + axisSet.xAxis.majorTickLength;
            [customLabels addObject:newLabel];
            [newLabel release];
        }
        [dateFormatter release];
        
        axisSet.xAxis.axisLabels =  [NSSet setWithArray:customLabels];
        [customLabels release]; 
    }
}

- (void)serverError:(NSString *)title message:(NSString *)message{
	[self stopRefreshAnimation];
    [WMReSTClient showError:title message:message];
}

- (void)connectionError:(NSString *)title message:(NSString *)message{
	[self stopRefreshAnimation];
    [WMReSTClient showError:title message:message];
}

- (void)startRefreshAnimation {
    if([iPadHelper isIpad]){
        // Remove refresh button
        self.navigationItem.rightBarButtonItem = nil;
        
        // Start animation
        UIActivityIndicatorView *activityIndicator = [[UIActivityIndicatorView alloc] initWithFrame:CGRectMake(0, 0, 20, 20)];
        [activityIndicator startAnimating];
        UIBarButtonItem *activityItem = [[UIBarButtonItem alloc] initWithCustomView:activityIndicator];
        [activityIndicator release];
        self.navigationItem.rightBarButtonItem = activityItem;
        [activityItem release];
    } else { // iPhone
        [self.masterController startRefreshAnimation];
    }    
    
	self.info.hidden = YES;
    self.scale.hidden = YES;
}

- (void)stopRefreshAnimation{
	if([iPadHelper isIpad]){
        // Stop animation
        self.navigationItem.rightBarButtonItem = nil;
        
        UIBarButtonItem *refreshItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemRefresh
                                                                                     target:self 
                                                                                     action:@selector(refreshContent:)];
        self.navigationItem.rightBarButtonItem = refreshItem;
        [refreshItem release];
	} else { // iPhone
        [self.masterController stopRefreshAnimation];
	}
    
    [self showInfo:self];
}

#pragma mark -
#pragma mark CPPlotDataSource

- (NSUInteger)numberOfRecordsForPlot:(CPPlot *)plot {
	if(self.stationGraphData == nil){
		return 0;
	}
    
    if ([(NSString *)plot.identifier isEqualToString:PLOT_WIND_AVERAGE_IDENTIFIER]) {
        // Wind average
        return [self.stationGraphData.windAverage dataPointCount];
	} else if ([(NSString *)plot.identifier isEqualToString:PLOT_WIND_MAX_IDENTIFIER]) { 
        // Wind max
        return [self.stationGraphData.windMax dataPointCount];
	}
    
    return 0;
}

- (NSNumber *)numberForPlot:(CPPlot *)plot field:(NSUInteger)fieldEnum recordIndex:(NSUInteger)index {
	if ([(NSString *)plot.identifier isEqualToString:PLOT_WIND_AVERAGE_IDENTIFIER]) {
        // Wind average
		if (fieldEnum == CPScatterPlotFieldX) {
			return [NSNumber numberWithDouble:[self.stationGraphData.windAverage timeIntervalForPointAtIndex:index]];
		} else if(fieldEnum == CPScatterPlotFieldY){
			return [self.stationGraphData.windAverage valueForPointAtIndex:index];
		}
	} else if ([(NSString *)plot.identifier isEqualToString:PLOT_WIND_MAX_IDENTIFIER]) { 
        // Wind max
		if (fieldEnum == CPScatterPlotFieldX) {
			return [NSNumber numberWithDouble:[self.stationGraphData.windMax timeIntervalForPointAtIndex:index]];
		} else if(fieldEnum == CPScatterPlotFieldY){
			return [self.stationGraphData.windMax valueForPointAtIndex:index];
		}
	}
    
    return [NSNumber numberWithDouble:0.0];
}

- (CPLayer *)dataLabelForIndex:(NSUInteger)index {
    double direction = [[self.stationGraphData.windDirection valueForPointAtIndex:index] doubleValue];
    NSString *directionText = [WindMobileHelper windDirectionLabel:direction];
    CPTextLayer *label = [[CPTextLayer alloc] initWithText:directionText];
    CPMutableTextStyle *textStyle = [[CPMutableTextStyle alloc] init];
    textStyle.color = [CPColor lightGrayColor];
    label.textStyle = textStyle;
    [textStyle release];
    return [label autorelease];
}

- (CPLayer *)dataLabelForPlot:(CPPlot *)plot recordIndex:(NSUInteger)index {
    if ([(NSString *)plot.identifier isEqualToString:PLOT_WIND_MAX_IDENTIFIER]) {
        static int maxNumberOfLabels = 50;
        
        double *values = nil;
        @try {
            int length = [self numberOfRecordsForPlot:plot];
            // Round to the near odd number
            int peakVectorSize = (int) round((double)length / maxNumberOfLabels * 2) * 2 - 1;
            peakVectorSize = MAX(peakVectorSize, 3);
            values = malloc(peakVectorSize * sizeof(double));
            
            int margin = (peakVectorSize / 2);
            int startIndex = index - margin;
            int stopIndex = index + margin;
            if ((startIndex >= 0) && (stopIndex < length)) {
                for (int i = startIndex; i <= stopIndex; i++) {
                    double value = [[self numberForPlot:plot field:CPScatterPlotFieldY recordIndex:i] doubleValue];
                    values[i-startIndex] = value;
                }
                if ([WindMobileHelper isPeak:values size:peakVectorSize]) {
                    return [self dataLabelForIndex:index];
                }
            }
        }
        @finally {
            if (values != nil) {
                free(values);
            }
        }
    }
    return nil;
}

#pragma mark -
#pragma mark Buttons

- (IBAction)setInterval:(id)sender {
	// new duration
	NSString* newDuration;
	switch (self.scale.selectedSegmentIndex) {
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
    
    [self showInfo:self];
	
	// apply new duration
	if([newDuration compare:self.duration] !=  NSOrderedSame){
		self.duration = newDuration;
		[self refreshContent:sender];
	}
}

- (IBAction)showInfo:(id)sender {
	self.scale.hidden = YES;
	self.info.hidden = NO;
}

- (IBAction)showScale:(id)sender {
	self.info.hidden = YES;
	self.scale.hidden = NO;
}

- (void)setupButtons {
	for (int i=0; i < self.scale.numberOfSegments; i++) {
        NSString *value = [NSString stringWithFormat:DURATION_FORMAT, i];
		[self.scale setTitle:NSLocalizedStringFromTable(value, @"WindMobile", nil) forSegmentAtIndex:i];
	}
}

@end
