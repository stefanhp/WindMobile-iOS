//
//  iPadStationInfoViewController.m
//  WindMobile
//
//  Created by Stefan Hochuli Paychère on 15.03.11.
//  Copyright 2011 la-haut.info. All rights reserved.
//

#import "iPadStationInfoViewController.h"


@implementation iPadStationInfoViewController
@synthesize delegate;
// Override
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
	if(stations != nil && [stations count]>0){
        StationInfo* stationInfo = [stations objectAtIndex:indexPath.row];
        [delegate selectStation:stationInfo];
    }
}

@end
