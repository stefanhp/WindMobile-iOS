//
//  TestWindMobileHelper.m
//  WindMobile
//
//  Created by Stefan Hochuli Paychère on 02.02.11.
//  Copyright 2011 Pistache Software. All rights reserved.
//

#import "TestWindMobileHelper.h"
#import "WindMobileHelper.h"

#define DATE_TO_TEST_STRING @"2010-05-15T11:40:55+0200"
#define DATE_TO_TEST_YEAR 2010
#define DATE_TO_TEST_MONTH 5
#define DATE_TO_TEST_DAY 15
#define DATE_TO_TEST_HOUR 11
#define DATE_TO_TEST_MINUTE 40
#define DATE_TO_TEST_SECOND 55
#define DATE_TO_TEST_TIMEZONE_SECONDS_FROM_GMT 7200 // +0200 is 2 hours = 2 * 60 * 60 = 7200 seconds
#define DATE_TO_TEST_INT_SECONDS 1273916455.0
#define DATE_TO_TEST_INT_MILLISECONDS 1273916455000.0


@implementation TestWindMobileHelper

#if USE_APPLICATION_UNIT_TEST     // all code under test is in the iPhone Application
#else                           // all code under test must be linked into the Unit Test bundle
- (NSDate*)referenceDate{
	NSDateComponents *datecomp = [[NSDateComponents alloc]init];
	[datecomp setYear:DATE_TO_TEST_YEAR];
	[datecomp setMonth:DATE_TO_TEST_MONTH];
	[datecomp setDay:DATE_TO_TEST_DAY];
	[datecomp setHour:DATE_TO_TEST_HOUR];
	[datecomp setMinute:DATE_TO_TEST_MINUTE];
	[datecomp setSecond:DATE_TO_TEST_SECOND];
	[datecomp setTimeZone:[NSTimeZone timeZoneForSecondsFromGMT:DATE_TO_TEST_TIMEZONE_SECONDS_FROM_GMT]]; 
	NSCalendar *gregorian = [[NSCalendar alloc]
							 initWithCalendarIdentifier:NSGregorianCalendar];
	return [gregorian dateFromComponents:datecomp];	
}

- (void) testDecodeDateFromString {
	// Expected date format (sample): "2010-05-15T11:40:00+0200"
	
	NSDate* date = [WindMobileHelper decodeDateFromString:DATE_TO_TEST_STRING];
	STAssertNotNil(date, @"Could not decode date from String");
	
	STAssertTrue([date isEqualToDate:[self referenceDate]], @"String decoded date is wrong (%@ != %@)", date, [self referenceDate]);
}

- (void)testDecodeDateFromInt {
	NSDate* date1 = [WindMobileHelper decodeDateFromString:DATE_TO_TEST_STRING];
	NSLog(@"Seconds since 1970: %f", [date1 timeIntervalSince1970]);
	NSDate* date = [WindMobileHelper decodeDateFromJavaInt:DATE_TO_TEST_INT_MILLISECONDS];
	STAssertNotNil(date, @"Could not decode Java date in milliseconds");

	STAssertTrue([date isEqualToDate:[self referenceDate]], @"Java milliseconds date is wrong (%@ != %@)", date, [self referenceDate]);
}


#endif


@end
