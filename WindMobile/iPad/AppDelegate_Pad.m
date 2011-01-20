//
//  AppDelegate_Pad.m
//  WindMobile
//
//  Created by Stefan Hochuli Paychère on 15.04.10.
//  Copyright Pistache Software 2010. All rights reserved.
//

#import "AppDelegate_Pad.h"

@implementation AppDelegate_Pad

@synthesize window;
#if __IPHONE_OS_VERSION_MAX_ALLOWED > __IPHONE_3_1
@synthesize splitViewController;
#endif


- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {    
	
    // Override point for customization after application launch
#if __IPHONE_OS_VERSION_MAX_ALLOWED > __IPHONE_3_1
	[window addSubview:splitViewController.view];
#endif
    [window makeKeyAndVisible];
	
	return YES;
}


- (void)dealloc {
#if __IPHONE_OS_VERSION_MAX_ALLOWED > __IPHONE_3_1
	[splitViewController release];
#endif
    [window release];
    [super dealloc];
}


@end
