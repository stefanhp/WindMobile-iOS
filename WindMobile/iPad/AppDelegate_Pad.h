//
//  AppDelegate_Pad.h
//  WindMobile
//
//  Created by Stefan Hochuli Paychère on 15.04.10.
//  Copyright Pistache Software 2010. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface AppDelegate_Pad : NSObject <UIApplicationDelegate> {
    UIWindow *window;
#if __IPHONE_OS_VERSION_MAX_ALLOWED > __IPHONE_3_1
    UISplitViewController *splitViewController;
#endif
}

@property (nonatomic, retain) IBOutlet UIWindow *window;
#if __IPHONE_OS_VERSION_MAX_ALLOWED > __IPHONE_3_1
@property (nonatomic, retain) IBOutlet UISplitViewController *splitViewController;
#endif

@end

