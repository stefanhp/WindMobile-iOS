//
//  AppDelegate_Phone.h
//  WindMobile
//
//  Created by Stefan Hochuli Paychère on 15.04.10.
//  Copyright Pistache Software 2010. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface AppDelegate_Phone : NSObject <UIApplicationDelegate> {
	UIWindow *window;
	UITabBarController *tabBarController;
}

@property (nonatomic, retain) IBOutlet UIWindow *window;
@property (nonatomic, retain) IBOutlet UITabBarController *tabBarController;

@end

