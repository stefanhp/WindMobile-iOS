//
//  StationInfoMapViewController.m
//  WindMobile
//
//  Created by Stefan Hochuli Paychère on 10.02.11.
//  Copyright 2011 Pistache Software. All rights reserved.
//

#import <Math.h>
#import "IASKSettingsReader.h"

#import "StationInfoMapViewController.h"
#import "MKMapView+ZoomLevel.h"
#import "iPadHelper.h"
#import "StationDetailMeteoViewController.h"
#import "AppDelegate_Phone.h"

@interface StationInfoMapViewController (private)
- (void)addAnnotations:(NSArray *)annotations;
- (void)centerAroundStation:(StationInfo *)station;
- (void)startRefreshAnimation;
- (void)stopRefreshAnimation;
- (void)refresh;
- (void)showStationDetail:(id)sender;
- (void)settingsChanged:(NSNotification* )notif;
@end

@implementation StationInfoMapViewController

@synthesize mapView;

#pragma mark -
#pragma mark UIViewController

- (void)viewDidLoad {
    [super viewDidLoad];
	
    self.mapView.mapType =[[NSUserDefaults standardUserDefaults]integerForKey:MAP_TYPE_KEY];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(settingsChanged:) name:kIASKAppSettingChanged object:nil];
    
    self.mapView.delegate = self;
    [self refresh];
}

- (void)viewDidUnload {
    [[NSNotificationCenter defaultCenter] removeObserver:self name:kIASKAppSettingChanged object:nil];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
	return YES;
}

#pragma mark -
#pragma mark Public methods

- (StationInfo *)getSelectedStation {
    return selectedStation;
}

- (void)selectStation:(StationInfo *)station {
    if (selectedStation != station) {
        [selectedStation release];
        selectedStation = [station retain];
    }
    if (station != nil) {
        self.mapView.selectedAnnotations = [NSArray arrayWithObject:station];
        [self centerAroundStation:selectedStation];
    }
}

- (void)refreshAction:(id)sender {
    [self selectStation:nil];
    [self refresh];
}

- (void)centerAroundAnnotations:(NSArray *)annotations
{
    // if we have no annotations we can skip all of this
    if ( [annotations count] == 0 )
        return;
	
    // then run through each annotation in the list to find the
    // minimum and maximum latitude and longitude values
    CLLocationCoordinate2D min;
    CLLocationCoordinate2D max; 
    BOOL minMaxInitialized = NO;
    NSUInteger numberOfValidAnnotations = 0;
	
    for ( id<MKAnnotation> a in annotations )
    {
        // only use annotations that are of our own custom type
        // in the event that the user is browsing from a location far away
        // you can omit this if you want the user's location to be included in the region 
        if ( [a isKindOfClass: [StationInfo class]] )
        {
			// if we haven't grabbed the first good value, do so now
			if ( !minMaxInitialized )
			{
				min = a.coordinate;
				max = a.coordinate;
				minMaxInitialized = YES;
			}
			else // otherwise compare with the current value
			{
				min.latitude = MIN( min.latitude, a.coordinate.latitude );
				min.longitude = MIN( min.longitude, a.coordinate.longitude );
				
				max.latitude = MAX( max.latitude, a.coordinate.latitude );
				max.longitude = MAX( max.longitude, a.coordinate.longitude );
			}
			++numberOfValidAnnotations;
        }
    }
	
    // If we don't have any valid annotations we can leave now,
    // this will happen in the event that there is only the user location
    if ( numberOfValidAnnotations == 0 )
        return;
	
    // Now that we have a min and max lat/lon create locations for the
    // three points in a right triangle
    CLLocation* locSouthWest = [[CLLocation alloc] 
								initWithLatitude: min.latitude 
								longitude: min.longitude];
    CLLocation* locSouthEast = [[CLLocation alloc] 
								initWithLatitude: min.latitude 
								longitude: max.longitude];
    CLLocation* locNorthEast = [[CLLocation alloc] 
								initWithLatitude: max.latitude 
								longitude: max.longitude];
	
    // Create a region centered at the midpoint of our hypotenuse
    CLLocationCoordinate2D regionCenter;
    regionCenter.latitude = (min.latitude + max.latitude) / 2.0;
    regionCenter.longitude = (min.longitude + max.longitude) / 2.0;
	
    // Use the locations that we just created to calculate the distance
    // between each of the points in meters.
    CLLocationDistance latMeters = [locSouthEast distanceFromLocation: locNorthEast];
    CLLocationDistance lonMeters = [locSouthEast distanceFromLocation: locSouthWest];
	
    MKCoordinateRegion region;
    region = MKCoordinateRegionMakeWithDistance( regionCenter, latMeters, lonMeters );
	
    MKCoordinateRegion fitRegion = [self.mapView regionThatFits: region];
    [self.mapView setRegion: fitRegion animated: YES];
	
    // Clean up
    [locSouthWest release];
    [locSouthEast release];
    [locNorthEast release];
}

