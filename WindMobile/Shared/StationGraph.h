//
//  StationGraph.h
//  WindMobile
//
//  Created by Stefan Hochuli Paychère on 31.01.11.
//  Copyright 2011 Pistache Software. All rights reserved.
//

/* Sample Data:
 <chart duration="14400" lastUpdate="2011-02-13T17:00:00+0100">
	<serie name="windAverage"/>
	<serie name="windMax"/>
	<serie name="windDirection"/>
 </chart>
 */

#import <Foundation/Foundation.h>
#import "CPPlotRange.h"
#import "GraphData.h"

@interface StationGraph : NSObject {
	NSDictionary* stationGraph;
	BOOL addPadding;
	
	GraphData *windAverage;
	GraphData *windMax;
	GraphData *windDirection;
	
}
@property (retain) NSDictionary* stationGraph;
@property (nonatomic) BOOL addPadding;
// StationGraph properties:
@property (readonly) NSNumber *duration;
@property (readonly) NSDate *lastUpdate;
@property (readonly) GraphData *windAverage;
@property (readonly) GraphData *windMax;
@property (readonly) GraphData *windDirection;

- (id)initWithDictionary:(NSDictionary *)aDictionary;

// NSDictionary composing
- (NSUInteger)count;
- (id)objectForKey:(id)aKey;
- (NSEnumerator *)keyEnumerator;
- (NSString *)description;

@end
