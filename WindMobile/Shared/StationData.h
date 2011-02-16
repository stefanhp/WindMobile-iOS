//
//  StationData.h
//  WindMobile
//
//  Created by Stefan Hochuli Paychère on 31.01.11.
//  Copyright 2011 Pistache Software. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "GraphData.h"

enum  {
	StationDataStatusUndef = 0,
	StationDataStatusGreen,
	StationDataStatusOrange,
	StationDataStatusRed
};
typedef NSUInteger StationDataStatus;

@interface StationData : NSObject {
	NSDictionary* stationData;

	GraphData *windDirection;
}
@property (retain) NSDictionary* stationData;
// StationData properties:
@property (readonly) NSString *status;
@property (readonly) StationDataStatus statusEnum;
@property (readonly) GraphData *windDirection;
@property (readonly) NSString *lastUpdate;
@property (readonly) NSString *windAverage;
@property (readonly) NSString *windMax;
@property (readonly) NSString *windTrend;
@property (readonly) NSString *windHistoryMin;
@property (readonly) NSString *windHistoryMax;
@property (readonly) NSString *windHistoryAverage;
@property (readonly) NSString *airTemperature;
@property (readonly) NSString *airHumidity;

- (id)initWithDictionary:(NSDictionary *)aDictionary;

// NSDictionary composing
- (NSUInteger)count;
- (id)objectForKey:(id)aKey;
- (NSEnumerator *)keyEnumerator;
- (NSString *)description;

@end
