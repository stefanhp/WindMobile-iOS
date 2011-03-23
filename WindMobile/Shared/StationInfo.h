//
//  StationInfo.h
//  WindMobile
//
//  Created by Stefan Hochuli Paychère on 31.01.11.
//  Copyright 2011 Pistache Software. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreLocation/CoreLocation.h>

enum  {
	StationInfoStatusUndef = 0,
	StationInfoStatusGreen,
	StationInfoStatusOrange,
	StationInfoStatusRed
};
typedef NSUInteger StationInfoStatus;


@interface StationInfo : NSObject {
	NSDictionary* stationInfo;
	CLLocationCoordinate2D coordinate;
}
@property (retain) NSDictionary* stationInfo;
@property (nonatomic, readonly) CLLocationCoordinate2D coordinate; 
// stationInfo properties:
@property (readonly) NSString* stationID;
@property (readonly) NSString* name;
@property (readonly) NSString* shortName;
@property (readonly) NSString* altitude;
@property (readonly) NSString* dataValidity;
@property (readonly) NSString* maintenanceStatus;
@property (readonly) StationInfoStatus maintenanceStatusEnum;

- (id)initWithDictionary:(NSDictionary *)aDictionary;

// NSDictionary composing
- (NSUInteger)count;
- (id)objectForKey:(id)aKey;
- (NSEnumerator *)keyEnumerator;
- (NSString *)description;

@end
