//
//  AppDelegate_Pad.h
//  WindMobile
//
//  Created by Stefan Hochuli Paychère on 15.04.10.
//  Copyright Pistache Software 2010. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "AppDelegate_WindMobile.h"

@class iPadStationInfoMapVC;

@interface AppDelegate_Pad : AppDelegate_WindMobile {
    UIWindow *window;
	
	iPadStationInfoMapVC *root;
}

@property (nonatomic, retain) IBOutlet UIWindow *window;

@end

