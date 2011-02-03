//
//  StationGraph.m
//  WindMobile
//
//  Created by Stefan Hochuli Paychère on 31.01.11.
//  Copyright 2011 Pistache Software. All rights reserved.
//

#import "StationGraph.h"
#import "WindMobileHelper.h"
#import "CorePlot-CocoaTouch.h"

#define STATION_GRAPH_DURATION_KEY @"@duration"
#define STATION_GRAPH_LAST_UPDATE_KEY @"@lastUpdate"
#define STATION_GRAPH_SERIE_KEY @"serie"
#define STATION_GRAPH_NAME_KEY @"@name"
#define	STATION_GRAPH_POINTS_KEY @"points"
#define STATION_GRAPH_AVERAGE_KEY @"windAverage"
#define STATION_GRAPH_MAX_KEY @"windMax"
#define STATION_GRAPH_DIRECTION_KEY @"windDirection"

#define DATA_POINT_DATE_KEY @"date"
#define DATA_POINT_VALUE_KEY @"value"

#define GRAPH_INITIAL_MAX_VALUE 25.0
#define GRAPH_PADDING_VALUE 5.0
#define GRAPH_PADDING_DATE 0.0

@implementation DataPoint
@synthesize graphType;
@synthesize date;
@synthesize value;
- (NSString *)description{
	return [NSString stringWithFormat:@"DataPoint %@, %@, %@", graphType, date, value];
}

@end

@implementation StationGraph
@synthesize stationGraph;
+ (DataPoint*)convertToDataPoint:(NSDictionary*)pointDict forType:(GraphPointType)aType{
	DataPoint *point = [[DataPoint alloc]init];
	point.graphType = [NSNumber numberWithUnsignedInteger:aType];
	
	point.date = [WindMobileHelper decodeDateFromJavaInt:[(NSNumber*)([pointDict objectForKey:DATA_POINT_DATE_KEY]) doubleValue]];
	point.value = [pointDict objectForKey:DATA_POINT_VALUE_KEY];
	return point;
}

- (id)initWithDictionary:(NSDictionary *)aDictionary{
	self = [super init];
	if(self != nil && aDictionary != nil){
		stationGraph = [aDictionary retain];
	}
	return self;
}

#pragma mark -
#pragma mark - NSDictionary composition

- (NSUInteger)count{
	return [stationGraph count];
}

- (id)objectForKey:(id)aKey{
	return [stationGraph objectForKey:aKey];
}

- (NSEnumerator *)keyEnumerator{
	return [stationGraph keyEnumerator];
}

- (NSString *)description{
	return [NSString stringWithFormat:@"StationGraph %@", [stationGraph description]];
}

#pragma mark -
#pragma mark - StationGraph properties
@dynamic duration;
- (NSNumber*)duration{
	return [NSNumber numberWithInteger:[(NSString*)([stationGraph objectForKey:STATION_GRAPH_DURATION_KEY]) integerValue]];
}

@dynamic lastUpdate;
- (NSDate*)lastUpdate{
	return [WindMobileHelper decodeDateFromString:[stationGraph objectForKey:STATION_GRAPH_LAST_UPDATE_KEY]];
}

@dynamic windAveragePoints;
- (NSArray *)windAveragePoints{
	return [self windSeriesForType:GraphPointTypeAverage];
}

@dynamic windMaxPoints;
- (NSArray *)windMaxPoints{
	return [self windSeriesForType:GraphPointTypeMax];
}
@dynamic windDirectionPoints;
- (NSArray *)windDirectionPoints{
	return [self windSeriesForType:GraphPointTypeDirection];
}

- (NSArray*)windSeriesForType:(GraphPointType)aType {
	NSArray *series = [stationGraph objectForKey:STATION_GRAPH_SERIE_KEY];
	if(series != nil){
		NSArray* tmp = nil;
		for(NSDictionary* serie in series){
			BOOL found = NO;
			switch (aType) {
				case GraphPointTypeAverage:
					found = [[serie objectForKey:STATION_GRAPH_NAME_KEY]isEqualToString:STATION_GRAPH_AVERAGE_KEY];
					break;
				case GraphPointTypeMax:
					found = [[serie objectForKey:STATION_GRAPH_NAME_KEY]isEqualToString:STATION_GRAPH_MAX_KEY];
					break;
				case GraphPointTypeDirection:
					found = [[serie objectForKey:STATION_GRAPH_NAME_KEY]isEqualToString:STATION_GRAPH_DIRECTION_KEY];
					break;
				default:
					break;
			}
			if(found){
				tmp = [serie objectForKey:STATION_GRAPH_POINTS_KEY];
				
				NSMutableArray *result = [[NSMutableArray alloc]initWithCapacity:[tmp count]];
				
				for(NSDictionary* dictPoint in tmp){
					[result addObject:[StationGraph convertToDataPoint:dictPoint forType:GraphPointTypeAverage]];
				}
				
				return [NSArray arrayWithArray:result];
			}
		}
	}
	return nil;
}

@dynamic windAverageDateRange;
- (CPPlotRange *)windAverageDateRange{
	return [self rangeForType:GraphPointTypeAverage andProperty:GraphRangeForDate];
}

@dynamic windMaxDateRange;
- (CPPlotRange *)windMaxDateRange{
	return [self rangeForType:GraphPointTypeMax andProperty:GraphRangeForDate];
}
@dynamic windDirectionDateRange;
- (CPPlotRange *)windDirectionDateRange{
	return [self rangeForType:GraphPointTypeDirection andProperty:GraphRangeForDate];
}

@dynamic windAverageValueRange;
- (CPPlotRange *)windAverageValueRange{
	return [self rangeForType:GraphPointTypeAverage andProperty:GraphRangeForValue];
}

@dynamic windMaxValueRange;
- (CPPlotRange *)windMaxValueRange{
	return [self rangeForType:GraphPointTypeMax andProperty:GraphRangeForValue];
}
@dynamic windDirectionValueRange;
- (CPPlotRange *)windDirectionValueRange{
	return [self rangeForType:GraphPointTypeDirection andProperty:GraphRangeForValue];
}

- (CPPlotRange*)rangeForType:(GraphPointType)pointType andProperty:(GraphRangeType)rangeType{
	NSArray *points = [self windSeriesForType:pointType];
	if(points != nil && [points count]>0){
		double maxValue = GRAPH_INITIAL_MAX_VALUE;
		double currentValue;
		NSTimeInterval minDate = [[(DataPoint*)([points objectAtIndex:0]) date] timeIntervalSince1970];
		NSTimeInterval maxDate = minDate;
		NSTimeInterval currentDate;
		
		switch (rangeType) {
			case GraphRangeForDate:
				for(DataPoint* point in points){
					currentDate = [[point date]timeIntervalSince1970];
					if(currentDate < minDate){
						minDate = currentDate;
					}
					if(currentDate > maxDate){
						maxDate = currentDate;
					}
				}
				return [CPPlotRange plotRangeWithLocation:CPDecimalFromDouble(minDate - GRAPH_PADDING_DATE)
												   length:CPDecimalFromDouble(maxDate - minDate + GRAPH_PADDING_DATE)];
				
				break;
			case GraphRangeForValue:
				for(DataPoint* point in points){
					currentValue = [point.value doubleValue];
					if(currentValue > maxValue){
						maxValue = currentValue;
					}
				}
				return [CPPlotRange plotRangeWithLocation:CPDecimalFromDouble(0.0 - GRAPH_PADDING_VALUE)
												   length:CPDecimalFromDouble(maxValue + GRAPH_PADDING_VALUE)];
				break;
			default:
				break;
		}
	}
	return nil;
}

@end
