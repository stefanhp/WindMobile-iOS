//
//  MapViewController.m
//  WindMobile
//
//  Created by Stefan Hochuli Paychère on 22.05.10.
//  Copyright 2010 Pistache Software. All rights reserved.
//

#import <CoreLocation/CoreLocation.h>
#import "MapViewController.h"
#import "MKMapView+ZoomLevel.h"
#import "iPadHelper.h"

#define SWISS_CENTER_LAT 46.687131
#define SWISS_CENTER_LON 8.140869

#define SWISS_SPAN_LAT 2.000000
#define SWISS_SPAN_LON 3.500000

#define POINT_SPAN_LAT 0.096379
#define POINT_SPAN_LON 0.173893

#define MAP_TYPE_KEY @"map_type_preference"

@implementation MapViewController

@synthesize mapView;

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
	
	self.mapView.mapType =[[NSUserDefaults standardUserDefaults]doubleForKey:MAP_TYPE_KEY]; // MKMapTypeStandard, MKMapTypeSatellite or MKMapTypeHybrid
	
	// Center on CH by default
	MKCoordinateRegion newRegion;
	newRegion.center.latitude = SWISS_CENTER_LAT;
	newRegion.center.longitude = SWISS_CENTER_LON;
	newRegion.span.latitudeDelta = SWISS_SPAN_LAT;
	newRegion.span.longitudeDelta = SWISS_SPAN_LON;
	[self.mapView setRegion:newRegion animated:YES];
	
	// show current location
	self.mapView.showsUserLocation = YES;
	

	// Show in Map button
	UIBarButtonItem *showInMapButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemAction
																				 target:self 
																				 action:@selector(showInMaps:)];
	self.navigationItem.rightBarButtonItem = showInMapButton;
}

- (void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
	// in case the user changed the settings
	self.mapView.mapType =[[NSUserDefaults standardUserDefaults]doubleForKey:MAP_TYPE_KEY];
}

// Override to allow orientations other than the default portrait orientation.
- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
    // Return YES for supported orientations
    //return (interfaceOrientation == UIInterfaceOrientationPortrait);
	return YES;
}

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

- (void)addAnnotation:(id <MKAnnotation>)annotation{
	[self.mapView addAnnotation:annotation];

	[self centerWithHint:annotation.coordinate];
	/*
	// set center and region 
	MKCoordinateRegion newRegion;
	if([self.mapView.annotations count] > 1){
		newRegion.center.latitude = SWISS_CENTER_LAT;
		newRegion.center.longitude = SWISS_CENTER_LON;
		newRegion.span.latitudeDelta = SWISS_SPAN_LAT;
		newRegion.span.longitudeDelta = SWISS_SPAN_LON;
	} else {
		newRegion.center.latitude = annotation.coordinate.latitude;
		newRegion.center.longitude = annotation.coordinate.longitude;
		newRegion.span.latitudeDelta = POINT_SPAN_LAT;
		newRegion.span.longitudeDelta = POINT_SPAN_LON;
	}
	[self.mapView setRegion:newRegion animated:YES];
	 */
}

- (void)addAnnotations:(NSArray *)annotations{
	[self.mapView addAnnotations:annotations];
	
	if(self.mapView.showsUserLocation && ![self.mapView.userLocation isUpdating]){
		[self centerWithHint:self.mapView.userLocation.location.coordinate];
	} else {
		id <MKAnnotation> annotation = (id <MKAnnotation>)[annotations objectAtIndex:0];
		[self centerWithHint:annotation.coordinate];
	}
	//NSArray *tmp = self.mapView.annotations;
}

- (void)removeAnnotation:(id <MKAnnotation>)annotation{
	[self.mapView removeAnnotation:annotation];
}

- (void)removeAnnotations:(NSArray *)annotations{
	[self.mapView removeAnnotations:annotations];
}

- (void)centerWithHint:(CLLocationCoordinate2D) coordinate{
	int delta = 1;
	if (self.mapView.showsUserLocation) {
		delta = 2;
	}

	int zoomLevel = 6;
	if([iPadHelper isIpad]){
		zoomLevel = 7;
	}

	if([self.mapView.annotations count] > delta){ // many points
		[self.mapView setCenterCoordinate:coordinate	
								zoomLevel:zoomLevel
								 animated:YES];
	} else { // single point (ignoring current user location
		[self.mapView setCenterCoordinate:coordinate	
								zoomLevel:10
								 animated:YES];
	}


}

- (IBAction)showInMaps:(id)sender{
	UIActionSheet *actionSheet = [[UIActionSheet alloc] initWithTitle:nil
															 delegate:self 
													cancelButtonTitle:NSLocalizedStringFromTable(@"CANCEL", @"WindMobile", nil)
											   destructiveButtonTitle:nil 
													otherButtonTitles:NSLocalizedStringFromTable(@"SHOW_IN_MAPS", @"WindMobile", nil), nil];
	actionSheet.actionSheetStyle = UIActionSheetStyleDefault;
	[actionSheet showFromTabBar:self.tabBarController.tabBar];
	[actionSheet release];
	
}

#pragma mark -
#pragma mark - UIActionSheetDelegate

- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex {
	// the user clicked one of the OK/Cancel buttons
	if (buttonIndex == 0) {
		NSArray* annotations = self.mapView.annotations;
		id<MKAnnotation> info = [annotations objectAtIndex:0];
		NSString *latlong = [[NSString stringWithFormat:@"%f,%f", info.coordinate.latitude, info.coordinate.longitude]
							 stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
		NSString *label = [[[info.title stringByAppendingString:@" "] 
							stringByAppendingString:info.subtitle]
						   stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
		
		NSString *url = [NSString stringWithFormat: @"http://maps.google.com/maps?ll=%@&q=%@(%@)&spn=0.096379,0.173893&t=h",
						 latlong, latlong, label];
		
		[[UIApplication sharedApplication] openURL:[NSURL URLWithString:url]];
	} 
}


@end
