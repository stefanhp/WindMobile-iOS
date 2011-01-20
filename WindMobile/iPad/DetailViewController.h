//
//  DetailViewController.h
//  WindMobile
//
//  Created by Stefan Hochuli Paychère on 22.05.10.
//  Copyright 2010 Pistache Software. All rights reserved.
//

#import <UIKit/UIKit.h>

@class StationDetailViewController;
@class MapViewController;

#if __IPHONE_OS_VERSION_MAX_ALLOWED > __IPHONE_3_1
@interface DetailViewController : UIViewController <UIPopoverControllerDelegate, UISplitViewControllerDelegate> {
    
    UIPopoverController *popoverController;
    UINavigationBar *navigationBar;
    
}

@property (nonatomic, retain) IBOutlet UINavigationBar *navigationBar;
@property (nonatomic, readonly) StationDetailViewController *stationDetailVC;
//@property (nonatomic, readonly) MapViewController *mapVC;

- (void)dismissPopover:(id)sender;

@end
#endif