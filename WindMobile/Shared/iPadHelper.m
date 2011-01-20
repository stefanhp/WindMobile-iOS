//
//  iPadHelper.m
//  WindMobile
//
//  Created by Stefan Hochuli Paychère on 22.05.10.
//  Copyright 2010 Pistache Software. All rights reserved.
//

#import "iPadHelper.h"


@implementation iPadHelper
+ (BOOL)isIpad{
	NSString* model = [[UIDevice currentDevice]model];
	if([model rangeOfString:@"iPad"].location != NSNotFound){
		return YES;
	}
	return NO;
}
@end
