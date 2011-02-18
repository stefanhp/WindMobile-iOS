//
//  WMReSTClient.h
//  WindMobile
//
//  Created by Stefan Hochuli Paychère on 17.05.10.
//  Copyright 2010 Pistache Software. All rights reserved.
//

#import "CPSReSTClient.h"
#import "StationData.h"
#import "StationGraph.h"

#define REST_SERVER @"windmobile.vol-libre-suchet.ch"
#define REST_PORT 1588

@protocol WMReSTClientDelegate
@optional
- (void)requestError:(NSString*) message details:(NSMutableDictionary *)error;
- (void)stationList:(NSArray*)stations;
- (void)stationData:(StationData*)stationData;
- (void)stationGraph:(StationGraph*)stationGraph;
@end


@interface WMReSTClient : CPSReSTClient<CPSReSTClientDelegate> {
	NSObject<WMReSTClientDelegate>* stationListSender;
	NSObject<WMReSTClientDelegate>* stationDataSender;
	NSObject<WMReSTClientDelegate>* stationGraphSender;
	
	BOOL useMockClient;
}
@property (retain,readwrite) NSObject<WMReSTClientDelegate>* stationListSender;
@property (retain,readwrite) NSObject<WMReSTClientDelegate>* stationDataSender;
@property (retain,readwrite) NSObject<WMReSTClientDelegate>* stationGraphSender;
+ (NSArray*)convertToStationInfo:(NSArray*)stations;
+ (StationData*)convertToStationData:(NSDictionary*)stationData;
+ (StationGraph*)convertToStationGraph:(NSDictionary*)stationGraph;

- (NSArray*)getStationList;
- (void)asyncGetStationList:(id)sender;

- (StationData*)getStationData:(NSString*)stationID;
- (void)asyncGetStationData:(NSString*)stationID forSender:(id)sender;

- (StationGraph*)getStationGraph:(NSString*)stationID duration:(NSString*)duration;
- (void)asyncGetStationGraph:(NSString*)stationID duration:(NSString*)duration forSender:(id)sender;

// Parent delegate
- (void)connectionError:(NSMutableDictionary *)error;
- (void)asyncResponse:(NSDictionary*)result;

// Helpers
- (void)showError:(NSString*)message;

@end

@interface WMReSTClient ()
- (void)getStationListResponse:(NSDictionary*)response;
- (void)getStationDataResponse:(NSDictionary*)response;

- (NSMutableDictionary*)mockStationInfo;
- (NSMutableDictionary*)mockStationData;
- (NSMutableDictionary*)mockGraphData;
@end