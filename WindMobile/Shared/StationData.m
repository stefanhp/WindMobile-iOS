//
//  StationData.m
//  WindMobile
//
//  Created by Stefan Hochuli Paychère on 31.01.11.
//  Copyright 2011 Pistache Software. All rights reserved.
//

#import "StationData.h"

#define STATION_DATA_STATUS_KEY @"@status"

#define STATION_DATA_VALUE_RED @"red"
#define STATION_DATA_VALUE_ORANGE @"orange"
#define STATION_DATA_VALUE_GREEN @"green"

@implementation StationData
@synthesize stationData;
- (id)initWithDictionary:(NSDictionary *)aDictionary{
	self = [super init];
	if(self != nil && aDictionary != nil){
		stationData = [aDictionary retain];
	}
	return self;
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
	}
	// default:
	return StationDataStatusRed;
}


@end
