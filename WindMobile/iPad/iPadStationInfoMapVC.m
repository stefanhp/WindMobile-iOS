//
//  iPadStationInfoMapVC.m
//  WindMobile
//
//  Created by Stefan Hochuli Paychère on 11.02.11.
//  Copyright 2011 Pistache Software. All rights reserved.
//

#import "iPadStationInfoMapVC.h"
#import "StationInfoViewController.h"

@implementation iPadStationInfoMapVC
@synthesize settingsPopover;
@synthesize stationsPopover;

- (void)viewDidLoad {
    [super viewDidLoad];
    
    CGRect toolbarRect = self.view.bounds;
    toolbarRect.size.height = 44;
    toolbar = [[UIToolbar alloc] initWithFrame:toolbarRect];
    toolbar.autoresizingMask = UIViewAutoresizingFlexibleWidth;
    toolbar.barStyle = UIBarStyleBlack;
    toolbar.translucent = YES;
    [self.view addSubview:toolbar];
    
    // toolbar buttons
    settingsItem = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"settings"] 
                                                    style:UIBarButtonItemStylePlain 
                                                   target:self 
                                                   action:@selector(showSettingsPopover:)];
    
    stationsItem = [[UIBarButtonItem alloc]initWithTitle:NSLocalizedStringFromTable(@"STATIONS", @"WindMobile", nil)
                                                style:UIBarButtonItemStylePlain 
                                               target:self
                                               action:@selector(showStationsPopover:)];
    
    flexItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace
                                                             target:nil
                                                             action:nil];
    
    refreshItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemRefresh
                                                                target:self 
                                                                action:@selector(refreshAction:)];
    
    UIActivityIndicatorView *activityIndicator = [[UIActivityIndicatorView alloc] initWithFrame:CGRectMake(0, 0, 20, 20)];
    [activityIndicator startAnimating];
    activityItem = [[UIBarButtonItem alloc] initWithCustomView:activityIndicator];
    [activityIndicator release];
    
    NSArray *items = [NSArray arrayWithObjects:settingsItem, flexItem, stationsItem, flexItem, refreshItem, nil];	
    [toolbar setItems:items animated:NO];
}

- (void)startRefreshAnimation{
	NSRange range;
	range.location = 0;
	range.length = [toolbar.items count] -1;
	NSArray *items = [toolbar.items subarrayWithRange:range];
    
	[toolbar setItems:[items arrayByAddingObject:activityItem] animated:NO];
    
	[(UIActivityIndicatorView *)activityItem.customView startAnimating];
}

- (void)stopRefreshAnimation{
	NSRange range;
	range.location = 0;
	range.length = [toolbar.items count] -1;
	NSArray *items = [toolbar.items subarrayWithRange:range];
	
	[toolbar setItems:[items arrayByAddingObject:refreshItem] animated:NO];
}

- (void)showSettingsPopover:(id)sender {
    if (self.settingsPopover == nil) {
        // InAppSettings
        IASKAppSettingsViewController *appSettings = [[IASKAppSettingsViewController alloc] initWithNibName:@"IASKAppSettingsView" bundle:nil];
        //appSettings.delegate = self;
        appSettings.showDoneButton = YES;
        appSettings.title = NSLocalizedStringFromTable(@"SETTINGS", @"WindMobile", nil);
        appSettings.delegate = self;
        
        // Navigation controller
        UINavigationController *aNavController = [[UINavigationController alloc] initWithRootViewController:appSettings];
        [appSettings release];
        
        // show in popover
        self.settingsPopover = [[UIPopoverController alloc] initWithContentViewController:aNavController];
        [aNavController release];
    }
    
    if (self.settingsPopover.popoverVisible == NO) {
        [settingsPopover presentPopoverFromBarButtonItem:settingsItem 
                                permittedArrowDirections:UIPopoverArrowDirectionAny
                                                animated:YES];
    }
}

- (void)showStationsPopover:(id)sender {
    if (self.stationsPopover == nil) {
        // Show station list
        iPadStationInfoViewController *stationListController = [[iPadStationInfoViewController alloc] initWithNibName:@"StationInfoViewController" bundle:nil];
        stationListController.stations = self.stations;
        stationListController.delegate = self;
        
        // show in popover
        self.stationsPopover = [[UIPopoverController alloc] initWithContentViewController:stationListController];
        [stationListController release];
        self.stationsPopover.popoverContentSize = CGSizeMake(380, 450);
    }
    
    if (self.stationsPopover.popoverVisible == NO) {
        [stationsPopover presentPopoverFromBarButtonItem:stationsItem 
                                permittedArrowDirections:UIPopoverArrowDirectionAny
                                                animated:YES];
    }
}

#pragma mark -
#pragma mark IASKSettingsDelegate

- (void)settingsViewControllerDidEnd:(IASKAppSettingsViewController*)sender {
	if (self.settingsPopover != nil) {
		[self.settingsPopover dismissPopoverAnimated:YES];
	}
}

#pragma mark -
#pragma mark iPadStationInfoDelegate methods

- (void)dismissStationsPopover {
    if (self.stationsPopover.popoverVisible) {
        [self.stationsPopover dismissPopoverAnimated:NO];
    }
}

- (void)dealloc {
    [settingsPopover release];
	[stationsPopover release];
	[toolbar release];	
	[stationsItem release];
	[flexItem release];	
	[refreshItem release];	
	[activityItem release];
	[settingsItem release];
    [super dealloc];
}

@end
