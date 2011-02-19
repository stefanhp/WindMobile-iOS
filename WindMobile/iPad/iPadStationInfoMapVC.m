//
//  iPadStationInfoMapVC.m
//  WindMobile
//
//  Created by Stefan Hochuli Paychère on 11.02.11.
//  Copyright 2011 Pistache Software. All rights reserved.
//

#import "iPadStationInfoMapVC.h"
#import "StationListViewController.h"
#import "MapViewController.h"

@implementation iPadStationInfoMapVC
@synthesize settingsPopOver;
@synthesize stationsPopOver;

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
    appSettings.showDoneButton = YES;
	appSettings.title = NSLocalizedStringFromTable(@"SETTINGS", @"WindMobile", nil);
	appSettings.delegate = self;
	
	// Navigation controller
	UINavigationController *aNavController = [[UINavigationController alloc] initWithRootViewController:appSettings];
	[appSettings release];
	
	// show in popover
	self.settingsPopOver = [[UIPopoverController alloc] initWithContentViewController:aNavController];
	[settingsPopOver presentPopoverFromBarButtonItem:settingsItem 
							permittedArrowDirections:UIPopoverArrowDirectionAny
											animated:YES];
	[aNavController release];
	
}

- (void)titleAction:(id)sender{
	// Show station list
	StationListViewController *showStations = [[StationListViewController alloc] initWithNibName:@"StationListViewController" bundle:nil];
	showStations.stations = self.stations;
	showStations.selectedStations = self.visibleStations;
	showStations.delegate = self;
	
	// show in popover
	self.stationsPopOver = [[UIPopoverController alloc] initWithContentViewController:showStations];
	[stationsPopOver presentPopoverFromBarButtonItem:titleItem 
				permittedArrowDirections:UIPopoverArrowDirectionAny
								animated:YES];
	[showStations release];
	
}

#pragma mark -
#pragma mark IASKSettingsDelegate
- (void)settingsViewControllerDidEnd:(IASKAppSettingsViewController*)sender{
	// Update changed preferences
	// Map type
	map.mapView.mapType =[[NSUserDefaults standardUserDefaults]doubleForKey:MAP_TYPE_KEY];
	
	// Timeout and mock data
	if(client != nil){
		// we only update an existing client: newly created clients will use the new default values
		client.timeout = [[NSUserDefaults standardUserDefaults]doubleForKey:TIMEOUT_KEY];
	}
	if(self.settingsPopOver != nil){
		[settingsPopOver dismissPopoverAnimated:YES];
	}
}

- (void)dealloc {
	[settingsItem release];
	[settingsPopOver release];
	[stationsPopOver release];
	
	self.stationsPopOver = nil;
    [super dealloc];
}

@end
