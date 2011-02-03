//
//  WMReSTClient.m
//  WindMobile
//
//  Created by Stefan Hochuli Paychère on 17.05.10.
//  Copyright 2010 Pistache Software. All rights reserved.
//

#import "WMReSTClient.h"
#import "StationInfo.h"

#define TIMEOUT_KEY @"timeout_preference"

#define RESP_CONTENT_KEY @"content"
#define RESP_ERROR_KEY @"error"

#define URL_STATION_INFOS @"/windmobile/stationinfos"
#define RESP_STATIONS_INFO_KEY @"stationInfos"
#define RESP_STATION_INFO_KEY @"stationInfo"

#define URL_STATION_DATA_FORMAT @"/windmobile/stationdatas/%@"
#define RESP_STATION_DATA_KEY @"stationData"

#define URL_STATION_GRAPH_FORMAT @"/windmobile/windchart/%@/%@"
#define RESP_STATION_GRAPH_KEY @"chart"

@implementation WMReSTClient

@synthesize stationListSender;
@synthesize stationDataSender;
@synthesize stationGraphSender;

- (id)init{
	if(self=[super initWithServer:REST_SERVER onPort:REST_PORT withSSL:NO]){
		[super setDelegate:self];
		NSTimeInterval interval = [[NSUserDefaults standardUserDefaults]doubleForKey:TIMEOUT_KEY];
		if (interval > 5) {
			[super setTimeout:interval];
		}

	}
	return self;
}

#pragma mark -
#pragma mark - Station Info

- (NSArray*)getStationList{
	NSDictionary* result = [self request:CPSReSTMethodGET atURL:URL_STATION_INFOS withGET:nil withPOST:nil asXML:YES accept:CPSReSTContentTypeApplicationXML];
	NSArray* stations = nil;
	
	// parse result
	NSDictionary * content = [result objectForKey:RESP_CONTENT_KEY];
	if(content != nil && [content count]>0 && [result objectForKey:RESP_ERROR_KEY] == nil){
		stations = [[content objectForKey:RESP_STATIONS_INFO_KEY]objectForKey:RESP_STATION_INFO_KEY];
	} else if(content != nil && [content count]>0 && [result objectForKey:RESP_ERROR_KEY] != nil){
		[self connectionError:[result objectForKey:RESP_ERROR_KEY]];
		return nil;
	}
	
	return [WMReSTClient convertToStationInfo:stations];
}

- (void)asyncGetStationList:(id)sender{
	self.stationListSender = sender;
	[self async:self request:CPSReSTMethodGET atURL:URL_STATION_INFOS withGET:nil withPOST:nil asXML:YES accept:CPSReSTContentTypeApplicationXML];
}

- (void)getStationListResponse:(NSDictionary*)response{
	NSArray* stations = nil;
	
	// parse result
	NSDictionary * content = [response objectForKey:RESP_CONTENT_KEY];
	if(content != nil && [content count]>0 && [response objectForKey:RESP_ERROR_KEY] == nil){
		stations = [[content objectForKey:RESP_STATIONS_INFO_KEY]objectForKey:RESP_STATION_INFO_KEY];
		if(stationListSender != nil && [stationListSender respondsToSelector:@selector(stationList:)]){
			[stationListSender stationList:[WMReSTClient convertToStationInfo:stations]];
		}
	} else if(content != nil && [content count]>0 && [response objectForKey:RESP_ERROR_KEY] != nil){
		[self connectionError:[response objectForKey:RESP_ERROR_KEY]];
	}
	self.stationListSender = nil;
}

+ (NSArray*)convertToStationInfo:(NSArray*)stations{
	NSMutableArray *converted = [[NSMutableArray alloc] initWithCapacity:[stations count]];
	for(NSDictionary* station in stations){
		StationInfo* info = [[StationInfo alloc]initWithDictionary:station];
		[converted addObject:info];
	}
	return converted;
}

#pragma mark -
#pragma mark - Station Data

- (StationData*)getStationData:(NSString*)stationID{
	NSDictionary* result = [self request:CPSReSTMethodGET atURL:[NSString stringWithFormat:URL_STATION_DATA_FORMAT, stationID]
								   withGET:nil withPOST:nil asXML:YES accept:CPSReSTContentTypeApplicationXML];
	NSDictionary* stationData = nil;
	
	// parse result
	NSDictionary * content = [result objectForKey:RESP_CONTENT_KEY];
	if(content != nil && [content count]>0 && [result objectForKey:RESP_ERROR_KEY] == nil){
		stationData = [content objectForKey:RESP_STATION_DATA_KEY];
	} else if(content != nil && [content count]>0 && [result objectForKey:RESP_ERROR_KEY] != nil){
		[self connectionError:[result objectForKey:RESP_ERROR_KEY]];
		return nil;
	}
	
	return [WMReSTClient convertToStationData:stationData];
}

- (void)asyncGetStationData:(NSString*)stationID forSender:(id)sender{
	self.stationDataSender = sender;
	[self async:self request:CPSReSTMethodGET atURL:[NSString stringWithFormat:URL_STATION_DATA_FORMAT, stationID]
		withGET:nil withPOST:nil asXML:YES accept:CPSReSTContentTypeApplicationXML]; 
}

