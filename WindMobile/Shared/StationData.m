//
//  StationData.m
//  WindMobile
//
//  Created by Stefan Hochuli Paychère on 31.01.11.
//  Copyright 2011 Pistache Software. All rights reserved.
//

#import "StationData.h"

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


@end
