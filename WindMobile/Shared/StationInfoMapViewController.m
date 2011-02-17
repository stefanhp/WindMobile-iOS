//
//  StationInfoMapViewController.m
//  WindMobile
//
//  Created by Stefan Hochuli Paychère on 10.02.11.
//  Copyright 2011 Pistache Software. All rights reserved.
//

#import "StationInfoMapViewController.h"
#import "MapViewController.h"
#import "iPadHelper.h"
#import "StationDetailMeteoViewController.h"

@implementation StationInfoMapViewController
@synthesize toolBar;
@synthesize stations;
@synthesize visibleStations;
@synthesize mainView;
@synthesize mapView;

// The designated initializer.  Override if you create the controller programmatically and want to perform customization that is not appropriate for viewDidLoad.
/*
- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization.
    }
    return self;
}
*/

// Implement viewDidLoad to do additional setup after loading the view, typically from a nib.
- (void)viewDidLoad {
    [super viewDidLoad];
	
	// Map
	map = [[[MapViewController alloc] initWithNibName:@"MapViewController" bundle:nil] retain];
	[self.mapView addSubview:map.view];
	
	// toolbar buttons
	titleItem = [[UIBarButtonItem alloc]initWithTitle:NSLocalizedStringFromTable(@"STATIONS", @"WindMobile", nil)
												style:UIBarButtonItemStylePlain 
											   target:self
											   action:@selector(titleAction:)];

	flexItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace
															 target:nil
															 action:nil];
	
	refreshItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemRefresh
																target:self 
																action:@selector(refreshContent:)];
	
	UIActivityIndicatorView *activityIndicator = [[UIActivityIndicatorView alloc] initWithFrame:CGRectMake(0, 0, 20, 20)];
	[activityIndicator startAnimating];
	activityItem = [[UIBarButtonItem alloc] initWithCustomView:activityIndicator];
	[activityIndicator release];
	
	NSArray *items = [NSArray arrayWithObjects:flexItem, titleItem, flexItem, refreshItem, nil];	
	[self.toolBar setItems:items animated:NO];
	//[self.mainView addSubview:self.toolBar];

	// load content
	[self refreshContent:self];
}

// Override to allow orientations other than the default portrait orientation.
- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
    // Return YES for supported orientations.
    return YES;
}

- (void)didReceiveMemoryWarning {
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Release any cached data, images, etc. that aren't in use.
}

- (void)viewDidUnload {
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}


- (void)dealloc {
	[map release];
	
    [super dealloc];
}

#pragma mark -
#pragma mark Title Action 

- (void)titleAction:(id)sender{
	// Show station list
	StationListViewController *showStations = [[StationListViewController alloc] initWithNibName:@"StationListViewController" bundle:nil];
	showStations.stations = self.stations;
	showStations.selectedStations = self.visibleStations;
	showStations.delegate = self;
	showStations.showDoneButton = YES;

	// show in modal sheet
	UINavigationController *aNavController = [[UINavigationController alloc] initWithRootViewController:showStations];

	[aNavController setModalPresentationStyle:UIModalPresentationFormSheet];
	[self presentModalViewController:aNavController animated:YES];
}

#pragma mark -
#pragma mark StationListDelegate protocol 

- (void)didRemoveItem:(StationInfo*)item{
	[map removeAnnotation:item];
}

- (void)didRemoveItems:(NSArray*)items{
	[map removeAnnotations:items];
}

- (void)didAddItem:(StationInfo*)item{
	[map addAnnotation:item];
}

- (void)didAddItems:(NSArray*)items{
	[map addAnnotations:items];
}

- (void)dismissStationListModal:(id)sender{
	[self dismissModalViewControllerAnimated:YES];
}

#pragma mark -
#pragma mark Station methods

- (void)refreshContent:(id)sender {
	[self startRefreshAnimation];
	if(client == nil){
		client = [[[WMReSTClient alloc] init ]retain];
	}
	
	// (re-)load content
	[client asyncGetStationList:self];
}

