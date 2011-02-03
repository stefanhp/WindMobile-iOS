//
//  WMCellGraphTheme.m
//  WindMobile
//
//  Created by Stefan Hochuli Paychère on 03.02.11.
//  Copyright 2011 Pistache Software. All rights reserved.
//

#import "WMCellGraphTheme.h"
#import "CorePlot-CocoaTouch.h"

@implementation WMCellGraphTheme
+(NSString *)defaultName 
{
	return @"WMCell";
}

-(void)applyThemeToBackground:(CPXYGraph *)graph 
{	
    graph.fill = [CPFill fillWithColor:[CPColor whiteColor]];
}

@end
