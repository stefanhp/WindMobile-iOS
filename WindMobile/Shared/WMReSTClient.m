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
#define URL_STATION_INFOS @"/windmobile/stationinfos"
#define URL_STATION_DATA_FORMAT @"/windmobile/stationdatas/%@"

@implementation WMReSTClient

@synthesize stationListSender;
@synthesize stationDataSender;

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

- (NSArray*)getStationList{
	NSDictionary* result = [self request:CPSReSTMethodGET atURL:URL_STATION_INFOS withGET:nil withPOST:nil asXML:YES accept:CPSReSTContentTypeApplicationXML];
	NSArray* stations = nil;
	
	// parse result
	NSDictionary * content = [result objectForKey:@"content"];
	if(content != nil && [content count]>0 && [result objectForKey:@"error"] == nil){
		stations = [[content objectForKey:@"stationInfos"]objectForKey:@"stationInfo"];
	}
	
	return [WMReSTClient convertToStationInfo:stations];
}

- (void)asyncGetStationList:(id)sender{
	[self setStationListSender:sender];
	[self async:self request:CPSReSTMethodGET atURL:URL_STATION_INFOS withGET:nil withPOST:nil asXML:YES accept:CPSReSTContentTypeApplicationXML];
}

- (void)getStationListResponse:(NSDictionary*)response{
	NSArray* stations = nil;
	
	// parse result
	NSDictionary * content = [response objectForKey:@"content"];
	if(content != nil && [content count]>0 && [response objectForKey:@"error"] == nil){
		stations = [[content objectForKey:@"stationInfos"]objectForKey:@"stationInfo"];
	}
	
	if(stationListSender != nil && [stationListSender respondsToSelector:@selector(stationList:)]){
		[stationListSender stationList:[WMReSTClient convertToStationInfo:stations]];
	}
}

+ (NSArray*)convertToStationInfo:(NSArray*)stations{
	NSMutableArray *converted = [[NSMutableArray alloc] initWithCapacity:[stations count]];
	for(NSDictionary* station in stations){
		StationInfo* info = [[StationInfo alloc]initWithDictionary:station];
		[converted addObject:info];
	}
	return converted;
}

- (NSDictionary*)getStationData:(NSString*)stationID{
	NSDictionary* result = [self request:CPSReSTMethodGET atURL:[NSString stringWithFormat:URL_STATION_DATA_FORMAT, stationID]
								   withGET:nil withPOST:nil asXML:YES accept:CPSReSTContentTypeApplicationXML];
	NSDictionary* stationData = nil;
	
	// parse result
	NSDictionary * content = [result objectForKey:@"content"];
	if(content != nil && [content count]>0 && [result objectForKey:@"error"] == nil){
		stationData = [content objectForKey:@"stationData"];
	}
	return stationData;
}

- (void)asyncGetStationData:(NSString*)stationID forSender:(id)sender{
	[self setStationDataSender:sender];
	[self async:self request:CPSReSTMethodGET atURL:[NSString stringWithFormat:URL_STATION_DATA_FORMAT, stationID]
		withGET:nil withPOST:nil asXML:YES accept:CPSReSTContentTypeApplicationXML]; 
}

- (void)getStationDataResponse:(NSDictionary*)response{
	NSDictionary* stationData = nil;

	// parse result
	NSDictionary * content = [response objectForKey:@"content"];
	if(content != nil && [content count]>0 && [response objectForKey:@"error"] == nil){
		stationData = [content objectForKey:@"stationData"];
	}
	
	if(stationDataSender != nil && [stationDataSender respondsToSelector:@selector(stationData:)]){
		[stationDataSender stationData:stationData];
	}
}

- (void)asyncResponse:(NSDictionary*)result{
	NSDictionary * content = [result objectForKey:@"content"];
	if(content != nil && [content count]>0 && [result objectForKey:@"error"] == nil){
		if([content objectForKey:@"stationInfos"] != nil){
			[self getStationListResponse:result];
		} else if([content objectForKey:@"stationData"] != nil){
			[self getStationDataResponse:result];
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
