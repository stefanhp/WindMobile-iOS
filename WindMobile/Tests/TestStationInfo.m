//
//  TestStationInfo.m
//  WindMobile
//
//  Created by Stefan Hochuli Paychère on 14.02.11.
//  Copyright 2011 Pistache Software. All rights reserved.
//

#import "TestStationInfo.h"
#import "StationInfo.h"

@implementation TestStationInfo

#if USE_APPLICATION_UNIT_TEST     // all code under test is in the iPhone Application
#else                           // all code under test must be linked into the Unit Test bundle

#define STATION_INFO_NAME @"Maubourget"
#define STATION_INFO_ALTITUDE @"1180"
#define STATION_INFO_DATA_VALIDITY @"3600"
#define STATION_INFO_LONGITUDE 6.61194
#define STATION_INFO_LATITUDE 46.85427

- (void) testInfo {
	NSDictionary* data = [NSDictionary dictionaryWithObjectsAndKeys:
						  STATION_INFO_ALTITUDE, @"@altitude",
						  STATION_INFO_DATA_VALIDITY, @"@dataValidity",
						  @"jdc:1001", @"@id",
						  STATION_INFO_NAME, @"@name",
						  STATION_INFO_NAME, @"@shortName",
						  [NSString stringWithFormat:@"%f", STATION_INFO_LONGITUDE], @"@wgs84Longitude",
						  [NSString stringWithFormat:@"%f", STATION_INFO_LATITUDE], @"@wgs84Latitude",
						  nil];
	StationInfo *info = [[StationInfo alloc] initWithDictionary:data];

	STAssertTrue([info.name isEqualToString:STATION_INFO_NAME], @"Wrong name (%@ != %@)", STATION_INFO_NAME, info.name);
	STAssertTrue([info.shortName isEqualToString:STATION_INFO_NAME], @"Wrong shortname (%@ != %@)", STATION_INFO_NAME, info.shortName);
	STAssertTrue([info.altitude isEqualToString:STATION_INFO_ALTITUDE], @"Wrong altitude (%@ != %@)",STATION_INFO_ALTITUDE, info.altitude);
	STAssertTrue([info.dataValidity isEqualToString:STATION_INFO_DATA_VALIDITY], @"Wrong data validity (%@ != %@)",STATION_INFO_DATA_VALIDITY, info.dataValidity);
	STAssertTrue((info.coordinate.longitude == STATION_INFO_LONGITUDE), @"Wrong longitude (%f != %f)",STATION_INFO_LONGITUDE, info.coordinate.longitude);
	STAssertTrue((info.coordinate.latitude == STATION_INFO_LATITUDE), @"Wrong longitude (%f != %f)",STATION_INFO_LATITUDE, info.coordinate.latitude);
	
}


#endif


@end
