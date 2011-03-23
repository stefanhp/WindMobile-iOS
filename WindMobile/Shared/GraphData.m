//
//  GraphData.m
//  WindMobile
//
//  Created by Stefan Hochuli Paychère on 14.02.11.
//  Copyright 2011 Pistache Software. All rights reserved.
//

#import "GraphData.h"

#define DATA_POINT_DATE_KEY @"date"
#define DATA_POINT_VALUE_KEY @"value"

#define STATION_GRAPH_NAME_KEY @"@name"
#define	STATION_GRAPH_POINTS_KEY @"points"

#define STATION_GRAPH_AVERAGE_KEY @"windAverage"
#define STATION_GRAPH_MAX_KEY @"windMax"
#define STATION_GRAPH_DIRECTION_KEY @"windDirection"

@implementation GraphData
@synthesize data;
@synthesize duration;
@synthesize graphType;

- (id)initWithDictionary:(NSDictionary *)aDictionary  andDuration:(NSNumber*)aDuration{
	self = [super init];
	if(self != nil && aDictionary != nil && aDuration != nil){
		data = [aDictionary retain];
		duration = [aDuration retain];
		
		GraphPointType aType = GraphPointTypeAverage;
		NSString* name = [data objectForKey:STATION_GRAPH_NAME_KEY];
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
	[data release];
	[duration release];
	[graphType release];
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
	return [NSString stringWithFormat:@"GraphData %@", [data description]];
}

#pragma mark -
#pragma mark - GraphData properties
@dynamic name;
- (NSString*)name{
	return [data objectForKey:STATION_GRAPH_NAME_KEY];
}

- (NSArray *)dataPoints{
	return [data objectForKey:STATION_GRAPH_POINTS_KEY];
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
