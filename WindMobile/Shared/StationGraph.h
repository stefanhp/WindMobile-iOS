//
//  StationGraph.h
//  WindMobile
//
//  Created by Stefan Hochuli Paychère on 31.01.11.
//  Copyright 2011 Pistache Software. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "CPPlotRange.h"

enum {
	GraphPointTypeAverage = 0,
	GraphPointTypeMax,
	GraphPointTypeDirection
};
typedef NSUInteger GraphPointType;

enum  {
	GraphRangeForType = 0,
	GraphRangeForDate,
	GraphRangeForValue
};
typedef NSUInteger GraphRangeType;

@interface DataPoint : NSObject {
	GraphPointType type;
	NSDate* date;
	NSNumber* value;
}
@property (retain) NSNumber *graphType;
@property (retain) NSDate *date;
@property (retain) NSNumber *value; 

@end

@interface StationGraph : NSObject {
	NSDictionary* stationGraph;
}
@property (retain) NSDictionary* stationGraph;
// StationGraph properties:
@property (readonly) NSNumber* duration;
@property (readonly) NSDate* lastUpdate;
@property (readonly) NSArray* windAveragePoints;
@property (readonly) NSArray* windMaxPoints;
@property (readonly) NSArray* windDirectionPoints;
@property (readonly) CPPlotRange* windAverageDateRange;
@property (readonly) CPPlotRange* windMaxDateRange;
@property (readonly) CPPlotRange* windDirectionDateRange;
@property (readonly) CPPlotRange* windAverageValueRange;
@property (readonly) CPPlotRange* windMaxValueRange;
@property (readonly) CPPlotRange* windDirectionValueRange;

+ (DataPoint*)convertToDataPoint:(NSDictionary*)point forType:(GraphPointType)aType;


- (id)initWithDictionary:(NSDictionary *)aDictionary;

// NSDictionary composing
- (NSUInteger)count;
- (id)objectForKey:(id)aKey;
- (NSEnumerator *)keyEnumerator;
- (NSString *)description;

@end

@interface StationGraph ()
- (NSArray*)windSeriesForType:(GraphPointType)aType;
- (CPPlotRange*)rangeForType:(GraphPointType)pointType andProperty:(GraphRangeType)rangeType;
@end
