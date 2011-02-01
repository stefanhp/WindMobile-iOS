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
@synthesize tabBarController;

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {    
	
    // Override point for customization after application launch
	[self.window addSubview:tabBarController.view];
    [self.window makeKeyAndVisible];
	
	return YES;
}


- (void)dealloc {
	[tabBarController release];
	[window release];
	[super dealloc];
}


@end
