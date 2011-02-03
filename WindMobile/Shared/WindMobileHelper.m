//
//  WindMobileHelper.m
//  WindMobile
//
//  Created by Stefan Hochuli Paychère on 02.02.11.
//  Copyright 2011 Pistache Software. All rights reserved.
//

#import "WindMobileHelper.h"


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
}

+ (NSString*)naturalTimeSinceDate:(NSDate*)date{
	if(date == nil){
		return NSLocalizedStringFromTable(@"NOT_AVAILABLE", @"WindMobile", nil);
	}
	NSTimeInterval interval = [date timeIntervalSinceNow];
	NSTimeInterval minutes = interval / 60;
	if(interval >0){
		// future
		if(minutes < 60){
			// minutes
			return [NSString stringWithFormat:NSLocalizedStringFromTable(@"IN_MINUTES", @"WindMobile", nil), (int)minutes];
		} else if (minutes < 60*24){
			// Hours
			return [NSString stringWithFormat:NSLocalizedStringFromTable(@"IN_HOURS", @"WindMobile", nil), (int)(minutes/60)];
		} else if(minutes < 60*24*365){
			// days
			return [NSString stringWithFormat:NSLocalizedStringFromTable(@"IN_DAYS", @"WindMobile", nil), (int)(minutes/(60*24))];
		} else {
			// years
			return [NSString stringWithFormat:NSLocalizedStringFromTable(@"IN_YEARS", @"WindMobile", nil), (int)(minutes/(60*24*365))];
		}
		
	} else {
		// past
		if(-minutes < 60){
			// minutes
			return [NSString stringWithFormat:NSLocalizedStringFromTable(@"AGO_MINUTES", @"WindMobile", nil), -(int)minutes];
		} else  if (-minutes < 60*24) {
			// hours
			return [NSString stringWithFormat:NSLocalizedStringFromTable(@"AGO_HOURS", @"WindMobile", nil), -(int)(minutes/60)];
		} else if (-minutes < 60*24*365) {
			// days
			return [NSString stringWithFormat:NSLocalizedStringFromTable(@"AGO_DAYS", @"WindMobile", nil), -(int)(minutes/(60*24))];
		} else {
			// years
			return [NSString stringWithFormat:NSLocalizedStringFromTable(@"AGO_YEARS", @"WindMobile", nil), -(int)(minutes/(60*24*365))];
		}
	}
	return @"N/A";
}

@end
