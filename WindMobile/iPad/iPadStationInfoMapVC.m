//
//  iPadStationInfoMapVC.m
//  WindMobile
//
//  Created by Stefan Hochuli Paychère on 11.02.11.
//  Copyright 2011 Pistache Software. All rights reserved.
//

#import "iPadStationInfoMapVC.h"
#import "IASKAppSettingsViewController.h"
#import "StationListViewController.h"

@implementation iPadStationInfoMapVC
- (void)viewDidLoad {
    [super viewDidLoad];
	
	settingsItem = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"settings"] 
													style:UIBarButtonItemStylePlain 
												   target:self 
												   action:@selector(showSettings:)];
	NSArray *items = [NSArray arrayWithObject:settingsItem];
	items = [items arrayByAddingObjectsFromArray:self.toolBar.items];
	self.toolBar.items = items;
}

- (void)showSettings:(id)sender{
	// InAppSettings
	IASKAppSettingsViewController *appSettings = [[IASKAppSettingsViewController alloc] initWithNibName:@"IASKAppSettingsView" bundle:nil];
	//appSettings.delegate = self;
    appSettings.showDoneButton = NO;
	
	// Navigation controller
	UINavigationController *aNavController = [[UINavigationController alloc] initWithRootViewController:appSettings];
	
	// show in popover
	UIPopoverController * pop = [[UIPopoverController alloc] initWithContentViewController:aNavController];
	[pop presentPopoverFromBarButtonItem:settingsItem 
				permittedArrowDirections:UIPopoverArrowDirectionAny
								animated:YES];
	
}

- (void)titleAction:(id)sender{
	// Show station list
	StationListViewController *showStations = [[StationListViewController alloc] initWithNibName:@"StationListViewController" bundle:nil];
	showStations.stations = self.stations;
	showStations.selectedStations = self.visibleStations;
	showStations.delegate = self;
	
	// show in popover
	UIPopoverController * pop = [[UIPopoverController alloc] initWithContentViewController:showStations];
	[pop presentPopoverFromBarButtonItem:titleItem 
				permittedArrowDirections:UIPopoverArrowDirectionAny
								animated:YES];
	
}

@end
