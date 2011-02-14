//
//  TestStationData.m
//  WindMobile
//
//  Created by Stefan Hochuli Paychère on 14.02.11.
//  Copyright 2011 Pistache Software. All rights reserved.
//

#import "TestStationData.h"
#import "StationData.h"
#import "CPPlotRange.h"

@implementation TestStationData

#if USE_APPLICATION_UNIT_TEST     // all code under test is in the iPhone Application
#else                           // all code under test must be linked into the Unit Test bundle


#define STATION_DATA_STATUS @"green"

#define STATION_DATA_GRAPH_NAME @"windDirection"

- (void) testData {
	NSDictionary* point1 = [NSDictionary dictionaryWithObjectsAndKeys:
							@"1297666800000", @"date",
							@"1.0", @"value",
							nil];
	
	NSDictionary* point2 = [NSDictionary dictionaryWithObjectsAndKeys:
							@"1297667400000", @"date",
							@"2.0", @"value",
							nil];
	NSDictionary* point3 = [NSDictionary dictionaryWithObjectsAndKeys:
							@"1297668000000", @"date",
							@"3.0", @"value",
							nil];
	
	NSDictionary* serie = [NSDictionary dictionaryWithObjectsAndKeys:
						   STATION_DATA_GRAPH_NAME, @"@name",
						   [NSArray arrayWithObjects:point1, point2, point3, nil], @"points",
						   nil];
	
	NSDictionary* chart = [NSDictionary dictionaryWithObjectsAndKeys:
						   @"3600", @"duration",
						   serie, @"serie",
						   nil];
	
	NSDictionary* data = [NSDictionary dictionaryWithObjectsAndKeys:
						  @"2011-02-14T10:00:00+0100", @"@expirationDate",
						  @"2011-02-14T09:00:00+0100", @"@lastUpdate",
						  @"1001", @"@stationId",
						  STATION_DATA_STATUS, @"@status",
						  @"61.6", @"airHumidity", 
						  @"3.4", @"airTemperature", 
						  @"6.4", @"windAverage",
						  
						  chart, @"windDirectionChart",

						  @"2.9", @"windHistoryAverage",
						  @"19.6", @"windHistoryMax",
						  @"0.6", @"windHistoryMin",
						  @"19.6", @"windMax",
						  @"48", @"windTrend",
						  
						  nil];
    StationData *stationData = [[StationData alloc]initWithDictionary:data];
	
	STAssertTrue((stationData.statusEnum == StationDataStatusGreen), @"Wrong status (%i != %i)", StationDataStatusGreen, stationData.statusEnum);
    
	GraphData *graph = stationData.windDirection;
	
	STAssertNotNil(graph, @"Wind deriction graph should not be nil");
	STAssertTrue([[graph name] isEqualToString:STATION_DATA_GRAPH_NAME], @"Wrong graph name (%@ != %@)", STATION_DATA_GRAPH_NAME, [graph name]);
	
	NSArray *points = graph.dataPoints;
	STAssertNotNil(points, @"Wind deriction graph should have data points");
	STAssertTrue([points count] == 3, @"Wrong number of data points (3 != %i)", [points count]);
	
	DataPoint *point = [points objectAtIndex:0];
	STAssertNotNil(point, @"Data point 1 should not be nil");
	STAssertTrue([[point graphType] unsignedIntValue] == GraphPointTypeDirection, @"Wrong graph type (2 != %@)", [point graphType]);
	STAssertTrue([[point date] timeIntervalSince1970] == 1297666800.0, @"Wrong date (1297666800.0 != %f)", [[point date] timeIntervalSince1970]);
	STAssertTrue(([point.value doubleValue] == 1.0), @"Wrong value (1.0 != %f)", [[point value] doubleValue]);
	
	CPPlotRange* dateRange = graph.dateRange;
	STAssertNotNil(dateRange, @"Date range should not be nil");
	STAssertTrue(dateRange.locationDouble == 1297666800.0, @"Wrong date range location (1297666800.0 != %f)", dateRange.locationDouble);
	STAssertTrue(dateRange.lengthDouble == 1200.0, @"Wrong date range length (1200.0 != %f)", dateRange.lengthDouble);
	
	CPPlotRange* valueRange = graph.valueRange;
	STAssertNotNil(valueRange, @"Value range should not be nil");
	STAssertTrue(valueRange.locationDouble == -4.0, @"Wrong value range location (-4.0 != %f)", valueRange.locationDouble);
	STAssertTrue(valueRange.lengthDouble == 30.0, @"Wrong value range length (30.0 != %f)", valueRange.lengthDouble);
	
}


#endif


@end
