//
//  GraphData.m
//  WindMobile
//
//  Created by Stefan Hochuli Paychère on 14.02.11.
//  Copyright 2011 Pistache Software. All rights reserved.
//

#import "GraphData.h"
#import "WindMobileHelper.h"
#import "CorePlot-CocoaTouch.h"

#define DATA_POINT_DATE_KEY @"date"
#define DATA_POINT_VALUE_KEY @"value"

#define STATION_GRAPH_NAME_KEY @"@name"
#define	STATION_GRAPH_POINTS_KEY @"points"

#define STATION_GRAPH_AVERAGE_KEY @"windAverage"
#define STATION_GRAPH_MAX_KEY @"windMax"
#define STATION_GRAPH_DIRECTION_KEY @"windDirection"

#define GRAPH_INITIAL_MAX_VALUE 25.0
#define GRAPH_PADDING_VALUE 5.0
#define GRAPH_PADDING_DATE 0

@implementation GraphData
@synthesize addPadding;
@synthesize graphData;
@synthesize duration;
@synthesize graphType;

- (id)initWithDictionary:(NSDictionary *)aDictionary  andDuration:(NSNumber*)aDuration{
	self = [super init];
	if(self != nil && aDictionary != nil && aDuration != nil){
		graphData = [aDictionary retain];
		duration = [aDuration retain];
		
		GraphPointType aType = GraphPointTypeAverage;
		NSString* name = [graphData objectForKey:STATION_GRAPH_NAME_KEY];
		if([name isEqualToString:STATION_GRAPH_MAX_KEY]){
			aType = GraphPointTypeMax;
		} else if ([name isEqualToString:STATION_GRAPH_DIRECTION_KEY]) {
			aType = GraphPointTypeDirection;
		}
		graphType = [[NSNumber numberWithUnsignedInteger:aType] retain];
	} else {
		return nil;
	}
	return self;
}

- (void)dealloc {
	[graphData release];
	[duration release];
	[graphType release];
	[super dealloc];
}

#pragma mark -
#pragma mark - NSDictionary composition

- (NSUInteger)count{
	return [graphData count];
}

- (id)objectForKey:(id)aKey{
	return [graphData objectForKey:aKey];
}

- (NSEnumerator *)keyEnumerator{
	return [graphData keyEnumerator];
}

- (NSString *)description{
	return [NSString stringWithFormat:@"GraphData %@", [graphData description]];
}

#pragma mark -
#pragma mark - GraphData properties
@dynamic name;
- (NSString*)name{
	return [graphData objectForKey:STATION_GRAPH_NAME_KEY];
}

- (NSArray *)dataPoints{
	return [graphData objectForKey:STATION_GRAPH_POINTS_KEY];
}

@dynamic dateRange;
- (CPPlotRange *)dateRange{
	NSArray *points = [self dataPoints];
	if(points != nil && [points count]>0){
		NSTimeInterval minDate = [self timeIntervalForPointAtIndex:0];
		NSTimeInterval maxDate = minDate;
		NSTimeInterval currentDate;
		
		for(int i=1; i< [self dataPointCount]; i++){
			currentDate = [self timeIntervalForPointAtIndex:i];
			if(currentDate < minDate){
				minDate = currentDate;
			}
			if(currentDate > maxDate){
				maxDate = currentDate;
			}
		}
		if (addPadding) {
			return [CPPlotRange plotRangeWithLocation:CPDecimalFromDouble(minDate - GRAPH_PADDING_DATE)
											   length:CPDecimalFromDouble(maxDate - minDate + GRAPH_PADDING_DATE)];
		} else {
			return [CPPlotRange plotRangeWithLocation:CPDecimalFromDouble(minDate)
											   length:CPDecimalFromDouble(maxDate - minDate)];
		}
	}
	return nil;
}	

@dynamic valueRange;
- (CPPlotRange *)valueRange{
	NSArray *points = [self dataPoints];
	if(points != nil && [points count]>0){
		double maxValue = 0;
		if(addPadding){
			maxValue = GRAPH_INITIAL_MAX_VALUE;
		}
		double currentValue;
		
		for(int i=0; i< [self dataPointCount]; i++){
			currentValue = [[self valueForPointAtIndex:i]doubleValue];
			if(currentValue > maxValue){
				maxValue = currentValue;
			}
		}
		if(addPadding){
			double pad = (maxValue / GRAPH_PADDING_VALUE) -1; 
			return [CPPlotRange plotRangeWithLocation:CPDecimalFromDouble(0.0 - pad)
											   length:CPDecimalFromDouble(maxValue + GRAPH_PADDING_VALUE)];
		} else {
			return [CPPlotRange plotRangeWithLocation:CPDecimalFromDouble(0.0 - GRAPH_PADDING_VALUE)
											   length:CPDecimalFromDouble(maxValue + GRAPH_PADDING_VALUE)];
		}
	}
	return nil;
}

#pragma mark -
#pragma mark Data Points

- (NSUInteger)dataPointCount{
	return [[self dataPoints] count];
}

- (NSTimeInterval)timeIntervalForPointAtIndex:(NSUInteger)index{
	NSDictionary* pointDict = [[self dataPoints] objectAtIndex:index];
	// Divided by 1000 to convert from Javav form to Objective-C form
	return [(NSNumber*)([pointDict objectForKey:DATA_POINT_DATE_KEY]) doubleValue] / 1000; 
}

- (NSDate*)dateForPointAtIndex:(NSUInteger)index{
	return [NSDate dateWithTimeIntervalSince1970:[self timeIntervalForPointAtIndex:index]];
}

- (NSNumber*)valueForPointAtIndex:(NSUInteger)index{
	NSDictionary* pointDict = [[self dataPoints] objectAtIndex:index];
	return (NSNumber*)([pointDict objectForKey:DATA_POINT_VALUE_KEY]);
}

@end
