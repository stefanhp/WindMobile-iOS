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

#define GRAPH_INITIAL_MAX_VALUE 25.0
#define GRAPH_PADDING_VALUE 5.0
#define GRAPH_PADDING_DATE 0


@implementation StationGraph
@synthesize stationGraph;
@synthesize addPadding;
@synthesize windAverage;
@synthesize windMax;
@synthesize windDirection;

- (id)initWithDictionary:(NSDictionary *)aDictionary{
	self = [super init];
	addPadding = YES;
	if(self != nil && aDictionary != nil){
		stationGraph = [aDictionary retain];
		
		// Create graphs
		NSArray *series = [stationGraph objectForKey:STATION_GRAPH_SERIE_KEY];
		NSNumber* aDuration = [NSNumber numberWithInteger:[(NSString*)([stationGraph objectForKey:STATION_GRAPH_DURATION_KEY]) integerValue]];
		if(series != nil){
			for(NSDictionary* serie in series){
				NSString *name = [serie objectForKey:STATION_GRAPH_NAME_KEY];
				if([name isEqualToString:STATION_GRAPH_AVERAGE_KEY]){
					windAverage = [[GraphData alloc] initWithDictionary:serie andDuration:aDuration];
					windAverage.addPadding = addPadding;
				} else if([name isEqualToString:STATION_GRAPH_MAX_KEY]){
					windMax = [[GraphData alloc] initWithDictionary:serie andDuration:aDuration];
					windMax.addPadding = addPadding;
				} else if([name isEqualToString:STATION_GRAPH_DIRECTION_KEY]){
					windDirection = [[GraphData alloc] initWithDictionary:serie andDuration:aDuration];
					windDirection.addPadding = addPadding;
				}
			}
		}
		
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

@end
