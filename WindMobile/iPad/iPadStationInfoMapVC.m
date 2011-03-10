//
//  iPadStationInfoMapVC.m
//  WindMobile
//
//  Created by Stefan Hochuli Paychère on 11.02.11.
//  Copyright 2011 Pistache Software. All rights reserved.
//

#import "iPadStationInfoMapVC.h"
#import "StationListViewController.h"

@implementation iPadStationInfoMapVC
@synthesize settingsPopOver;
@synthesize stationsPopOver;

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
                                                   action:@selector(showSettings:)];
    
    titleItem = [[UIBarButtonItem alloc]initWithTitle:NSLocalizedStringFromTable(@"STATIONS", @"WindMobile", nil)
                                                style:UIBarButtonItemStylePlain 
                                               target:self
                                               action:@selector(titleAction:)];
    
    flexItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace
                                                             target:nil
                                                             action:nil];
    
    refreshItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemRefresh
                                                                target:self 
                                                                action:@selector(refreshContent:)];
    
    UIActivityIndicatorView *activityIndicator = [[UIActivityIndicatorView alloc] initWithFrame:CGRectMake(0, 0, 20, 20)];
    [activityIndicator startAnimating];
    activityItem = [[UIBarButtonItem alloc] initWithCustomView:activityIndicator];
    [activityIndicator release];
    
    NSArray *items = [NSArray arrayWithObjects:settingsItem, flexItem, titleItem, flexItem, refreshItem, nil];	
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

#pragma mark -
#pragma mark IASKSettingsDelegate
- (void)settingsViewControllerDidEnd:(IASKAppSettingsViewController*)sender{
	// Update changed preferences
	// Map type
	mapView.mapType =[[NSUserDefaults standardUserDefaults]doubleForKey:MAP_TYPE_KEY];
	
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
    [settingsPopOver release];
	[stationsPopOver release];
	[toolbar release];	
	[titleItem release];
	[flexItem release];	
	[refreshItem release];	
	[activityItem release];
	[settingsItem release];
    [super dealloc];
}

@end
