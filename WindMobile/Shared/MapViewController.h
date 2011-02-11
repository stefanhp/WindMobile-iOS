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

@interface MapViewController : UIViewController <MKMapViewDelegate,UIActionSheetDelegate> {
	MKMapView *mapView;
}
@property (nonatomic, retain) IBOutlet MKMapView *mapView;

- (void)addAnnotation:(id <MKAnnotation>)annotation;
- (void)addAnnotations:(NSArray *)annotations;
- (void)removeAnnotation:(id <MKAnnotation>)annotation;
- (void)removeAnnotations:(NSArray *)annotations;
- (IBAction)showInMaps:(id)sender;
- (void)centerWithHint:(CLLocationCoordinate2D) coordinate;
@end
