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

-(void)viewDidLoad
{
    [super viewDidLoad];
    self.title = @"Chats";
    // Put Refresh button on the top left
	UIBarButtonItem *refreshItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemRefresh
																				 target:self 
																				 action:@selector(refresh:)];
	self.navigationItem.rightBarButtonItem = refreshItem;
	[refreshItem release];

    [self refresh:self];
}


-(void)refresh:(id)sender
{
    self.stationList = [NSArray arrayWithArray:[stationViewDatasource getStationList]];
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
    chatViewController.title = [NSString stringWithFormat:@"Chat @ %@",stationName];
    [chatViewController refreshChat];
}

-(void)dealloc
{
    [stationList release];
    [super dealloc];
}

@end
