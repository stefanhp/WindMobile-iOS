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
#import "DetailViewController.h"

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
    
    static NSString *CellIdentifier = @"Cell";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:CellIdentifier] autorelease];
    }
    
	NSDictionary* data = [stations objectAtIndex:indexPath.row];

    // Configure the cell...
	if(data != nil){
		//cell.accessoryType = UITableViewCellAccessoryNone; // tmp until subview is ready
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
		StationDetailViewController *detailVC = nil;
		NSDictionary* data = [stations objectAtIndex:indexPath.row];
		NSString *idString = [data objectForKey:@"@id"];
		NSString *name = [data objectForKey:@"@shortName"];
		NSString *altitude = [data objectForKey:@"@altitude"];
		NSString *wgs84Latitude = [data objectForKey:@"@wgs84Latitude"];
		NSString *wgs84Longitude = [data objectForKey:@"@wgs84Longitude"];
		
		if([iPadHelper isIpad]){
			// For iPad, get detail view form split view
#if __IPHONE_OS_VERSION_MAX_ALLOWED > __IPHONE_3_1
			DetailViewController* splitDetailVC = (DetailViewController*)[self.splitViewController.viewControllers objectAtIndex:1];
			detailVC = [splitDetailVC stationDetailVC];
			splitDetailVC.navigationBar.topItem.title = [data objectForKey:@"@shortName"];
			[splitDetailVC dismissPopover:self];
#endif
		} else {
			// For iPhone, create one to push
			detailVC = [[StationDetailViewController alloc] initWithNibName:@"StationDetailViewController" bundle:nil];
		}	
		
		if(idString != nil){
			[detailVC setStationID:idString];
			if(name != nil){
				[detailVC setStationName:name];
			}
			if(altitude != nil){
				[detailVC setAltitude:altitude];
			}
			if(wgs84Latitude != nil && wgs84Longitude != nil){
				CLLocationCoordinate2D theCoordinate;
				theCoordinate.latitude = [wgs84Latitude doubleValue];
				theCoordinate.longitude = [wgs84Longitude doubleValue];
				[detailVC setCoordinate:theCoordinate];
			}
			
		}
		
		if([iPadHelper isIpad]){
			[detailVC refreshContent:self];
		} else {
			// push controller
			[self.navigationController pushViewController:detailVC animated:YES];
			[detailVC release];
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
    [super dealloc];
	[stations release];
}

#pragma mark -
#pragma mark Station methods

- (void)refreshContent:(id)sender {
	// Remove refresh button
	self.navigationItem.rightBarButtonItem = nil;

	// activity indicator
	UIActivityIndicatorView *activityIndicator = [[UIActivityIndicatorView alloc] initWithFrame:CGRectMake(0, 0, 20, 20)];
	[activityIndicator startAnimating];
	UIBarButtonItem *activityItem = [[UIBarButtonItem alloc] initWithCustomView:activityIndicator];
	[activityIndicator release];
	self.navigationItem.rightBarButtonItem = activityItem;
	
	if(client == nil){
		client = [[[WMReSTClient alloc] init ]retain];
	}
	
	// (re-)load content
	[client asyncGetStationList:self];
}

- (void)stationList:(NSArray*)aStationArray{
	self.stations = aStationArray;
	
	//NSLog(@"Stations: %@", aStationArray);

	// Stop animation
	self.navigationItem.rightBarButtonItem = nil;
	
	// Put Refresh button on the top left
	//if([iPadHelper isIpad]){} else {
	UIBarButtonItem *refreshItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemRefresh
																				 target:self 
																				 action:@selector(refreshContent:)];
	self.navigationItem.rightBarButtonItem = refreshItem;
	//}
	
	
	// refresh table
	[self.tableView reloadData];
}

@end

