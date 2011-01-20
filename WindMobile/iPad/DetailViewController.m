//
//  DetailViewController.m
//  WindMobile
//
//  Created by Stefan Hochuli Paychère on 22.05.10.
//  Copyright 2010 Pistache Software. All rights reserved.
//

#import "DetailViewController.h"
#import "StationDetailViewController.h"
#import "MapViewController.h"

#if __IPHONE_OS_VERSION_MAX_ALLOWED > __IPHONE_3_1

@interface DetailViewController ()
@property (nonatomic, retain) UIPopoverController *popoverController;
@end



@implementation DetailViewController

@synthesize navigationBar;
@synthesize popoverController;

@dynamic stationDetailVC;
- (StationDetailViewController*)stationDetailVC{
	static StationDetailViewController *stationDetailVC = nil;
	if(stationDetailVC == nil){
		stationDetailVC = [[StationDetailViewController alloc] initWithNibName:@"StationDetailViewController" bundle:nil];
		[self.view addSubview:stationDetailVC.view];
		// resize
		CGRect mainViewBounds = self.view.bounds;
		[stationDetailVC.view setFrame:CGRectMake(CGRectGetMinX(mainViewBounds),
												  CGRectGetMinY(mainViewBounds) + CGRectGetHeight(self.navigationBar.bounds), 
												  CGRectGetWidth(mainViewBounds), 
												  CGRectGetHeight(mainViewBounds) - CGRectGetHeight(self.navigationBar.bounds))];
		
	}
	return stationDetailVC;
}

#pragma mark -
#pragma mark Managing the detail item

/*
 When setting the detail item, update the view and dismiss the popover controller if it's showing.
 */
- (void)dismissPopover:(id)sender {
    if (popoverController != nil) {
        [popoverController dismissPopoverAnimated:YES];
    }        
}


#pragma mark -
#pragma mark Split view support

- (void)splitViewController: (UISplitViewController*)svc willHideViewController:(UIViewController *)aViewController withBarButtonItem:(UIBarButtonItem*)barButtonItem forPopoverController: (UIPopoverController*)pc {
    
    barButtonItem.title = NSLocalizedStringFromTable(@"STATIONS", @"WindMobile", nil);
    [navigationBar.topItem setLeftBarButtonItem:barButtonItem animated:YES];
    self.popoverController = pc;
}


// Called when the view is shown again in the split view, invalidating the button and popover controller.
- (void)splitViewController: (UISplitViewController*)svc willShowViewController:(UIViewController *)aViewController invalidatingBarButtonItem:(UIBarButtonItem *)barButtonItem {
    
    [navigationBar.topItem setLeftBarButtonItem:nil animated:YES];
    self.popoverController = nil;
}


#pragma mark -
#pragma mark Rotation support

// Ensure that the view controller supports rotation and that the split view can therefore show in both portrait and landscape.
- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
    return YES;
}


#pragma mark -
#pragma mark View lifecycle

/*
 // Implement viewDidLoad to do additional setup after loading the view, typically from a nib.
- (void)viewDidLoad {
    [super viewDidLoad];
}
 */

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

- (void)viewDidUnload {
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
    self.popoverController = nil;
}


#pragma mark -
#pragma mark Memory management

/*
- (void)didReceiveMemoryWarning {
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Release any cached data, images, etc that aren't in use.
}
*/

- (void)dealloc {
    [popoverController release];
    [navigationBar release];
    
    [super dealloc];
}

@end

#endif
