//
//  StationInfo.m
//  WindMobile
//
//  Created by Stefan Hochuli Paychère on 31.01.11.
//  Copyright 2011 Pistache Software. All rights reserved.
//

#import "StationInfo.h"
#import "iPadHelper.h"

#define STATION_INFO_ID_KEY @"@id"
#define STATION_INFO_NAME_KEY @"@name"
#define STATION_INFO_SHORT_NAME_KEY @"@shortName"
#define STATION_INFO_ALTITUDE_KEY @"@altitude"
#define STATION_INFO_DATA_VALIDITY_KEY @"@dataValidity"
#define STATION_INFO_MAINTENANCE_STATUS_KEY @"@maintenanceStatus"

#define STATION_INFO_VALUE_RED @"red"
#define STATION_INFO_VALUE_ORANGE @"orange"
#define STATION_INFO_VALUE_GREEN @"green"

@implementation StationInfo

@synthesize stationInfo;
@synthesize coordinate;

- (id)initWithDictionary:(NSDictionary *)aDictionary{
	self = [super init];
	if(self != nil && aDictionary != nil){
		stationInfo = [aDictionary retain];
		//coordinate
		NSString *wgs84Latitude = [stationInfo objectForKey:@"@wgs84Latitude"];
		NSString *wgs84Longitude = [stationInfo objectForKey:@"@wgs84Longitude"];
		
		if(wgs84Latitude != nil && wgs84Longitude != nil){
			coordinate.latitude = [wgs84Latitude doubleValue];
			coordinate.longitude = [wgs84Longitude doubleValue];
		}
	}
	return self;
}

- (void)dealloc {
	[stationInfo release];
	[super dealloc];
}

#pragma mark -
#pragma mark - NSDictionary composition

- (NSUInteger)count{
	return [stationInfo count];
}

- (id)objectForKey:(id)aKey{
	return [stationInfo objectForKey:aKey];
}

- (NSEnumerator *)keyEnumerator{
	return [stationInfo keyEnumerator];
}

- (NSString *)description{
	return [NSString stringWithFormat:@"StationInfo %f,%f %@", coordinate.longitude,coordinate.latitude ,[stationInfo description]];
}

#pragma mark -
#pragma mark - StationInfo properties
@dynamic name;
- (NSString*)name{
	return (NSString*)[stationInfo objectForKey:STATION_INFO_NAME_KEY];
}

@dynamic shortName;
- (NSString*)shortName{
	return (NSString*)[stationInfo objectForKey:STATION_INFO_SHORT_NAME_KEY];
}

@dynamic altitude;
- (NSString*)altitude{
	return (NSString*)[stationInfo objectForKey:STATION_INFO_ALTITUDE_KEY];
}

@dynamic dataValidity;
- (NSString*)dataValidity{
	return (NSString*)[stationInfo objectForKey:STATION_INFO_DATA_VALIDITY_KEY];
}

@dynamic stationID;
- (NSString*)stationID{
	return (NSString*)[stationInfo objectForKey:STATION_INFO_ID_KEY];
}

@dynamic maintenanceStatus;
- (NSString*)maintenanceStatus{
	return (NSString*)[stationInfo objectForKey:STATION_INFO_MAINTENANCE_STATUS_KEY];
}

@dynamic maintenanceStatusEnum;
- (StationInfoStatus)maintenanceStatusEnum{
	if(self.maintenanceStatus == nil){
		return StationInfoStatusUndef;
	}
	
	if([self.maintenanceStatus compare:STATION_INFO_VALUE_GREEN] == NSOrderedSame){
		return StationInfoStatusGreen;
	} else if([self.maintenanceStatus compare:STATION_INFO_VALUE_ORANGE] == NSOrderedSame){
		return StationInfoStatusOrange;
	} else if([self.maintenanceStatus compare:STATION_INFO_VALUE_RED] == NSOrderedSame){
		return StationInfoStatusRed;
	}
	// default:
	return StationInfoStatusUndef;
}

@end
