//
//  StationInfo+MKAnnotation.h
//  WindMobile
//
//  Created by Yann on 21.03.11.
//  Copyright 2011 la-haut.info. All rights reserved.
//

#import "StationInfo.h"
#import <MapKit/MapKit.h>

@interface StationInfo (MKAnnotation) //<MKAnnotation>

- (NSString *)title;
- (NSString *)subtitle;

@end
