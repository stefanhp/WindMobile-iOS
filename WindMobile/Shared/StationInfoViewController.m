//
//  StationInfoViewController.m
//  WindMobile
//
//  Created by Stefan Hochuli Paychère on 14.05.10.
//  Copyright 2010 Pistache Software. All rights reserved.
//

#import <MapKit/MapKit.h>
#import "IASKSettingsReader.h"

#import "StationInfoViewController.h"
#import "WMReSTClient.h"
#import "iPadHelper.h"
#import "StationInfo.h"
#import "StationDetailMeteoViewController.h"

@interface StationInfoViewController (private)
- (void)startRefreshAnimation;
- (void)stopRefreshAnimation;
- (void)settingsChanged:(NSNotification* )notif;
@end

@implementation StationInfoViewController

@synthesize stations;

#pragma mark -
#pragma mark View lifecycle

- (void)viewDidLoad {
    [super viewDidLoad];
	
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(settingsChanged:) name:kIASKAppSettingChanged object:nil];
    
	[self refreshContent:self];
}

- (void)viewDidUnload {
    [[NSNotificationCenter defaultCenter] removeObserver:self name:kIASKAppSettingChanged object:nil];
}

#pragma mark -
#pragma mark UIViewController (orientation)

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
	return YES;
}

- (void)didRotateFromInterfaceOrientation:(UIInterfaceOrientation)fromInterfaceOrientation {
    [self refreshContent:self];
}

#pragma mark -
#pragma mark Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}


- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
	if (stations != nil) {
		return [stations count];
	}
    return 0;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    static NSString *CellIdentifier = @"StationInfoCell";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:CellIdentifier] autorelease];
    }
    
	StationInfo *data = [stations objectAtIndex:indexPath.row];
    
    // Configure the cell...
	if (data != nil) {
		if ([iPadHelper isIpad]) {
			cell.accessoryType = UITableViewCellAccessoryNone;
		} else {
			cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
		}
        if ([iPadHelper isIpad] || self.interfaceOrientation == UIInterfaceOrientationLandscapeLeft || self.interfaceOrientation == UIInterfaceOrientationLandscapeRight) {
            cell.textLabel.text = [data objectForKey:@"@name"];
        } else {
            cell.textLabel.text = [data objectForKey:@"@shortName"];
        }
		cell.detailTextLabel.text = [NSString stringWithFormat:NSLocalizedStringWithDefaultValue(@"ALTITUDE_FORMAT", 
																								 @"WindMobile", 
																								 [NSBundle mainBundle], 
																								 @"Altitude %@m", 
																								 @"Altitude format string"),
                                     [data objectForKey:@"@altitude"]];
        
		switch (data.maintenanceStatusEnum) {
			case StationInfoStatusGreen:
				cell.imageView.image = [UIImage imageNamed:@"bullet-green"];
				break;
			case StationInfoStatusOrange:
				cell.imageView.image = [UIImage imageNamed:@"bullet-yellow"];
				break;
			case StationInfoStatusRed:
				cell.imageView.image = [UIImage imageNamed:@"bullet-red"];
				break;
			default:
				cell.imageView.image = [UIImage imageNamed:@"bullet-grey"];
				break;
		}
	}
	
	return cell;
}

#pragma mark -
#pragma mark TableView delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
	if(stations != nil && [stations count]>0){
        StationDetailMeteoViewController *meteoVC = nil;
        StationInfo* stationInfo = [stations objectAtIndex:indexPath.row];
        meteoVC = [[StationDetailMeteoViewController alloc] initWithNibName:@"StationDetailMeteoViewController" bundle:nil];
        [meteoVC setStationInfo:stationInfo];
        // push controller
        [self.navigationController pushViewController:meteoVC animated:YES];
        [meteoVC release];
	}
}


#pragma mark -
#pragma mark Memory management

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    
    // Relinquish ownership any cached data, images, etc that aren't in use.
}

- (void)dealloc {
	[client release];
	[stations release];
    [super dealloc];
}

#pragma mark -
#pragma mark Public methods

- (void)refreshContent:(id)sender {
	[self startRefreshAnimation];
	if(client == nil){
		client = [[WMReSTClient alloc] init ];
	}
	
	// (re-)load content
	[client asyncGetStationList:[[NSUserDefaults standardUserDefaults]boolForKey:STATION_OPERATIONAL_KEY] forSender:self];
}

#pragma mark -
#pragma mark Private methods

- (void)startRefreshAnimation{
	// Remove refresh button
	self.navigationItem.rightBarButtonItem = nil;
	
	// activity indicator
	UIActivityIndicatorView *activityIndicator = [[UIActivityIndicatorView alloc] initWithFrame:CGRectMake(0, 0, 20, 20)];
	[activityIndicator startAnimating];
	UIBarButtonItem *activityItem = [[UIBarButtonItem alloc] initWithCustomView:activityIndicator];
	[activityIndicator release];
	self.navigationItem.rightBarButtonItem = activityItem;
	[activityItem release];
}

- (void)stopRefreshAnimation{
	// Stop animation
	self.navigationItem.rightBarButtonItem = nil;
	
	// Put Refresh button on the top left
	UIBarButtonItem *refreshItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemRefresh
																				 target:self 
																				 action:@selector(refreshContent:)];
	self.navigationItem.rightBarButtonItem = refreshItem;
	[refreshItem release];
}

- (void)settingsChanged:(NSNotification* )notif {
    if ([[notif object] isEqualToString:STATION_OPERATIONAL_KEY]) {
        [self refreshContent:self];
    }
}

#pragma mark -
#pragma mark WMReSTClientDelegate

- (void)stationList:(NSArray*)aStationArray{
	[self stopRefreshAnimation];

	self.stations = aStationArray;
	
	// refresh table
	[self.tableView reloadData];
}

- (void)serverError:(NSString *)title message:(NSString *)message{
	[self stopRefreshAnimation];
    [WMReSTClient showError:title message:message];
}

- (void)connectionError:(NSString *)title message:(NSString *)message{
	[self stopRefreshAnimation];
    [WMReSTClient showError:title message:message];
}

@end

