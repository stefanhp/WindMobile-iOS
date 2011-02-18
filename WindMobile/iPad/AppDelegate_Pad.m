//
//  AppDelegate_Pad.m
//  WindMobile
//
//  Created by Stefan Hochuli Paychère on 15.04.10.
//  Copyright Pistache Software 2010. All rights reserved.
//

#import "AppDelegate_Pad.h"
#import "iPadStationInfoMapVC.h"

@implementation AppDelegate_Pad

@synthesize window;


- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {    
	
    // Override point for customization after application launch
	root = [[iPadStationInfoMapVC alloc]initWithNibName:@"StationInfoMapViewController"
												  bundle:nil];
	window.rootViewController = root;
	/*
	root.view.frame = window.bounds;
	[window addSubview:root.view];
	 */
    [window makeKeyAndVisible];
	
	return YES;
}


- (void)dealloc {
	[root release];
    [window release];
    [super dealloc];
}


@end
