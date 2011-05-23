//
//  iPadStationInfoMapVC.m
//  WindMobile
//
//  Created by Stefan Hochuli Paychère on 11.02.11.
//  Copyright 2011 Pistache Software. All rights reserved.
//

#import "iPadStationInfoMapVC.h"
#import "StationInfoViewController.h"
#import "StationDetailMeteoViewController.h"

#import "ChatTableViewController.h"

@implementation iPadStationInfoMapVC

@synthesize settingsPopover;
@synthesize stationsPopover;
@synthesize detailPopover;
@synthesize chatPopover;

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
                                                style:UIBarButtonItemStyleBordered 
                                               target:self
                                               action:@selector(showStationsPopover:)];
    
    chatItem = [[UIBarButtonItem alloc]initWithTitle:NSLocalizedStringFromTable(@"CHAT_TABLE_TITLE", @"WindMobile", nil)
                                                   style:UIBarButtonItemStyleBordered 
                                                  target:self
                                                  action:@selector(showChatPopover:)];
    
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
    
    NSArray *items = [NSArray arrayWithObjects:settingsItem, flexItem, stationsItem, chatItem, flexItem, refreshItem, nil];	
    [toolbar setItems:items animated:NO];
}

- (void)didRotateFromInterfaceOrientation:(UIInterfaceOrientation)fromInterfaceOrientation {
    if (self.detailPopover.popoverVisible == YES) {
        // Hide the popover because its position will not be updated after the screen rotation
        [detailPopover dismissPopoverAnimated:NO];
    }
}

- (void)startRefreshAnimation{
	NSRange range;
	range.location = 0;
	range.length = [toolbar.items count] -1;
	NSArray *items = [toolbar.items subarrayWithRange:range];
    
	[toolbar setItems:[items arrayByAddingObject:activityItem] animated:NO];
    
	[(UIActivityIndicatorView *)activityItem.customView startAnimating];
    
    // Disable stations popover button
    [stationsItem setEnabled:NO];    
    [chatItem setEnabled:NO];    
}

- (void)stopRefreshAnimation{
	NSRange range;
	range.location = 0;
	range.length = [toolbar.items count] -1;
	NSArray *items = [toolbar.items subarrayWithRange:range];
	
	[toolbar setItems:[items arrayByAddingObject:refreshItem] animated:NO];
    
    // Enable stations popover button
    [stationsItem setEnabled:YES];
    [chatItem setEnabled:YES];
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

- (void)showChatPopover:(id)sender {
    ChatTableViewController *chatTableViewController;
    UINavigationController *aNavController;
    
    if (self.chatPopover == nil) {
        // Show chat list
        chatTableViewController = [[ChatTableViewController alloc] initWithNibName:@"ChatView" bundle:nil];
        //chatTableViewController.delegate = self;
        //chatTableViewController.stations = self.stations;

        // Navigation controller
        aNavController = [[UINavigationController alloc] initWithRootViewController:chatTableViewController];
        [chatTableViewController release];

        // show in popover
        self.chatPopover = [[UIPopoverController alloc] initWithContentViewController:aNavController];
        [aNavController release];
        
        self.chatPopover.popoverContentSize = CGSizeMake(380, 450);
    } else {
        aNavController = (UINavigationController *)self.chatPopover.contentViewController;
        [aNavController popToRootViewControllerAnimated:NO];
        chatTableViewController = (ChatTableViewController *)aNavController.topViewController;
    }
    
    if (self.chatPopover.popoverVisible == NO) {
        [chatPopover presentPopoverFromBarButtonItem:chatItem 
                                permittedArrowDirections:UIPopoverArrowDirectionAny
                                                animated:YES];
        
        //stationListController.stations = self.stations;
        [chatTableViewController refreshContent:self];
    }
}

- (void)showStationsPopover:(id)sender {
    iPadStationInfoViewController *stationListController;
    
    if (self.stationsPopover == nil) {
        // Show station list
        stationListController = [[iPadStationInfoViewController alloc] initWithNibName:@"StationInfoViewController" bundle:nil];
        stationListController.delegate = self;
        stationListController.stations = self.stations;
        
        // show in popover
        self.stationsPopover = [[UIPopoverController alloc] initWithContentViewController:stationListController];
        [stationListController release];
        self.stationsPopover.popoverContentSize = CGSizeMake(380, 450);
    } else {
        stationListController = (iPadStationInfoViewController *)self.stationsPopover.contentViewController;
    }
    
    if (self.stationsPopover.popoverVisible == NO) {
        [stationsPopover presentPopoverFromBarButtonItem:stationsItem 
                                permittedArrowDirections:UIPopoverArrowDirectionAny
                                                animated:YES];
        
        stationListController.stations = self.stations;
        [stationListController refreshContent:self];
    }
}

- (void)showStationDetail:(id)sender {
    if ([self.mapView.selectedAnnotations count] == 0) {
        return;
    }
    id<MKAnnotation> annotation = [self.mapView.selectedAnnotations objectAtIndex:0];
    
	StationDetailMeteoViewController *meteo = [[StationDetailMeteoViewController alloc]initWithNibName:@"StationDetailMeteoViewController" bundle:nil];
    meteo.stationInfo = annotation;
	UINavigationController *nav = [[UINavigationController alloc] initWithRootViewController:meteo];
	[meteo release];
    
    self.detailPopover = [[UIPopoverController alloc] initWithContentViewController:nav];
    [nav release];
    // Done in StationDetailMeteoViewController
    //self.detailPopover.popoverContentSize = CGSizeMake(320, 380);
    
    if (self.detailPopover.popoverVisible == NO) {
        // Deselect annotation
        [self.mapView deselectAnnotation:annotation animated:NO];
        
        // Show from point
        CGPoint point = [self.mapView convertCoordinate:annotation.coordinate toPointToView:self.view];
        [detailPopover presentPopoverFromRect:CGRectMake(point.x + 6.5, point.y - 27.0, 1.0, 1.0) 
                                       inView:self.view 
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
	[detailPopover release];    
	[toolbar release];	
	[stationsItem release];
	[chatItem release];
	[flexItem release];	
	[refreshItem release];	
	[activityItem release];
	[settingsItem release];
    [super dealloc];
}

@end
