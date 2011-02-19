//
//  StationDetailViewController.m
//  WindMobile
//
//  Created by Stefan Hochuli Paychère on 14.05.10.
//  Copyright 2010 Pistache Software. All rights reserved.
//

#import "StationDetailViewController.h"
#import "CPSReSTClient.h"
#import "MapViewController.h"
#import "iPadHelper.h"
#import "WindPlotController.h"
#import "StationInfo.h"
#import "WindMobileHelper.h"
#import "CorePlot-CocoaTouch.h"

#define SECTION_INFO 0
#define INDEX_ALTITUDE 0
#define INDEX_UPDATE 1
#define INDEX_MAP 2

#define SECTION_CURRENT 1
#define INDEX_WIND_CURRENT 0
#define INDEX_WIND_MAX 1
#define INDEX_WIND_TREND 2
#define INDEX_WIND_GRAPH 3

#define SECTION_WEATHER 2
#define INDEX_TEMPERATURE 0
#define INDEX_HUMIDITY 1

#define SECTION_HISTORY 3
#define INDEX_HISTORY_MIN 0
#define INDEX_HISTORY_MAX 1
#define INDEX_HISTORY_AVERAGE 2

#define SECTION_NUMBER 4

@implementation StationDetailViewController

@synthesize stationInfo;
@synthesize stationData;

#pragma mark -
#pragma mark View lifecycle

- (void)viewDidLoad {
    [super viewDidLoad];
	
    // Uncomment the following line to preserve selection between presentations.
    //self.clearsSelectionOnViewWillAppear = NO;
	
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
	

	self.title = stationInfo.name;
	[self refreshContent:self];
}

// Override to allow orientations other than the default portrait orientation.
- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
    // Return YES for supported orientations
    //return (interfaceOrientation == UIInterfaceOrientationPortrait);
	return YES;
}


#pragma mark -
#pragma mark Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    // Return the number of sections.
    return SECTION_NUMBER;
}


- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    // Return the number of rows in the section.
	switch (section) {
		case SECTION_INFO:
			return INDEX_MAP+1;
			break;
		case SECTION_CURRENT:
			return INDEX_WIND_GRAPH+1;
			break;
		case SECTION_HISTORY:
			return INDEX_HISTORY_AVERAGE+1;
			break;
		case SECTION_WEATHER:
			return INDEX_HUMIDITY+1;
			break;
		default:
			break;
	}
    return 1;
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
    // The header for the section is the region name -- get this from the region at the section index.
	switch (section) {
		case SECTION_INFO:
			return NSLocalizedStringFromTable(@"SECTION_INFO", @"WindMobile", nil); 
			break;
		case SECTION_CURRENT:
			return NSLocalizedStringFromTable(@"SECTION_CURRENT", @"WindMobile", nil);
			break;
		case SECTION_HISTORY:
			return NSLocalizedStringFromTable(@"SECTION_HISTORY", @"WindMobile", nil);
			break;
		case SECTION_WEATHER:
			return NSLocalizedStringFromTable(@"SECTION_WEATHER", @"WindMobile", nil);
			break;
		default:
			break;
	}
    return nil;
}

- (NSString *)tableView:(UITableView *)tableView titleForFooterInSection:(NSInteger)section{
	switch (section) {
		case SECTION_HISTORY:
			return NSLocalizedStringFromTable(@"SECTION_HISTORY_FOOTER", @"WindMobile", nil);
			break;
		default:
			break;
	}
    return nil;
}


