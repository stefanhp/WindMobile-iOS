//
//  AppDelegate_WindMobile.m
//  WindMobile
//
//  Created by Yann on 28.02.11.
//  Copyright 2011 la-haut.info. All rights reserved.
//

#import "AppDelegate_WindMobile.h"


@implementation AppDelegate_WindMobile

+ (void)initialize {
	// Default values in Root.plist and Root.inApp.plist are not take in account (http://www.cocoanetics.com/2010/07/defaults-for-the-defaults/)
	NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
	NSArray *keys = [NSArray arrayWithObjects:STATION_OPERATIONAL_KEY, MAP_TYPE_KEY, TIMEOUT_KEY, nil];
	NSArray *objects = [NSArray arrayWithObjects:@"YES", @"0", @"20", nil];
	NSDictionary *defaultsDict = [NSDictionary dictionaryWithObjects:objects forKeys:keys];
	[defaults registerDefaults:defaultsDict];
}

@end