@dynamic stations;
- (NSArray*)stations{
    return self.mapView.annotations;
}

#pragma mark -
#pragma mark Private methods

- (void)addAnnotations:(NSArray *)annotations {
	NSArray *oldAnnotations = self.mapView.annotations;
    [self.mapView removeAnnotations:oldAnnotations];
    [self.mapView addAnnotations:annotations];
    if (selectedStation == nil) {
        [self centerAroundAnnotations:annotations];
    } else {
        [self centerAroundStation:selectedStation];        
    }
}

- (void)centerAroundStation:(StationInfo *)station {
	int zoomLevel = 9;
	if([iPadHelper isIpad]){
		zoomLevel = 10;
	}
    [self.mapView setCenterCoordinate:station.coordinate zoomLevel:zoomLevel animated:YES];
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
																				 action:@selector(refreshAction:)];
	self.navigationItem.rightBarButtonItem = refreshItem;
	[refreshItem release];
}

- (void)refresh {
    [self startRefreshAnimation];
	if(client == nil){
		client = [[WMReSTClient alloc] init ];
	}
    
    // (re-)load content
	[client asyncGetStationList:[[NSUserDefaults standardUserDefaults]boolForKey:STATION_OPERATIONAL_KEY] forSender:self];
}

- (void)showStationDetail:(id)sender {
    if ([self.mapView.selectedAnnotations count] == 0) {
        return;
    }
    id<MKAnnotation> annotation = [self.mapView.selectedAnnotations objectAtIndex:0];
    
	StationDetailMeteoViewController *meteo = [[StationDetailMeteoViewController alloc]initWithNibName:@"StationDetailMeteoViewController" bundle:nil];
    meteo.stationInfo = annotation;
	UINavigationController *nav = [[UINavigationController alloc] initWithRootViewController:meteo];
	[meteo release];
    
    // Show in modal view
    [self presentModalViewController:nav animated:YES];
    
	[nav release];
}

- (void)settingsChanged:(NSNotification* )notif {
    if ([[notif object] isEqualToString:STATION_OPERATIONAL_KEY]) {
        [self refresh];
    } else if ([[notif object] isEqualToString:MAP_TYPE_KEY]) {
        self.mapView.mapType =[[NSUserDefaults standardUserDefaults]integerForKey:MAP_TYPE_KEY];
    }
}

#pragma mark -
#pragma mark WMReSTClientDelegate

- (void)stationList:(NSArray *)stations{
	[self stopRefreshAnimation];
	[self performSelectorOnMainThread:@selector(addAnnotations:) withObject:stations waitUntilDone:true];
}

- (void)serverError:(NSString *)title message:(NSString *)message{
	[self stopRefreshAnimation];
    [WMReSTClient showError:title message:message];
}

- (void)connectionError:(NSString *)title message:(NSString *)message{
	[self stopRefreshAnimation];
    [WMReSTClient showError:title message:message];
}

#pragma mark -
#pragma mark MKMapViewDelegate

- (MKAnnotationView *)mapView:(MKMapView *)theMapView viewForAnnotation:(id <MKAnnotation>)annotation{
	if ([annotation isKindOfClass:[MKUserLocation class]]){
		// Ignore the user location
        return nil;
	}
	StationInfo *info = (StationInfo*)annotation;
	static NSString* stationAnnotationIdentifier = @"stationAnnotationIdentifier";
	
	MKPinAnnotationView* pinView = (MKPinAnnotationView *)[self.mapView dequeueReusableAnnotationViewWithIdentifier:stationAnnotationIdentifier];
	if (!pinView) {
		// if an existing pin view was not available, create one
		pinView = [[[MKPinAnnotationView alloc]initWithAnnotation:annotation reuseIdentifier:stationAnnotationIdentifier] autorelease];
		
		pinView.animatesDrop = YES;
		pinView.canShowCallout = YES;
		
		UIButton* rightButton = [UIButton buttonWithType:UIButtonTypeDetailDisclosure];
		[rightButton addTarget:self
						action:@selector(showStationDetail:)
			  forControlEvents:UIControlEventTouchUpInside];
		pinView.rightCalloutAccessoryView = rightButton;
	}
	
	pinView.annotation = annotation;
	switch (info.maintenanceStatusEnum) {
		case StationInfoStatusGreen:
			pinView.pinColor = MKPinAnnotationColorGreen;
			break;
		case StationInfoStatusOrange:
			pinView.pinColor = MKPinAnnotationColorPurple;
			break;
		case StationInfoStatusRed:
			pinView.pinColor = MKPinAnnotationColorRed;
			break;
		default:
			break;
	}
	
	return pinView;
}

#pragma mark -
#pragma mark Memory

- (void)didReceiveMemoryWarning {
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Release any cached data, images, etc. that aren't in use.
}

- (void)dealloc {
	[client release];
	[selectedStation release];
	[mapView release];
	
    [super dealloc];
}

@end