// Customize the appearance of table view cells.
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    static NSString *CellIdentifier = @"StationDetailCell";
    static NSString *CellIdentifierGraph = @"GraphCell";
	
    UITableViewCell *cell = nil;
	
	if(indexPath.section == SECTION_CURRENT && indexPath.row == INDEX_WIND_GRAPH){
		cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifierGraph];
		if (cell == nil) {
			cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue1 
										   reuseIdentifier:CellIdentifierGraph]
					autorelease];
			
			WindPlotController *wplot = [[WindPlotController alloc] init];
			[wplot setTitle:[NSString stringWithFormat:@"%@ %@",
							 NSLocalizedStringFromTable(@"SECTION_CURRENT", @"WindMobile", nil),
							 NSLocalizedStringFromTable(@"INDEX_WIND_GRAPH", @"WindMobile", nil)]];
			[wplot setStationInfo:stationInfo];
			wplot.drawAxisSet = NO;
			wplot.isInCell = YES;

			// resize
			CGRect frame = cell.contentView.bounds;
			frame.origin.x	= frame.origin.x + ((frame.size.width/3)) -2.0 ;
			frame.size.width = (frame.size.width/3)*2;
			// Smaller option:
			//frame.origin.x	= frame.size.width - frame.size.height*2 -10.0 ;
			//frame.size.width = frame.size.height*2;
			wplot.view.frame = frame;
			
			//wplot.view.alpha = 0.5;
			
			[cell.contentView addSubview:wplot.view];
			[wplot release];

		}
	} else {
		cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
		if (cell == nil) {
			cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:CellIdentifier] autorelease];
		}
	}

    
    // Configure the cell...
	cell.accessoryType = UITableViewCellAccessoryNone;
	switch(indexPath.section){
		case SECTION_INFO:
			switch(indexPath.row){
				case INDEX_ALTITUDE:
					cell.textLabel.text = NSLocalizedStringFromTable(@"ALTITUDE", @"WindMobile", nil);
					cell.detailTextLabel.text = [NSString stringWithFormat:NSLocalizedStringFromTable(@"ALTITUDE_SHORT_FORMAT", @"WindMobile", nil),self.stationInfo.altitude];
					return cell;
					break;
				case INDEX_UPDATE:
					cell.textLabel.text = NSLocalizedStringFromTable(@"UPDATED", @"WindMobile", nil);
					cell.detailTextLabel.text = [NSString stringWithFormat:@"%@",
												 [WindMobileHelper naturalTimeSinceDate:
												  [WindMobileHelper decodeDateFromString:[stationData objectForKey:@"@lastUpdate"]]]];
					//UIColor *color = cell.detailTextLabel.textColor;
					switch (stationData.statusEnum) {
						case StationDataStatusRed:
							cell.detailTextLabel.textColor = [UIColor redColor];
							break;
						case StationDataStatusOrange:
							cell.detailTextLabel.textColor = [UIColor orangeColor];
							break;
						default:
							cell.detailTextLabel.textColor = [UIColor colorWithRed:0.22 green:0.33 blue:0.53 alpha:1.0];
							break;
					}
					return cell;
					break;
				case INDEX_MAP:
					if([iPadHelper isIpad]){} else {
						cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
					}
					cell.textLabel.text = NSLocalizedStringFromTable(@"COORDINATE", @"WindMobile", nil);
					cell.detailTextLabel.text = NSLocalizedStringFromTable(@"COORDINATE_SHOW", @"WindMobile", nil);
					return cell;
					break;
			}
			break;
		case SECTION_CURRENT:
			switch (indexPath.row) {
				case INDEX_WIND_CURRENT:
					cell.textLabel.text = NSLocalizedStringFromTable(@"WIND_CURRENT", @"WindMobile", nil);
					if([stationData objectForKey:@"windAverage"] != nil){
						cell.detailTextLabel.text = [NSString stringWithFormat:NSLocalizedStringFromTable(@"WIND_FORMAT", @"WindMobile", nil),
													 [stationData objectForKey:@"windAverage"]];
					} else {
						cell.detailTextLabel.text = NSLocalizedStringFromTable(@"NOT_AVAILABLE", @"WindMobile", nil);
					}
					
					return cell;
					break;
				case INDEX_WIND_MAX:
					cell.textLabel.text = NSLocalizedStringFromTable(@"WIND_MAX", @"WindMobile", nil);
					if([stationData objectForKey:@"windMax"] != nil){
						cell.detailTextLabel.text = [NSString stringWithFormat:NSLocalizedStringFromTable(@"WIND_FORMAT", @"WindMobile", nil),
													 [stationData objectForKey:@"windMax"]];
					} else {
						cell.detailTextLabel.text = NSLocalizedStringFromTable(@"NOT_AVAILABLE", @"WindMobile", nil);
					}
					return cell;
					break;
				case INDEX_WIND_TREND:
					cell.textLabel.text = NSLocalizedStringFromTable(@"WIND_TREND", @"WindMobile", nil);
					if([stationData objectForKey:@"windTrend"] != nil){
						cell.detailTextLabel.text = [NSString stringWithFormat:NSLocalizedStringFromTable(@"WIND_TREND_FORMAT", @"WindMobile", nil),
													 [stationData objectForKey:@"windTrend"]];
					} else {
						cell.detailTextLabel.text = NSLocalizedStringFromTable(@"NOT_AVAILABLE", @"WindMobile", nil);
					}
					return cell;
					break;
				case INDEX_WIND_GRAPH:
					if([iPadHelper isIpad]){} else {
						cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
					}
					cell.textLabel.text = NSLocalizedStringFromTable(@"INDEX_WIND_GRAPH", @"WindMobile", nil);
					//cell.detailTextLabel.text = NSLocalizedStringFromTable(@"COORDINATE_SHOW", @"WindMobile", nil);
					return cell;
					
					break;
			}
			break;
		case SECTION_HISTORY:
			switch (indexPath.row) {
				case INDEX_HISTORY_MIN:
					cell.textLabel.text = NSLocalizedStringFromTable(@"WIND_MIN", @"WindMobile", nil);
					if([stationData objectForKey:@"windHistoryMin"] != nil){
						cell.detailTextLabel.text = [NSString stringWithFormat:NSLocalizedStringFromTable(@"WIND_FORMAT", @"WindMobile", nil),
													 [stationData objectForKey:@"windHistoryMin"]];
					} else {
						cell.detailTextLabel.text = NSLocalizedStringFromTable(@"NOT_AVAILABLE", @"WindMobile", nil);
					}
					
					return cell;
					break;
				case INDEX_HISTORY_MAX:
					cell.textLabel.text = NSLocalizedStringFromTable(@"WIND_MAX", @"WindMobile", nil);
					if([stationData objectForKey:@"windHistoryMax"] != nil){
						cell.detailTextLabel.text = [NSString stringWithFormat:NSLocalizedStringFromTable(@"WIND_FORMAT", @"WindMobile", nil),
													 [stationData objectForKey:@"windHistoryMax"]];
					} else {
						cell.detailTextLabel.text = NSLocalizedStringFromTable(@"NOT_AVAILABLE", @"WindMobile", nil);
					}
					return cell;
					break;
				case INDEX_HISTORY_AVERAGE:
					cell.textLabel.text = NSLocalizedStringFromTable(@"WIND_AVERAGE", @"WindMobile", nil);
					if([stationData objectForKey:@"windHistoryAverage"] != nil){
						cell.detailTextLabel.text = [NSString stringWithFormat:NSLocalizedStringFromTable(@"WIND_FORMAT", @"WindMobile", nil),
													 [stationData objectForKey:@"windHistoryAverage"]];
					} else {
						cell.detailTextLabel.text = NSLocalizedStringFromTable(@"NOT_AVAILABLE", @"WindMobile", nil);
					}
					return cell;
					break;
			}
			break;
		case SECTION_WEATHER:
			switch (indexPath.row) {
				case INDEX_TEMPERATURE:
					cell.textLabel.text = NSLocalizedStringFromTable(@"TEMPERATURE", @"WindMobile", nil);
					if([stationData objectForKey:@"airTemperature"] != nil){
						cell.detailTextLabel.text = [NSString stringWithFormat:NSLocalizedStringFromTable(@"TEMPERATURE_FORMAT", @"WindMobile", nil),
													 [stationData objectForKey:@"airTemperature"]];
					} else {
						cell.detailTextLabel.text = NSLocalizedStringFromTable(@"NOT_AVAILABLE", @"WindMobile", nil);
					}
					
					return cell;
					break;
				case INDEX_HUMIDITY:
					cell.textLabel.text = NSLocalizedStringFromTable(@"HUMIDITY", @"WindMobile", nil);
					if([stationData objectForKey:@"airHumidity"] != nil){
						cell.detailTextLabel.text = [NSString stringWithFormat:NSLocalizedStringFromTable(@"HUMIDITY_FORMAT", @"WindMobile", nil),
													 [stationData objectForKey:@"airHumidity"]];
					} else {
						cell.detailTextLabel.text = NSLocalizedStringFromTable(@"NOT_AVAILABLE", @"WindMobile", nil);
					}
					return cell;
					break;
			}
			break;
		default:
			break;
	}
    return cell;
}


