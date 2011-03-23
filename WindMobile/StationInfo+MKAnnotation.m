//
//  StationInfo+MKAnnotation.m
//  WindMobile
//
//  Created by Yann on 21.03.11.
//  Copyright 2011 la-haut.info. All rights reserved.
//

#import "StationInfo+MKAnnotation.h"
#import "iPadHelper.h"

@implementation StationInfo (MKAnnotation)

- (NSString *)title {
    if ([iPadHelper isIpad]) {
        return self.name;
    } else {
        return self.shortName;
    }
}

- (NSString *)subtitle {
	return [NSString stringWithFormat:NSLocalizedStringFromTable(@"ALTITUDE_SHORT_FORMAT", @"WindMobile", nil),
			self.altitude];
}

@end