- (void)getStationDataResponse:(NSDictionary*)response{
	NSDictionary* stationData = nil;

	// parse result
	NSDictionary * content = [response objectForKey:RESP_CONTENT_KEY];
	if(content != nil && [content count]>0 && [response objectForKey:RESP_ERROR_KEY] == nil){
		stationData = [content objectForKey:RESP_STATION_DATA_KEY];
		if(stationDataSender != nil && [stationDataSender respondsToSelector:@selector(stationData:)]){
			[stationDataSender stationData:[WMReSTClient convertToStationData:stationData]];
		}
	} else if(content != nil && [content count]>0 && [response objectForKey:RESP_ERROR_KEY] != nil){
		[self connectionError:[response objectForKey:RESP_ERROR_KEY]];
	}
	self.stationDataSender = nil;
}

+ (StationData*)convertToStationData:(NSDictionary*)stationData{
	return [[StationData alloc]initWithDictionary:stationData];
}

#pragma mark -
#pragma mark - Station Graph

- (StationGraph*)getStationGraph:(NSString*)stationID duration:(NSString*)duration{
	NSDictionary* stationGraph = nil;

	NSDictionary* result = [self request:CPSReSTMethodGET
								   atURL:[NSString stringWithFormat:URL_STATION_GRAPH_FORMAT, stationID, duration]
								 withGET:nil withPOST:nil asXML:YES 
								  accept:CPSReSTContentTypeApplicationXML];

	// parse result
	NSDictionary * content = [result objectForKey:RESP_CONTENT_KEY];
	if(content != nil && [content count]>0 && [result objectForKey:RESP_ERROR_KEY] == nil){
		stationGraph = [content objectForKey:@"chart"];
	}
	return [WMReSTClient convertToStationGraph:stationGraph];
}

- (void)asyncGetStationGraph:(NSString*)stationID duration:(NSString*)duration forSender:(id)sender{
	self.stationGraphSender = sender;
	[self async:self request:CPSReSTMethodGET atURL:[NSString stringWithFormat:URL_STATION_GRAPH_FORMAT, stationID, duration]
		withGET:nil withPOST:nil asXML:YES accept:CPSReSTContentTypeApplicationXML]; 
}

- (void)getStationGraphResponse:(NSDictionary*)response{
	NSDictionary* stationGraph = nil;
	
	// parse result
	NSDictionary * content = [response objectForKey:RESP_CONTENT_KEY];
	if(content != nil && [content count]>0 && [response objectForKey:RESP_ERROR_KEY] == nil){
		stationGraph = [content objectForKey:RESP_STATION_GRAPH_KEY];
	}
	
	if(stationGraphSender != nil && [stationGraphSender respondsToSelector:@selector(stationGraph:)]){
		[stationGraphSender stationGraph:[WMReSTClient convertToStationGraph:stationGraph]];
	}
	self.stationGraphSender = nil;
}

+ (StationGraph*)convertToStationGraph:(NSDictionary*)stationGraph{
	return [[StationGraph alloc]initWithDictionary:stationGraph];
}

#pragma mark -
#pragma mark Internal

- (void)asyncResponse:(NSDictionary*)result{
	NSDictionary * content = [result objectForKey:RESP_CONTENT_KEY];
	if(content != nil && [content count]>0 && [result objectForKey:RESP_ERROR_KEY] == nil){
		if([content objectForKey:RESP_STATIONS_INFO_KEY] != nil){
			[self getStationListResponse:result];
		} else if([content objectForKey:RESP_STATION_DATA_KEY] != nil){
			[self getStationDataResponse:result];
		} else if([content objectForKey:RESP_STATION_GRAPH_KEY] != nil){
			[self getStationGraphResponse:result];
		}
	}
}

- (void)connectionError:(NSMutableDictionary *)error{
	id code = [error objectForKey:@"statusCode"];
	NSString *msg;
	if(code != nil){
		msg = [NSLocalizedStringFromTable(@"ERROR_RECEIVED", @"WindMobile", nil) stringByAppendingString:[code stringValue]];
		msg = [[msg stringByAppendingString:@":\n"]stringByAppendingString:[NSHTTPURLResponse localizedStringForStatusCode:[code intValue]]];
	} else {
		msg = [NSString stringWithFormat:NSLocalizedStringFromTable(@"ERROR_RECEIVED_FORMAT", @"WindMobile", nil), REST_SERVER];
	}
	
	if(stationListSender != nil && [stationListSender respondsToSelector:@selector(requestError:details:)]){
		[stationListSender requestError:msg details:error];
	}
	if(stationDataSender != nil && [stationDataSender respondsToSelector:@selector(requestError:details:)]){
		[stationDataSender requestError:msg details:error];
	}
	if(stationGraphSender != nil && [stationGraphSender respondsToSelector:@selector(requestError:details:)]){
		[stationGraphSender requestError:msg details:error];
	}
	
	[self showError:msg];
}

- (void)showError:(NSString*)message{
	UIAlertView * alert = [[UIAlertView alloc] initWithTitle:NSLocalizedStringFromTable(@"ERROR_NETWORK", @"WindMobile", nil)
													 message:message
													delegate:nil cancelButtonTitle:NSLocalizedStringFromTable(@"OK", @"WindMobile", nil)
										   otherButtonTitles:nil];
	[alert show];
	[alert release];
}

@end
