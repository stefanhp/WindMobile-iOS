//
//  AppDelegate_Phone.m
//  WindMobile
//
//  Created by Stefan Hochuli Paychère on 15.04.10.
//  Copyright Pistache Software 2010. All rights reserved.
//

#import "AppDelegate_Phone.h"

@implementation AppDelegate_Phone

@synthesize window;
@synthesize nav;

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {    
	
    // Override point for customization after application launch
	[window addSubview:nav.view];
	[window makeKeyAndVisible];
	
	return YES;
}


- (void)dealloc {
	[nav release];
	[window release];
	[super dealloc];
}


@end
