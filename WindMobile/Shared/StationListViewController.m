//
//  StationListViewController.m
//  WindMobile
//
//  Created by Stefan Hochuli Paychère on 11.02.11.
//  Copyright 2011 Pistache Software. All rights reserved.
//

#import "StationListViewController.h"

#define SECTION_MULTI_SELECT 0
#define MULTI_SELECT_BUTTON_INDEX 0

#define SECTION_LIST 1


@implementation StationListViewController
@synthesize delegate;
@synthesize showDoneButton;

#pragma mark -
#pragma mark View lifecycle

- (void)viewDidLoad {
    [super viewDidLoad];

    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;

	self.title = NSLocalizedStringFromTable(@"SHOW_STATIONS", @"WindMobile", nil);
}

- (void)viewWillAppear:(BOOL)animated {
	self.navigationItem.rightBarButtonItem = nil;
	//self.navigationController.delegate = self;
	if (self.showDoneButton) {
		UIBarButtonItem *buttonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemDone 
																					target:self 
																					action:@selector(dismiss:)];
		self.navigationItem.rightBarButtonItem = buttonItem;
		[buttonItem release];
	} 
	[super viewWillAppear:animated];
}

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
/*
// Override to allow orientations other than the default portrait orientation.
- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
    // Return YES for supported orientations.
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}
*/


#pragma mark -
#pragma mark Table view data source
@synthesize stations;
@synthesize selectedStations;

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    // Return the number of sections.
    return SECTION_LIST +1;
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
    // The header for the section is the region name -- get this from the region at the section index.
	switch (section) {
		case SECTION_LIST:
			return NSLocalizedStringFromTable(@"STATIONS", @"WindMobile", nil);
			break;
		default:
			break;
	}
    return nil;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    // Return the number of rows in the section.
	switch (section) {
		case SECTION_MULTI_SELECT:
			return MULTI_SELECT_BUTTON_INDEX+1;
			break;
		case SECTION_LIST:
			if(stations != nil){
				return [stations count];
			}
			return 0;
		default:
			break;
	}
    return 2;
}


// Customize the appearance of table view cells.
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    static NSString *CellIdentifier = @"StationListCell";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:CellIdentifier] autorelease];
    }
    
	StationInfo* data;
	
    // Configure the cell...
	switch (indexPath.section) {
		case SECTION_MULTI_SELECT:
			if(stations != nil && selectedStations != nil && [stations count] == [selectedStations count]){
				cell.textLabel.text = NSLocalizedStringFromTable(@"SHOW_STATIONS_NONE", @"WindMobile", nil);
			} else {
				cell.textLabel.text = NSLocalizedStringFromTable(@"SHOW_STATIONS_ALL", @"WindMobile", nil);
			}
			cell.textLabel.textAlignment = UITextAlignmentCenter;
			break;
		case SECTION_LIST:
			data = [stations objectAtIndex:indexPath.row];
			if(data != nil){
				//cell.accessoryType = UITableViewCellAccessoryNone; // tmp until subview is ready
				if(selectedStations != nil && [selectedStations containsObject:data] ){
					cell.accessoryType = UITableViewCellAccessoryCheckmark;
				} else {
					cell.accessoryType = UITableViewCellAccessoryNone;
				}
				cell.textLabel.text = [data objectForKey:@"@shortName"];
				cell.detailTextLabel.text = [NSString stringWithFormat:NSLocalizedStringWithDefaultValue(@"ALTITUDE_FORMAT", 
																										 @"WindMobile", 
																										 [NSBundle mainBundle], 
																										 @"Altitude %@m", 
																										 @"Altitude format string"),
											 [data objectForKey:@"@altitude"]];
			}
			cell.textLabel.textAlignment = UITextAlignmentLeft;
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
        // Delete the row from the data source.
        [tableView deleteRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:UITableViewRowAnimationFade];
    }   
    else if (editingStyle == UITableViewCellEditingStyleInsert) {
        // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view.
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
	StationInfo* data;

	switch (indexPath.section) {
		case SECTION_MULTI_SELECT:
			switch (indexPath.row) {
				case MULTI_SELECT_BUTTON_INDEX:
					[self selectAllOrNone:self];
					break;
				default:
					break;
			}
			break;
		case SECTION_LIST:
			data = [stations objectAtIndex:indexPath.row];
			if([selectedStations containsObject:data]){
				// remove it
				if([self.delegate respondsToSelector:@selector(willRemoveItem:)]){
					[delegate willRemoveItem:data];
				}
				[self.selectedStations removeObject:data];
				if([self.delegate respondsToSelector:@selector(didRemoveItem:)]){
					[delegate didRemoveItem:data];
				}
			} else {
				// add it
				if([self.delegate respondsToSelector:@selector(willAddItem:)]){
					[delegate willAddItem:data];
				}
				[self.selectedStations addObject:data];
				if([self.delegate respondsToSelector:@selector(didAddItem:)]){
					[delegate didAddItem:data];
				}
			}
			[self.tableView reloadData];
			break;
		default:
			break;
	}
}

-(void)selectAllOrNone:(id)sender{
	if(stations == nil || selectedStations == nil){
		return;
	}
	if([stations count] == [selectedStations count]){
		// currently all selected: deselect all
		if([self.delegate respondsToSelector:@selector(willRemoveItems:)]){
			[delegate willRemoveItems:self.selectedStations];
		}
		NSArray *removedItems = [NSArray arrayWithArray:self.selectedStations];
		
		[self.selectedStations removeAllObjects];
		
		if([self.delegate respondsToSelector:@selector(didRemoveItems:)]){
			[delegate didRemoveItems:removedItems];
		}
	} else {
		// not all seleted: select all
		
		// gather list of objects to add
		NSMutableArray *tmp = [NSMutableArray arrayWithCapacity:[self.stations count]];
		for (StationInfo* data in self.stations) {
			if([selectedStations containsObject:data] == NO){
				[tmp addObject:data];
			}
		}
		
		// add them
		if([self.delegate respondsToSelector:@selector(willAddItems:)]){
			[delegate willAddItems:tmp];
		}
		[self.selectedStations addObjectsFromArray:tmp];
		if([self.delegate respondsToSelector:@selector(didAddItems:)]){
			[delegate didAddItems:tmp];
		}
	}
	[self.tableView reloadData];
}

- (IBAction)dismiss:(id)sender{
	if([self.delegate respondsToSelector:@selector(dismissStationListModal:)]){
		[delegate dismissStationListModal:self];
	}
}

#pragma mark -
#pragma mark Memory management

- (void)didReceiveMemoryWarning {
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Relinquish ownership any cached data, images, etc. that aren't in use.
}

- (void)viewDidUnload {
    // Relinquish ownership of anything that can be recreated in viewDidLoad or on demand.
    // For example: self.myOutlet = nil;
}


- (void)dealloc {
	[stations release];
	[selectedStations release];
    [super dealloc];
}


@end

