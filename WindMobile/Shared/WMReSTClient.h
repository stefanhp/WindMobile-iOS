//
//  WMReSTClient.h
//  WindMobile
//
//  Created by Stefan Hochuli Paychère on 17.05.10.
//  Copyright 2010 Pistache Software. All rights reserved.
//

#import "CPSReSTClient.h"

#define REST_SERVER @"windmobile.vol-libre-suchet.ch"
#define REST_PORT 1588

@protocol WMReSTClientDelegate
@optional
- (void)requestError:(NSMutableDictionary *)error;
- (void)stationList:(NSArray*)stations;
- (void)stationData:(NSDictionary*)stationData;
@end


@interface WMReSTClient : CPSReSTClient<CPSReSTClientDelegate> {
	NSObject<WMReSTClientDelegate>* stationListSender;
	NSObject<WMReSTClientDelegate>* stationDataSender;
}
@property (retain,readwrite) NSObject<WMReSTClientDelegate>* stationListSender;
@property (retain,readwrite) NSObject<WMReSTClientDelegate>* stationDataSender;
+ (NSArray*)convertToStationInfo:(NSArray*)stations;

- (NSArray*)getStationList;
- (void)asyncGetStationList:(id)sender;

- (NSDictionary*)getStationData:(NSString*)stationID;
- (void)asyncGetStationData:(NSString*)stationID forSender:(id)sender;

// Parent delegate
- (void)connectionError:(NSMutableDictionary *)error;
- (void)asyncResponse:(NSDictionary*)result;

// Helpers
- (void)showError:(NSString*)message;

@end

@interface WMReSTClient ()
- (void)getStationListResponse:(NSDictionary*)response;
- (void)getStationDataResponse:(NSDictionary*)response;
@end