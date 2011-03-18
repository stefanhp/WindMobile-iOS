//
//  StationInfoViewController.h
//  WindMobile
//
//  Created by Stefan Hochuli Paychère on 14.05.10.
//  Copyright 2010 Pistache Software. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "WMReSTClient.h"

@interface StationInfoViewController : UITableViewController<WMReSTClientDelegate> {
	WMReSTClient* client;
	NSArray *stations;
}
@property (retain)NSArray *stations;
- (void)refreshContent:(id)sender;
@end