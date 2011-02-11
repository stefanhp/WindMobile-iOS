//
//  StationListViewController.h
//  WindMobile
//
//  Created by Stefan Hochuli Paychère on 11.02.11.
//  Copyright 2011 Pistache Software. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "StationInfo.h"

@protocol StationListDelegate
@optional
- (void)willAddItem:(StationInfo*)item;
- (void)didAddItem:(StationInfo*)item;
- (void)willRemoveItem:(StationInfo*)item;
- (void)didRemoveItem:(StationInfo*)item;

- (void)willAddItems:(NSArray*)items;
- (void)didAddItems:(NSArray*)items;
- (void)willRemoveItems:(NSArray*)items;
- (void)didRemoveItems:(NSArray*)items;

- (void)dismissStationListModal:(id)sender;
@end

@interface StationListViewController : UITableViewController {
	NSArray *stations;
	NSMutableArray *selectedStations;
	
	id <StationListDelegate> delegate;
	BOOL showDoneButton;
}
@property (nonatomic, assign) IBOutlet id delegate;
@property (nonatomic, retain) NSArray *stations;
@property (nonatomic, retain) NSMutableArray *selectedStations;
@property (nonatomic, assign) BOOL showDoneButton;

- (void)selectAllOrNone:(id)sender;
- (IBAction)dismiss:(id)sender;
@end
