//
//  StationData.h
//  WindMobile
//
//  Created by Stefan Hochuli Paychère on 31.01.11.
//  Copyright 2011 Pistache Software. All rights reserved.
//

#import <Foundation/Foundation.h>

enum  {
	StationDataStatusGreen = 0,
	StationDataStatusOrange,
	StationDataStatusRed
};
typedef NSUInteger StationDataStatus;

@interface StationData : NSObject {
	NSDictionary* stationData;
}
@property (retain) NSDictionary* stationData;
// StationData properties:
@property (readonly) NSString* status;
@property (readonly) StationDataStatus statusEnum;

- (id)initWithDictionary:(NSDictionary *)aDictionary;

// NSDictionary composing
- (NSUInteger)count;
- (id)objectForKey:(id)aKey;
- (NSEnumerator *)keyEnumerator;
- (NSString *)description;

@end
