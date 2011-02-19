//
//  StationData.m
//  WindMobile
//
//  Created by Stefan Hochuli Paychère on 31.01.11.
//  Copyright 2011 Pistache Software. All rights reserved.
//

#import "StationData.h"
#import "WindMobileHelper.h"

#define STATION_DATA_STATUS_KEY @"@status"
#define STATION_DATA_WIND_CHART_KEY @"windDirectionChart"
#define STATION_DATA_GRAPH_DURATION_KEY @"@duration"
#define STATION_DATA_GRAPH_SERIE_KEY @"serie"
#define STATION_DATA_LAST_UPDATE_KEY @"@lastUpdate"
#define STATION_DATA_WIND_AVERAGE_KEY @"windAverage"
#define STATION_DATA_WIND_MAX_KEY @"windMax"
#define STATION_DATA_WIND_TREND_KEY @"windTrend"
#define STATION_DATA_WIND_HISTORY_MIN_KEY @"windHistoryMin"
#define STATION_DATA_WIND_HISTORY_MAX_KEY @"windHistoryMax"
#define STATION_DATA_WIND_HISTORY_AVERAGE_KEY @"windHistoryAverage"
#define STATION_DATA_WIND_AIR_TEMPERATURE_KEY @"airTemperature"
#define STATION_DATA_WIND_AIR_HUMIDITY_KEY @"airHumidity"

#define STATION_DATA_VALUE_RED @"red"
#define STATION_DATA_VALUE_ORANGE @"orange"
#define STATION_DATA_VALUE_GREEN @"green"

@implementation StationData
@synthesize stationData;
@synthesize windDirection;

- (id)initWithDictionary:(NSDictionary *)aDictionary{
	self = [super init];
	if(self != nil && aDictionary != nil){
		stationData = [aDictionary retain];
		
		// Create graphs
		NSDictionary *chart = [stationData objectForKey:STATION_DATA_WIND_CHART_KEY];
		if(chart != nil){
			NSNumber* aDuration = [NSNumber numberWithInteger:[(NSString*)([chart objectForKey:STATION_DATA_GRAPH_DURATION_KEY]) integerValue]];
			NSDictionary *serie = [chart objectForKey:STATION_DATA_GRAPH_SERIE_KEY];
			windDirection = [[GraphData alloc] initWithDictionary:serie andDuration:aDuration];
			windDirection.addPadding = YES;
		}
		
	}
	return self;
}

- (void)dealloc {
	[stationData release];
	[windDirection release];
	[super dealloc];
}

#pragma mark -
#pragma mark - NSDictionary composition

- (NSUInteger)count{
	return [stationData count];
}

- (id)objectForKey:(id)aKey{
	return [stationData objectForKey:aKey];
}

- (NSEnumerator *)keyEnumerator{
	return [stationData keyEnumerator];
}

- (NSString *)description{
	return [NSString stringWithFormat:@"StationData %@", [stationData description]];
}

#pragma mark -
#pragma mark - StationData properties
@dynamic status;
- (NSString*)status{
	return (NSString*)[stationData objectForKey:STATION_DATA_STATUS_KEY];
}

@dynamic statusEnum;
- (StationDataStatus)statusEnum{
	if([self.status compare:STATION_DATA_VALUE_GREEN] == NSOrderedSame){
		return StationDataStatusGreen;
	} else if([self.status compare:STATION_DATA_VALUE_ORANGE] == NSOrderedSame){
		return StationDataStatusOrange;
	} else if([self.status compare:STATION_DATA_VALUE_RED] == NSOrderedSame){
		return StationDataStatusRed;
	}
	// default:
	return StationDataStatusUndef;
}

@dynamic lastUpdate;
- (NSString*)lastUpdate{
	return [NSString stringWithFormat:@"%@",
			  [WindMobileHelper naturalTimeSinceDate:
			   [WindMobileHelper decodeDateFromString:[stationData objectForKey:STATION_DATA_LAST_UPDATE_KEY]]]];
}

@dynamic windAverage;
- (NSString*)windAverage{
	return [stationData objectForKey:STATION_DATA_WIND_AVERAGE_KEY];
}

@dynamic windMax;
- (NSString*)windMax{
	return [stationData objectForKey:STATION_DATA_WIND_MAX_KEY];
}


@dynamic windTrend;
- (NSString*)windTrend{
	return [stationData objectForKey:STATION_DATA_WIND_TREND_KEY];
}


@dynamic windHistoryMin;
- (NSString*)windHistoryMin{
	return [stationData objectForKey:STATION_DATA_WIND_HISTORY_MIN_KEY];
}


@dynamic windHistoryMax;
- (NSString*)windHistoryMax{
	return [stationData objectForKey:STATION_DATA_WIND_HISTORY_MAX_KEY];
}


@dynamic windHistoryAverage;
- (NSString*)windHistoryAverage{
	return [stationData objectForKey:STATION_DATA_WIND_HISTORY_AVERAGE_KEY];
}


@dynamic airTemperature;
- (NSString*)airTemperature{
	return [stationData objectForKey:STATION_DATA_WIND_AIR_TEMPERATURE_KEY];
}


@dynamic airHumidity;
- (NSString*)airHumidity{
	return [stationData objectForKey:STATION_DATA_WIND_AIR_HUMIDITY_KEY];
}


@end
