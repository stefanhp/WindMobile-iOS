//
//  StationInfoViewController.m
//  WindMobile
//
//  Created by Stefan Hochuli Paychère on 14.05.10.
//  Copyright 2010 Pistache Software. All rights reserved.
//

#import "StationInfoViewController.h"
#import "WMReSTClient.h"
#import "StationDetailViewController.h"
#import <MapKit/MapKit.h>
#import "iPadHelper.h"
#import "StationInfo.h"
#import "StationDetailMeteoViewController.h"

@implementation StationInfoViewController

@synthesize stations;

#pragma mark -
#pragma mark View lifecycle

- (void)viewDidLoad {
    [super viewDidLoad];
	
    // Uncomment the following line to preserve selection between presentations.
    //self.clearsSelectionOnViewWillAppear = NO;
	
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
	
	[self refreshContent:self];
}

/*
- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
}
*/
/*
- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
}
*/
/*
- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
}
*/
/*
- (void)viewDidDisappear:(BOOL)animated {
    [super viewDidDisappear:animated];
}
*/
// Override to allow orientations other than the default portrait orientation.
- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
    // Return YES for supported orientations
    //return (interfaceOrientation == UIInterfaceOrientationPortrait);
	return YES;
}

- (CGSize)contentSizeForViewInPopoverView {
    return CGSizeMake(320.0, 280.0);
}


#pragma mark -
#pragma mark Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    // Return the number of sections.
    return 1;
}


- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    // Return the number of rows in the section.
	if (stations != nil) {
		return [stations count];
	}
    return 0;
}


// Customize the appearance of table view cells.
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    static NSString *CellIdentifier = @"StationInfoCell";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:CellIdentifier] autorelease];
    }
    
	StationInfo *data = [stations objectAtIndex:indexPath.row];

    // Configure the cell...
	if(data != nil){
		if([iPadHelper isIpad]){
			cell.accessoryType = UITableViewCellAccessoryNone;
		} else {
			cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
		}
		cell.textLabel.text = [data objectForKey:@"@shortName"];
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
	if(stations != nil && [stations count]>0){
		
		if([iPadHelper isIpad]){
			// For iPad, detail view is loaded from map annotation only
		} else {
			// For iPhone, create one to push
			StationDetailMeteoViewController *meteoVC = nil;
			StationInfo* stationInfo = [stations objectAtIndex:indexPath.row];
			meteoVC = [[StationDetailMeteoViewController alloc] initWithNibName:@"StationDetailMeteoViewController" bundle:nil];
			[meteoVC setStationInfo:stationInfo];
			// push controller
			[self.navigationController pushViewController:meteoVC animated:YES];
			[meteoVC release];
		}
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
	[client release];
	[stations release];
    [super dealloc];
}

#pragma mark -
#pragma mark Station methods

- (void)refreshContent:(id)sender {
	[self startRefreshAnimation];
	if(client == nil){
		client = [[WMReSTClient alloc] init ];
	}
	
	// (re-)load content
	[client asyncGetStationList:self];
}

- (void)stationList:(NSArray*)aStationArray{
	[self stopRefreshAnimation];

	self.stations = aStationArray;
	
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