- (void)stationList:(NSArray*)aStationArray{
	[self stopRefreshAnimation];
	
	[map removeAnnotations:self.visibleStations];
	map.mapView.delegate = self;

	
	self.stations = aStationArray;
	self.visibleStations = [NSMutableArray arrayWithArray:aStationArray];
	
	[map addAnnotations:self.visibleStations];

	// refresh display
}

- (void)requestError:(NSString*) message details:(NSMutableDictionary *)error{
	[self stopRefreshAnimation];
}

- (void)startRefreshAnimation{
	NSRange range;
	range.location = 0;
	range.length = [self.toolBar.items count] -1;
	NSArray *items = [self.toolBar.items subarrayWithRange:range];
	
	[self.toolBar setItems:[items arrayByAddingObject:activityItem] animated:NO];

	[(UIActivityIndicatorView *)activityItem.customView startAnimating];
}

- (void)stopRefreshAnimation{
	NSRange range;
	range.location = 0;
	range.length = [self.toolBar.items count] -1;
	NSArray *items = [self.toolBar.items subarrayWithRange:range];
	
	[self.toolBar setItems:[items arrayByAddingObject:refreshItem] animated:NO];
}

#pragma mark -
#pragma mark MKMapViewDelegate

- (MKAnnotationView *)mapView:(MKMapView *)theMapView viewForAnnotation:(id <MKAnnotation>)annotation{
	static NSString* stationAnnotationIdentifier = @"stationAnnotationIdentifier";
	MKPinAnnotationView* pinView = (MKPinAnnotationView *)
	[map.mapView dequeueReusableAnnotationViewWithIdentifier:stationAnnotationIdentifier];
	if (!pinView)
	{
		// if an existing pin view was not available, create one
		MKPinAnnotationView* customPinView = [[[MKPinAnnotationView alloc]
											   initWithAnnotation:annotation reuseIdentifier:stationAnnotationIdentifier] autorelease];
		//customPinView.pinColor = MKPinAnnotationColorPurple;
		customPinView.animatesDrop = YES;
		customPinView.canShowCallout = YES;
		
		// add a detail disclosure button to the callout which will open a new view controller page
		//
		// note: you can assign a specific call out accessory view, or as MKMapViewDelegate you can implement:
		//  - (void)mapView:(MKMapView *)mapView annotationView:(MKAnnotationView *)view calloutAccessoryControlTapped:(UIControl *)control;
		//
		UIButton* rightButton = [UIButton buttonWithType:UIButtonTypeDetailDisclosure];
		[rightButton addTarget:self
						action:@selector(showStationDetail:)
			  forControlEvents:UIControlEventTouchUpInside];
		customPinView.rightCalloutAccessoryView = rightButton;
		
		return customPinView;
	}
	else
	{
		pinView.annotation = annotation;
	}
	return pinView;
	
}

- (void)showStationDetail:(id)sender{
	StationDetailMeteoViewController *meteo = [[StationDetailMeteoViewController alloc]initWithNibName:@"StationDetailMeteoViewController" bundle:nil];
	NSArray *annotations = map.mapView.selectedAnnotations;
	//meteo.stationInfo = self.stationIn
	id <MKAnnotation> annotation;
	if(annotations != nil && [annotations count] == 1){
		StationInfo *info = [annotations objectAtIndex:0];
		annotation = [annotations objectAtIndex:0];
		meteo.stationInfo = info;
	}

	UINavigationController *nav = [[UINavigationController alloc] initWithRootViewController:meteo];

	if([iPadHelper isIpad]){
		// show in popover
		if(annotation != nil){
			// deselect annotation
			[map.mapView deselectAnnotation:annotation animated:YES];
			
			// find location
			CGPoint point = [map.mapView convertCoordinate:annotation.coordinate toPointToView:self.view];
			
			UIPopoverController * pop = [[UIPopoverController alloc] initWithContentViewController:nav];
			[pop presentPopoverFromRect:CGRectMake(point.x + 6.5, point.y - 27.0, 1.0, 1.0) 
								 inView:self.view 
			   permittedArrowDirections:UIPopoverArrowDirectionAny 
							   animated:YES];
		}
		
	} else {
		// Show in modal view
		//[meteo setModalPresentationStyle:UIModalPresentationFormSheet];
		[self presentModalViewController:nav animated:YES];
	}
}

@end
