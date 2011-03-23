//
//  StationGraph.m
//  WindMobile
//
//  Created by Stefan Hochuli Paychère on 31.01.11.
//  Copyright 2011 Pistache Software. All rights reserved.
//

#import "StationGraphData.h"
#import "WindMobileHelper.h"

#define STATION_GRAPH_DURATION_KEY @"@duration"
#define STATION_GRAPH_LAST_UPDATE_KEY @"@lastUpdate"
#define STATION_GRAPH_SERIE_KEY @"serie"
#define STATION_GRAPH_NAME_KEY @"@name"
#define	STATION_GRAPH_POINTS_KEY @"points"
#define STATION_GRAPH_AVERAGE_KEY @"windAverage"
#define STATION_GRAPH_MAX_KEY @"windMax"
#define STATION_GRAPH_DIRECTION_KEY @"windDirection"

@implementation StationGraphData
@synthesize data;
@synthesize windAverage;
@synthesize windMax;
@synthesize windDirection;

- (id)initWithDictionary:(NSDictionary *)aDictionary{
	self = [super init];
    
	if(self != nil && aDictionary != nil){
		data = [aDictionary retain];
		
		// Create graphs
		NSArray *series = [data objectForKey:STATION_GRAPH_SERIE_KEY];
		NSNumber* aDuration = [NSNumber numberWithInteger:[(NSString*)([data objectForKey:STATION_GRAPH_DURATION_KEY]) integerValue]];
		if(series != nil){
			for(NSDictionary* serie in series){
				NSString *name = [serie objectForKey:STATION_GRAPH_NAME_KEY];
				if([name isEqualToString:STATION_GRAPH_AVERAGE_KEY]){
					windAverage = [[GraphData alloc] initWithDictionary:serie andDuration:aDuration];
				} else if([name isEqualToString:STATION_GRAPH_MAX_KEY]){
					windMax = [[GraphData alloc] initWithDictionary:serie andDuration:aDuration];
				} else if([name isEqualToString:STATION_GRAPH_DIRECTION_KEY]){
					windDirection = [[GraphData alloc] initWithDictionary:serie andDuration:aDuration];
				}
			}
		}
		
	}
	return self;
}

- (void)dealloc {
	[data release];
	[windAverage release];
	[windMax release];
	[windDirection release];
	[super dealloc];
}

#pragma mark -
#pragma mark - NSDictionary composition

- (NSUInteger)count{
	return [data count];
}

- (id)objectForKey:(id)aKey{
	return [data objectForKey:aKey];
}

- (NSEnumerator *)keyEnumerator{
	return [data keyEnumerator];
}

- (NSString *)description{
	return [NSString stringWithFormat:@"StationGraph %@", [data description]];
}

#pragma mark -
#pragma mark - StationGraphData properties
@dynamic duration;
- (NSNumber*)duration{
	return [NSNumber numberWithInteger:[(NSString*)([data objectForKey:STATION_GRAPH_DURATION_KEY]) integerValue]];
}

@dynamic lastUpdate;
- (NSDate*)lastUpdate{
	return [WindMobileHelper decodeDateFromString:[data objectForKey:STATION_GRAPH_LAST_UPDATE_KEY]];
}

@end
