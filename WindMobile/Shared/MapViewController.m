//
//  MapViewController.m
//  WindMobile
//
//  Created by Stefan Hochuli Paychère on 22.05.10.
//  Copyright 2010 Pistache Software. All rights reserved.
//

#import "MapViewController.h"


@implementation MapViewController

@synthesize mapView;
@synthesize region;
@synthesize coordinate;
@synthesize subtitle;

/*
 // The designated initializer.  Override if you create the controller programmatically and want to perform customization that is not appropriate for viewDidLoad.
- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    if ((self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil])) {
        // Custom initialization
    }
    return self;
}
*/


// Implement viewDidLoad to do additional setup after loading the view, typically from a nib.
- (void)viewDidLoad {
    [super viewDidLoad];
	
	self.mapView.mapType = MKMapTypeStandard;   // also MKMapTypeSatellite or MKMapTypeHybrid

	// display view
	[self.mapView setRegion:self.region animated:YES];
	[self.mapView addAnnotation:self];
	
	UIBarButtonItem *flexItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace
																			  target:nil
																			  action:nil];

	UIBarButtonItem *showInMapButton = [[UIBarButtonItem alloc]initWithTitle:NSLocalizedStringFromTable(@"COORDINATE_SHOW_IN_MAPS", @"WindMobile", nil)
																	   style:UIBarButtonItemStyleBordered //  UIBarButtonItemStyleDone
																	  target:self
																	  action:@selector(showInMaps:)];
	
	[self setToolbarItems:[NSArray arrayWithObjects:flexItem, showInMapButton, nil]];

}

- (void)viewDidAppear:(BOOL)animated
{
    // bring back the toolbar
    [self.navigationController setToolbarHidden:NO animated:NO];
}

/*
// Override to allow orientations other than the default portrait orientation.
- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
    // Return YES for supported orientations
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}
*/

- (void)didReceiveMemoryWarning {
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Release any cached data, images, etc that aren't in use.
}

- (void)viewDidUnload {
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}


- (void)dealloc {
	[mapView release];

    [super dealloc];
}

- (IBAction)showInMaps:(id)sender{
	NSString *latlong = [[NSString stringWithFormat:@"%f,%f", self.coordinate.latitude, self.coordinate.longitude]
						 stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
	NSString *label = [[[self.title stringByAppendingString:@" "] 
						stringByAppendingString:self.subtitle]
					   stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
	
	NSString *url = [NSString stringWithFormat: @"http://maps.google.com/maps?ll=%@&q=%@(%@)&spn=0.096379,0.173893&t=h",
					 latlong, latlong, label];
	
	[[UIApplication sharedApplication] openURL:[NSURL URLWithString:url]];
}


@end
