//
//  iPadStationInfoViewController.h
//  WindMobile
//
//  Created by Stefan Hochuli Paychère on 15.03.11.
//  Copyright 2011 la-haut.info. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "StationInfoViewController.h"
#import "StationInfo.h"

@protocol iPadStationInfoDelegate
@required
- (void)selectStation:(StationInfo *)station;
@end

@interface iPadStationInfoViewController : StationInfoViewController {
	id <iPadStationInfoDelegate> delegate;
}
@property (nonatomic, assign) IBOutlet id delegate;

@end
