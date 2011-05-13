//
//  WMReSTClient.h
//  WindMobile
//
//  Created by Stefan Hochuli Paychère on 17.05.10.
//  Copyright 2010 Pistache Software. All rights reserved.
//

#import "CPSReSTClient.h"
#import "StationData.h"
#import "StationGraphData.h"

#define REST_SERVER @"windmobile.vol-libre-suchet.ch"
#define REST_PORT 1588
#define REST_TIMEOUT 60.0

@protocol WMReSTClientDelegate
@optional
- (void)stationList:(NSArray*)stations;
- (void)stationData:(StationData*)stationData;
- (void)stationGraphData:(StationGraphData*)stationGraphData;
@required
- (void)serverError:(NSString*)title message:(NSString*)msg;
- (void)connectionError:(NSString*)title message:(NSString*)msg;
@end


@interface WMReSTClient : CPSReSTClient<CPSReSTClientDelegate> {
	NSObject<WMReSTClientDelegate>* stationListSender;
	NSObject<WMReSTClientDelegate>* stationDataSender;
	NSObject<WMReSTClientDelegate>* stationGraphDataSender;
	
	BOOL useMockClient;
}
@property (retain,readwrite) NSObject<WMReSTClientDelegate>* stationListSender;
@property (retain,readwrite) NSObject<WMReSTClientDelegate>* stationDataSender;
@property (retain,readwrite) NSObject<WMReSTClientDelegate>* stationGraphDataSender;
+ (NSArray*)convertToStationInfo:(NSArray*)stations;
+ (StationData*)convertToStationData:(NSDictionary*)stationData;
+ (StationGraphData*)convertToStationGraphData:(NSDictionary*)stationGraphData;

- (NSArray*)getStationList:(BOOL)operationalStationOnly;
- (void)asyncGetStationList:(BOOL)operationalStationOnly forSender:(id)sender;

- (StationData*)getStationData:(NSString*)stationID;
- (void)asyncGetStationData:(NSString*)stationID forSender:(id)sender;

- (StationGraphData*)getStationGraphData:(NSString*)stationID duration:(NSString*)duration;
- (void)asyncGetStationGraphData:(NSString*)stationID duration:(NSString*)duration forSender:(id)sender;

// Parent delegate
- (void)connectionError:(NSError*)error;
- (void)asyncResponse:(NSDictionary*)result;

// Helpers
+ (void)showError:(NSString*)title message:(NSString*)message;

@end

@interface WMReSTClient ()
- (void)getStationListResponse:(NSDictionary*)response;
- (void)getStationDataResponse:(NSDictionary*)response;
- (void)getStationGraphDataResponse:(NSDictionary*)response;
- (void)serverError:(NSDictionary*)error;
- (void)serverUnknownError:(NSInteger)httpStatusCode;

- (NSMutableDictionary*)mockStationInfo;
- (NSMutableDictionary*)mockStationData;
- (NSMutableDictionary*)mockGraphData;
@end