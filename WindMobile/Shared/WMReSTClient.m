//
//  WMReSTClient.m
//  WindMobile
//
//  Created by Stefan Hochuli Paychère on 17.05.10.
//  Copyright 2010 Pistache Software. All rights reserved.
//

#import "WMReSTClient.h"
#import "StationInfo.h"

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

#pragma mark -
#pragma mark CPSReSTClient override

- (NSMutableDictionary*)execRequest:(NSURLRequest*)request {
	if([[NSUserDefaults standardUserDefaults] boolForKey:MOCK_KEY] == NO){
		return [super execRequest:request];
	}
	
	NSArray *pathComp = request.URL.pathComponents;
	
	if([pathComp containsObject:@"stationinfos"]){
		return [self mockStationInfo];
	} else if([pathComp containsObject:@"stationdatas"]){
		return [self mockStationData];
	} else if([pathComp containsObject:@"windchart"]){
		return [self mockGraphData];
	}
	
	// error
	if (delegate != nil && [delegate conformsToProtocol:@protocol(CPSReSTClientDelegate)]) {
		[delegate performSelectorOnMainThread:@selector(connectionError: ) withObject:[NSMutableDictionary dictionaryWithCapacity:0] waitUntilDone:YES];
	}
	
	return [NSMutableDictionary dictionaryWithCapacity:0];
}

- (NSMutableDictionary*)mockStationInfo{
	NSMutableDictionary *response = [NSMutableDictionary dictionaryWithCapacity:2]; 
	NSDictionary *stationInfo = [[NSDictionary alloc] initWithObjectsAndKeys:
								 @"1180", @"@altitude",
								 @"3600", @"@dataValidity", 
								 @"jdc:1001", @"@id",
								 @"Mauborget", @"@name",
								 @"Mauborget", @"@shortName",
								 @"46.854273800878", @"@wgs84Latitude",
								 @"6.6119477978952", @"@wgs84Longitude",
								 @"green", @"@maintenanceStatus",
								 nil];
	NSDictionary *stationInfos = [[NSDictionary alloc] initWithObjectsAndKeys:
								  [NSArray arrayWithObject:stationInfo], @"stationInfo",
								  nil];
	NSDictionary *content = [[NSDictionary alloc] initWithObjectsAndKeys:
							 stationInfos, @"stationInfos",
							 nil];
	[response setObject:content forKey:@"content"];
	return response;
}

- (NSMutableDictionary*)mockStationData{
	NSMutableDictionary *response = [NSMutableDictionary dictionaryWithCapacity:2]; 
	NSDictionary* point1 = [NSDictionary dictionaryWithObjectsAndKeys:
							@"1297666800000", @"date",
							@"326.0", @"value",
							nil];
	
	NSDictionary* point2 = [NSDictionary dictionaryWithObjectsAndKeys:
							@"1297667400000", @"date",
							@"324.0", @"value",
							nil];
	NSDictionary* point3 = [NSDictionary dictionaryWithObjectsAndKeys:
							@"1297668000000", @"date",
							@"191.0", @"value",
							nil];
	NSDictionary* point4 = [NSDictionary dictionaryWithObjectsAndKeys:
							@"1297668600000", @"date",
							@"182.0", @"value",
							nil];
	NSDictionary* point5 = [NSDictionary dictionaryWithObjectsAndKeys:
							@"1297668000000", @"date",
							@"157.0", @"value",
							nil];
	NSDictionary* point6 = [NSDictionary dictionaryWithObjectsAndKeys:
							@"1297669800000", @"date",
							@"191.0", @"value",
							nil];
	NSDictionary* point7 = [NSDictionary dictionaryWithObjectsAndKeys:
							@"1297670400000", @"date",
							@"157.0", @"value",
							nil];
	
	NSDictionary* serie = [NSDictionary dictionaryWithObjectsAndKeys:
						   @"windDirection", @"@name",
						   [NSArray arrayWithObjects:point1, point2, point3, point4, point5, point6, point7, nil], @"points",
						   nil];
	
	NSDictionary* chart = [NSDictionary dictionaryWithObjectsAndKeys:
						   @"3600", @"duration",
						   serie, @"serie",
						   nil];
	
	NSDictionary* stationData = [NSDictionary dictionaryWithObjectsAndKeys:
								 @"2011-02-14T10:00:00+0100", @"@expirationDate",
								 @"2011-02-14T09:00:00+0100", @"@lastUpdate",
								 @"1001", @"@stationId",
								 @"green", @"@status",
								 @"61.6", @"airHumidity", 
								 @"3.4", @"airTemperature", 
								 @"6.4", @"windAverage",
								 
								 chart, @"windDirectionChart",
								 
								 @"2.9", @"windHistoryAverage",
								 @"19.6", @"windHistoryMax",
								 @"0.6", @"windHistoryMin",
								 @"19.6", @"windMax",
								 @"48", @"windTrend",
								 
								 nil];
	NSDictionary *content = [[NSDictionary alloc] initWithObjectsAndKeys:
							 stationData, @"stationData",
							 nil];
	[response setObject:content forKey:@"content"];
	return response;
}

