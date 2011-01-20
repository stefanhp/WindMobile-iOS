//
//  MapViewController.h
//  WindMobile
//
//  Created by Stefan Hochuli Paychère on 22.05.10.
//  Copyright 2010 Pistache Software. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <MapKit/MapKit.h>

@class StationDetailViewController;

@interface MapViewController : UIViewController <MKMapViewDelegate,MKAnnotation> {
	MKMapView *mapView;
	MKCoordinateRegion region;
	CLLocationCoordinate2D coordinate;
	NSString* subtitle;
}
@property (nonatomic, retain) IBOutlet MKMapView *mapView;
@property (nonatomic) MKCoordinateRegion region;
@property (nonatomic) CLLocationCoordinate2D coordinate;
@property (nonatomic, retain) NSString* subtitle;

- (IBAction)showInMaps:(id)sender; 
@end
