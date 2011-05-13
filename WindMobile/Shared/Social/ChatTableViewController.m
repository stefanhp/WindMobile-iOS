//
//  TableViewController.m
//  
//
//  Created by David on 5/11/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "ChatTableViewController.h"
#import "StationItem.h"

@implementation ChatTableViewController

@synthesize stationList;
@synthesize chatViewController;
@synthesize stationViewDatasource;
@synthesize refreshing;

-(void)viewDidLoad
{
    [super viewDidLoad];
    
    self.title = NSLocalizedStringFromTable(@"CHAT_TABLE_TITLE", @"WindMobile", nil);
    // Put Refresh button on the top left
    [self refreshContent:self];
}


-(void)refreshContent:(id)sender
{
    if ( self.refreshing ) {
        return;
    }
    self.refreshing = true;
    [self startRefreshAnimation];
    dispatch_async( dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        // backgroun process
        NSString *error = nil;
        @try{
            self.stationList = [NSArray arrayWithArray:[stationViewDatasource getStationList]];
        }
        @catch (NSException *ex) {
            error = [ex reason];
        }
        @finally {
            self.refreshing = false;
        }
        
        dispatch_async( dispatch_get_main_queue(), ^{
            // Add code here to update the UI/send notifications based on the
            // results of the background processing
            [self stopRefreshAnimation];
            if ( error ) {
                UIAlertView *openURLAlert = [[UIAlertView alloc] initWithTitle:@"Server error" message:error delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
                [openURLAlert show];
                [openURLAlert release];
            }
            [self.tableView reloadData];
        });
    });

    
    [self.tableView reloadData];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [self.stationList count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"Cell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if ( cell == nil ) {
        cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier] autorelease];
    }
    cell.textLabel.text = ((StationItem*)[self.stationList objectAtIndex:[indexPath row]]).displayName;
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [self.navigationController pushViewController:chatViewController animated:YES];
    NSString *stationId = ((StationItem*)[self.stationList objectAtIndex:[indexPath row]]).identifier;
    NSString *stationName = ((StationItem*)[self.stationList objectAtIndex:[indexPath row]]).displayName;

    chatViewController.chatRoomId = stationId;
    NSString *format = NSLocalizedStringFromTable(@"CHAT_STATION_TITLE", @"WindMobile", nil);
    
    chatViewController.title = [NSString stringWithFormat:format,stationName];
}

-(void)dealloc
{
    [stationList release];
    [chatViewController release];
    [stationViewDatasource release];
    [super dealloc];
}

- (void)startRefreshAnimation
{
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

- (void)stopRefreshAnimation
{
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