- (NSMutableDictionary*)mockGraphData{
	NSMutableDictionary *response = [NSMutableDictionary dictionaryWithCapacity:2];
	
	NSArray* serie = [NSArray arrayWithObjects:
					  // average
					  [NSDictionary dictionaryWithObjectsAndKeys:
					   @"windAverage", @"@name",
					   [NSArray arrayWithObjects:
						[NSDictionary dictionaryWithObjectsAndKeys: @"1297940400000", @"date", @"2.8", @"value", nil],
						[NSDictionary dictionaryWithObjectsAndKeys: @"1297941000000", @"date", @"4.6", @"value", nil],
						[NSDictionary dictionaryWithObjectsAndKeys: @"1297941600000", @"date", @"1.7", @"value", nil],
						[NSDictionary dictionaryWithObjectsAndKeys: @"1297942200000", @"date", @"2.5", @"value", nil],
						[NSDictionary dictionaryWithObjectsAndKeys: @"1297942800000", @"date", @"5.5", @"value", nil],
						[NSDictionary dictionaryWithObjectsAndKeys: @"1297943400000", @"date", @"6.8", @"value", nil],
						[NSDictionary dictionaryWithObjectsAndKeys: @"1297944000000", @"date", @"2.5", @"value", nil],
						[NSDictionary dictionaryWithObjectsAndKeys: @"1297944600000", @"date", @"0.4", @"value", nil],
						[NSDictionary dictionaryWithObjectsAndKeys: @"1297945200000", @"date", @"0.0", @"value", nil],
						[NSDictionary dictionaryWithObjectsAndKeys: @"1297945800000", @"date", @"0.0", @"value", nil],
						[NSDictionary dictionaryWithObjectsAndKeys: @"1297946400000", @"date", @"1.7", @"value", nil],
						[NSDictionary dictionaryWithObjectsAndKeys: @"1297947000000", @"date", @"0.3", @"value", nil],
						[NSDictionary dictionaryWithObjectsAndKeys: @"1297947600000", @"date", @"0.4", @"value", nil],
						[NSDictionary dictionaryWithObjectsAndKeys: @"1297948200000", @"date", @"1.1", @"value", nil],
						[NSDictionary dictionaryWithObjectsAndKeys: @"1297948800000", @"date", @"0.2", @"value", nil],
						[NSDictionary dictionaryWithObjectsAndKeys: @"1297949400000", @"date", @"0.6", @"value", nil],
						[NSDictionary dictionaryWithObjectsAndKeys: @"1297950000000", @"date", @"0.0", @"value", nil],
						[NSDictionary dictionaryWithObjectsAndKeys: @"1297950600000", @"date", @"1.8", @"value", nil],
						[NSDictionary dictionaryWithObjectsAndKeys: @"1297951200000", @"date", @"5.4", @"value", nil],
						[NSDictionary dictionaryWithObjectsAndKeys: @"1297951800000", @"date", @"6.2", @"value", nil],
						[NSDictionary dictionaryWithObjectsAndKeys: @"1297952400000", @"date", @"6.4", @"value", nil],
						[NSDictionary dictionaryWithObjectsAndKeys: @"1297953000000", @"date", @"5.7", @"value", nil],
						[NSDictionary dictionaryWithObjectsAndKeys: @"1297953600000", @"date", @"6.1", @"value", nil],
						[NSDictionary dictionaryWithObjectsAndKeys: @"1297954200000", @"date", @"3.8", @"value", nil],
						nil], @"points",
					   nil],
					  // max
					  [NSDictionary dictionaryWithObjectsAndKeys:
					   @"windMax", @"@name",
					   [NSArray arrayWithObjects:
						[NSDictionary dictionaryWithObjectsAndKeys: @"1297940400000", @"date", @"8.3", @"value", nil],
						[NSDictionary dictionaryWithObjectsAndKeys: @"1297941000000", @"date", @"8.7", @"value", nil],
						[NSDictionary dictionaryWithObjectsAndKeys: @"1297941600000", @"date", @"7.2", @"value", nil],
						[NSDictionary dictionaryWithObjectsAndKeys: @"1297942200000", @"date", @"8.6", @"value", nil],
						[NSDictionary dictionaryWithObjectsAndKeys: @"1297942800000", @"date", @"12.3", @"value", nil],
						[NSDictionary dictionaryWithObjectsAndKeys: @"1297943400000", @"date", @"13.6", @"value", nil],
						[NSDictionary dictionaryWithObjectsAndKeys: @"1297944000000", @"date", @"7.6", @"value", nil],
						[NSDictionary dictionaryWithObjectsAndKeys: @"1297944600000", @"date", @"4.1", @"value", nil],
						[NSDictionary dictionaryWithObjectsAndKeys: @"1297945200000", @"date", @"0.0", @"value", nil],
						[NSDictionary dictionaryWithObjectsAndKeys: @"1297945800000", @"date", @"2.1", @"value", nil],
						[NSDictionary dictionaryWithObjectsAndKeys: @"1297946400000", @"date", @"6.2", @"value", nil],
						[NSDictionary dictionaryWithObjectsAndKeys: @"1297947000000", @"date", @"4.2", @"value", nil],
						[NSDictionary dictionaryWithObjectsAndKeys: @"1297947600000", @"date", @"4.1", @"value", nil],
						[NSDictionary dictionaryWithObjectsAndKeys: @"1297948200000", @"date", @"6.6", @"value", nil],
						[NSDictionary dictionaryWithObjectsAndKeys: @"1297948800000", @"date", @"4.2", @"value", nil],
						[NSDictionary dictionaryWithObjectsAndKeys: @"1297949400000", @"date", @"4.7", @"value", nil],
						[NSDictionary dictionaryWithObjectsAndKeys: @"1297950000000", @"date", @"2.1", @"value", nil],
						[NSDictionary dictionaryWithObjectsAndKeys: @"1297950600000", @"date", @"9.1", @"value", nil],
						[NSDictionary dictionaryWithObjectsAndKeys: @"1297951200000", @"date", @"11.8", @"value", nil],
						[NSDictionary dictionaryWithObjectsAndKeys: @"1297951800000", @"date", @"14.5", @"value", nil],
						[NSDictionary dictionaryWithObjectsAndKeys: @"1297952400000", @"date", @"13.8", @"value", nil],
						[NSDictionary dictionaryWithObjectsAndKeys: @"1297953000000", @"date", @"12.9", @"value", nil],
						[NSDictionary dictionaryWithObjectsAndKeys: @"1297953600000", @"date", @"13.9", @"value", nil],
						[NSDictionary dictionaryWithObjectsAndKeys: @"1297954200000", @"date", @"13.7", @"value", nil],
						[NSDictionary dictionaryWithObjectsAndKeys: @"1297954800000", @"date", @"13.8", @"value", nil],
						nil], @"points",
					   nil],
					  // direction
					  [NSDictionary dictionaryWithObjectsAndKeys:
					   @"windDirection", @"@name",
					   [NSArray arrayWithObjects:
						[NSDictionary dictionaryWithObjectsAndKeys: @"1297940400000", @"date", @"173.0", @"value", nil],
						[NSDictionary dictionaryWithObjectsAndKeys: @"1297941000000", @"date", @"174.0", @"value", nil],
						[NSDictionary dictionaryWithObjectsAndKeys: @"1297941600000", @"date", @"159.0", @"value", nil],
						[NSDictionary dictionaryWithObjectsAndKeys: @"1297942200000", @"date", @"264.0", @"value", nil],
						[NSDictionary dictionaryWithObjectsAndKeys: @"1297942800000", @"date", @"321.0", @"value", nil],
						[NSDictionary dictionaryWithObjectsAndKeys: @"1297943400000", @"date", @"340.0", @"value", nil],
						[NSDictionary dictionaryWithObjectsAndKeys: @"1297944000000", @"date", @"338.0", @"value", nil],
						[NSDictionary dictionaryWithObjectsAndKeys: @"1297944600000", @"date", @"319.0", @"value", nil],
						[NSDictionary dictionaryWithObjectsAndKeys: @"1297945200000", @"date", @"0.0", @"value", nil],
						[NSDictionary dictionaryWithObjectsAndKeys: @"1297945800000", @"date", @"325.0", @"value", nil],
						[NSDictionary dictionaryWithObjectsAndKeys: @"1297946400000", @"date", @"143.0", @"value", nil],
						[NSDictionary dictionaryWithObjectsAndKeys: @"1297947000000", @"date", @"113.0", @"value", nil],
						[NSDictionary dictionaryWithObjectsAndKeys: @"1297947600000", @"date", @"134.0", @"value", nil],
						[NSDictionary dictionaryWithObjectsAndKeys: @"1297948200000", @"date", @"140.0", @"value", nil],
						[NSDictionary dictionaryWithObjectsAndKeys: @"1297948800000", @"date", @"137.0", @"value", nil],
						[NSDictionary dictionaryWithObjectsAndKeys: @"1297949400000", @"date", @"163.0", @"value", nil],
						[NSDictionary dictionaryWithObjectsAndKeys: @"1297950000000", @"date", @"187.0", @"value", nil],
						[NSDictionary dictionaryWithObjectsAndKeys: @"1297950600000", @"date", @"323.0", @"value", nil],
						[NSDictionary dictionaryWithObjectsAndKeys: @"1297951200000", @"date", @"328.0", @"value", nil],
						[NSDictionary dictionaryWithObjectsAndKeys: @"1297951800000", @"date", @"341.0", @"value", nil],
						[NSDictionary dictionaryWithObjectsAndKeys: @"1297952400000", @"date", @"336.0", @"value", nil],
						[NSDictionary dictionaryWithObjectsAndKeys: @"1297953000000", @"date", @"335.0", @"value", nil],
						[NSDictionary dictionaryWithObjectsAndKeys: @"1297953600000", @"date", @"336.0", @"value", nil],
						[NSDictionary dictionaryWithObjectsAndKeys: @"1297954200000", @"date", @"328.0", @"value", nil],
						[NSDictionary dictionaryWithObjectsAndKeys: @"1297954800000", @"date", @"331.0", @"value", nil],						nil], @"points",
					   nil],
					  nil];
	
	NSDictionary* stationGraph = [NSDictionary dictionaryWithObjectsAndKeys:
								  @"14400", @"@duration",
								  @"2011-02-17T16:00:00+0100", @"@lastUpdate",
								  serie, @"serie",
								  nil];
	
	NSDictionary *content = [[NSDictionary alloc] initWithObjectsAndKeys:
							 stationGraph, @"chart",
							 nil];
	[response setObject:content forKey:@"content"];
	return response;
}

@end