/*
// Override to support conditional editing of the table view.
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
    // Return NO if you do not want the specified item to be editable.
    return YES;
}
*/


/*
// Override to support editing the table view.
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        // Delete the row from the data source
        [tableView deleteRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:YES];
    }   
    else if (editingStyle == UITableViewCellEditingStyleInsert) {
        // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
    }   
}
*/


/*
// Override to support rearranging the table view.
- (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)fromIndexPath toIndexPath:(NSIndexPath *)toIndexPath {
}
*/


/*
// Override to support conditional rearranging of the table view.
- (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath {
    // Return NO if you do not want the item to be re-orderable.
    return YES;
}
*/


#pragma mark -
#pragma mark Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
	if(indexPath.section == SECTION_INFO && indexPath.row == INDEX_MAP){
		MapViewController *mapVC = [[MapViewController alloc] initWithNibName:@"MapViewController" bundle:nil];
		
		if([iPadHelper isIpad]){
		} else {
			// push controller
			[self.navigationController pushViewController:mapVC animated:YES];
			[mapVC addAnnotation:self.stationInfo];
			[mapVC release];
		}
	} else if (indexPath.section == SECTION_CURRENT && indexPath.row == INDEX_WIND_GRAPH){
		WindPlotController *wplot = [[WindPlotController alloc] init];
		[wplot setTitle:NSLocalizedStringFromTable(@"INDEX_WIND_GRAPH", @"WindMobile", nil)];
		[wplot setStationInfo:stationInfo];
		wplot.drawAxisSet = YES;
		wplot.isInCell = NO;
		
		if([iPadHelper isIpad]){} else {
			// push controller
			[self.navigationController pushViewController:wplot animated:YES];
		}
		[wplot release];
	}
}


#pragma mark -
#pragma mark Memory management

- (void)didReceiveMemoryWarning {
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Relinquish ownership any cached data, images, etc that aren't in use.
}

- (void)viewDidUnload {
    // Relinquish ownership of anything that can be recreated in viewDidLoad or on demand.
    // For example: self.myOutlet = nil;
}


- (void)dealloc {
	if(client != nil){
		[client release];
	}
    [super dealloc];
}

#pragma mark -
#pragma mark Station Details methods

- (void)refreshContent:(id)sender {
	// In case we're loaded from iPad clear data
	if(stationData){
		[stationData release];
		stationData = nil;
	}
	[self.tableView reloadData];
	
	[self startRefreshAnimation];
	
	if(client == nil){
		client = [[WMReSTClient alloc] init ];
	}
	
	// (re-)load content
	[client asyncGetStationData:self.stationInfo.stationID forSender:self];
}

- (void)stationData:(StationData*)aStationData{
	[self stopRefreshAnimation];

	self.stationData = aStationData;
	
	// refresh table
	[self.tableView reloadData];
}

- (void)requestError:(NSString*) message details:(NSMutableDictionary *)error{
	[self stopRefreshAnimation];
}

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
@end

