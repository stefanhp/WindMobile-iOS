//
//  GraphData.h
//  WindMobile
//
//  Created by Stefan Hochuli Paychère on 14.02.11.
//  Copyright 2011 Pistache Software. All rights reserved.
//

/* Sample data:
 <serie name="windAverage">
	<points>
		<date>1297598400000</date>
		<value>10.5</value>
	</points>
	<points>
		<date>1297599000000</date>
		<value>8.8</value>
	</points>
 </serie>
*/

#import <Foundation/Foundation.h>

@class CPPlotRange;

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
	NSNumber* graphType;
	NSDate* date;
	NSNumber* value;
}
@property (retain) NSNumber *graphType;
@property (retain) NSDate *date;
@property (retain) NSNumber *value; 

@end


@interface GraphData : NSObject {
	NSDictionary* graphData;
	NSNumber* duration;
	NSNumber* graphType;
	BOOL addPadding;
}
@property (nonatomic) BOOL addPadding;
@property (retain) NSDictionary* graphData;

@property (readonly) NSString* name;
@property (readonly) NSNumber* duration;
@property (retain) NSNumber *graphType;
@property (readonly) NSArray* dataPoints;
@property (readonly) CPPlotRange* dateRange;
@property (readonly) CPPlotRange* valueRange;

+ (DataPoint*)convertToDataPoint:(NSDictionary*)point forType:(NSNumber*)aType;

- (id)initWithDictionary:(NSDictionary *)aDictionary andDuration:(NSNumber*)duration;

// NSDictionary composing
- (NSUInteger)count;
- (id)objectForKey:(id)aKey;
- (NSEnumerator *)keyEnumerator;
- (NSString *)description;

@end
