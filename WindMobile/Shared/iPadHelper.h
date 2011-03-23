//
//  iPadHelper.h
//  WindMobile
//
//  Created by Stefan Hochuli Paychère on 22.05.10.
//  Copyright 2010 Pistache Software. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface iPadHelper : NSObject {
}

+(BOOL)isIpad;
+(BOOL)isPresentedModally:(UIViewController*)viewController;

@end
