//
//  WindMobileHelper.m
//  WindMobile
//
//  Created by Stefan Hochuli Paychère on 02.02.11.
//  Copyright 2011 Pistache Software. All rights reserved.
//

#import "WindMobileHelper.h"

#define ONE_HOUR 60 // 60 minutes
#define ONE_DAY 1440 // 60*24 = 1440 minutes
#define ONE_YEAR 525600 // 60*24*365 = 525600 minutes

@implementation WindMobileHelper
+ (NSDate*)decodeDateFromString:(NSString*)stringDate{
	if(stringDate == nil){
		return nil;
	}
	if([stringDate length]<24){
		return nil;
	}
	// Expected date format (sample): "2010-02-15T11:14:25.678+01:00"
	// Expected date format (sample): "2010-05-15T11:40:00+0200"
	NSDateFormatter *dateFormatter = [[[NSDateFormatter alloc] init]autorelease];
	[dateFormatter setDateFormat:@"yyyy-MM-dd'T'HH:mm:ssZ"]; 
	//NSString* toDecodeDate = [[stringDate substringToIndex:19]stringByAppendingString:[stringDate substringFromIndex:23]];
	//NSLog(@"To decode date: %@", toDecodeDate);
	return [dateFormatter dateFromString:stringDate];
}

+ (NSDate*)decodeDateFromJavaInt:(double)dateValue{
	// Java dates are in milliseconds since January 1, 1970, 00:00:00 GMT
	// not to exceed the milliseconds representation for the year 8099.
	// A negative number indicates the number of milliseconds before January 1, 1970, 00:00:00 GMT 
	// Objective-C are in seconds since the same reference date.
	NSTimeInterval seconds = (NSTimeInterval)(dateValue / 1000);
	return [NSDate dateWithTimeIntervalSince1970:seconds];
	//return [[NSDate dateWithTimeIntervalSince1970:seconds]autorelease];
}

+ (NSString*)naturalTimeSinceDate:(NSDate*)date{
	if(date == nil){
		return NSLocalizedStringFromTable(@"NOT_AVAILABLE", @"WindMobile", nil);
	}
	NSTimeInterval interval = [date timeIntervalSinceNow];
	NSTimeInterval minutes = interval / 60;
	if(interval >0){
		// future
		if(minutes < ONE_HOUR){
			// minutes
			return [NSString stringWithFormat:NSLocalizedStringFromTable(@"IN_MINUTES", @"WindMobile", nil), (int)minutes];
		} else if (minutes < ONE_DAY){
			// Hours
			return [NSString stringWithFormat:NSLocalizedStringFromTable(@"IN_HOURS", @"WindMobile", nil), (int)(minutes/ONE_HOUR)];
		} else if(minutes < ONE_YEAR){
			// days
			return [NSString stringWithFormat:NSLocalizedStringFromTable(@"IN_DAYS", @"WindMobile", nil), (int)(minutes/ONE_DAY)];
		} else {
			// years
			return [NSString stringWithFormat:NSLocalizedStringFromTable(@"IN_YEARS", @"WindMobile", nil), (int)(minutes/ONE_YEAR)];
		}
		
	} else {
		// past
		if(-minutes < ONE_HOUR){
			// minutes
			return [NSString stringWithFormat:NSLocalizedStringFromTable(@"AGO_MINUTES", @"WindMobile", nil), -(int)minutes];
		} else  if (-minutes < ONE_DAY) {
			// hours
			return [NSString stringWithFormat:NSLocalizedStringFromTable(@"AGO_HOURS", @"WindMobile", nil), -(int)(minutes/ONE_HOUR)];
		} else if (-minutes < ONE_YEAR) {
			// days
			return [NSString stringWithFormat:NSLocalizedStringFromTable(@"AGO_DAYS", @"WindMobile", nil), -(int)(minutes/ONE_DAY)];
		} else {
			// years
			return [NSString stringWithFormat:NSLocalizedStringFromTable(@"AGO_YEARS", @"WindMobile", nil), -(int)(minutes/ONE_YEAR)];
		}
	}
	return NSLocalizedStringFromTable(@"NOT_AVAILABLE", @"WindMobile", nil);
}

+ (NSString *)windDirectionLabel:(double)windDirection {
    // See WindMobile.strings
    static int sectorNumber = 8;
    
    float sector = 360 / sectorNumber;
    float directionAngle = 0;
    for (int directionIndex = 0; directionIndex < sectorNumber; directionIndex++) {
        float min = directionAngle - sector / 2;
        float max = directionAngle + sector / 2;
        
        if (directionIndex == 0) {
            // Looking for the north "half sector" from 337.5 to 360
            if ((windDirection >= 360 + min) && (windDirection <= 360)) {
                NSString *key = [NSString stringWithFormat:@"WIND_DIRECTION_%i", 0];
                return NSLocalizedStringFromTable(key, @"WindMobile", nil);
            }
        }
        if ((windDirection >= min) && (windDirection < max)) {
            NSString *key = [NSString stringWithFormat:@"WIND_DIRECTION_%i", directionIndex];
            return NSLocalizedStringFromTable(key, @"WindMobile", nil);
        }
        
        directionAngle += sector;
    }
    return nil;
}

+ (BOOL)isPeak:(double[])values size:(int)size {
    int middleIndex = size / 2;
    double middleValue = values[middleIndex];
    double maxValue = 0;
    int maxIndex = 0;
    
    for (int i = 0; i < size; i++) {
        double currentValue = values[i];
        if (currentValue > middleValue) {         
            return NO;
        }
        
        // Mark the 1st max value only if the chart contains a "flat" max
        if (currentValue > maxValue) {
            maxValue = currentValue;
            maxIndex = i;
        }
    }
    return (maxIndex == middleIndex);
}

@end
