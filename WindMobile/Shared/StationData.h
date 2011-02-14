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
	StationDataStatusGreen = 0,
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
@property (readonly) NSString* status;
@property (readonly) StationDataStatus statusEnum;
@property (readonly) GraphData *windDirection;

- (id)initWithDictionary:(NSDictionary *)aDictionary;

// NSDictionary composing
- (NSUInteger)count;
- (id)objectForKey:(id)aKey;
- (NSEnumerator *)keyEnumerator;
- (NSString *)description;

@end
