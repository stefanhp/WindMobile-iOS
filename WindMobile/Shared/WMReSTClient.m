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
#define RESP_STATUS_CODE_KEY @"statusCode"

#define URL_STATION_INFOS @"/windmobile/stationinfos?allStation=%@"
#define RESP_STATIONS_INFO_KEY @"stationInfos"
#define RESP_STATION_INFO_KEY @"stationInfo"

#define URL_STATION_DATA_FORMAT @"/windmobile/stationdatas/%@"
#define RESP_STATION_DATA_KEY @"stationData"

#define URL_STATION_GRAPH_FORMAT @"/windmobile/windchart/%@/%@"
#define RESP_STATION_GRAPH_KEY @"chart"

@implementation WMReSTClient

@synthesize stationListSender;
@synthesize stationDataSender;
@synthesize stationGraphDataSender;

- (id)init{
	if(self=[super initWithServer:REST_SERVER onPort:REST_PORT withSSL:NO]){
		[super setDelegate:self];
		[super setTimeout:[[NSUserDefaults standardUserDefaults]doubleForKey:TIMEOUT_KEY]];
	}
	return self;
}

- (void)dealloc {
	[stationListSender release];
	[stationDataSender release];
	[stationGraphDataSender release];
	[super dealloc];
}

#pragma mark -
#pragma mark - Station Info

- (NSArray*)getStationList:(BOOL)operationalStationOnly{
	NSDictionary* result = [self request:CPSReSTMethodGET atURL:[NSString stringWithFormat:URL_STATION_INFOS, operationalStationOnly ? @"false" : @"true"] 
								 withGET:nil withPOST:nil asXML:YES accept:CPSReSTContentTypeApplicationXML];
	NSArray* stations = nil;
	
	// parse result
	NSDictionary * content = [result objectForKey:RESP_CONTENT_KEY];
	if(content != nil && [content count]>0){
		stations = [[content objectForKey:RESP_STATIONS_INFO_KEY]objectForKey:RESP_STATION_INFO_KEY];
	}
	return [WMReSTClient convertToStationInfo:stations];
}

- (void)asyncGetStationList:(BOOL)operationalStationOnly forSender:(id)sender{
	self.stationListSender = sender;
	[self async:self request:CPSReSTMethodGET atURL:[NSString stringWithFormat:URL_STATION_INFOS, operationalStationOnly ? @"false" : @"true"]
		withGET:nil withPOST:nil asXML:YES accept:CPSReSTContentTypeApplicationXML];
}

- (void)getStationListResponse:(NSDictionary*)content{
	if(content != nil && [content count]>0){
		NSArray* stations = [[content objectForKey:RESP_STATIONS_INFO_KEY]objectForKey:RESP_STATION_INFO_KEY];
		if(stationListSender != nil && [stationListSender respondsToSelector:@selector(stationList:)]){
			[stationListSender stationList:[WMReSTClient convertToStationInfo:stations]];
		}
	}
	self.stationListSender = nil;
}

+ (NSArray*)convertToStationInfo:(NSArray*)stations{
	NSMutableArray *converted = [[NSMutableArray alloc] initWithCapacity:[stations count]];
	for(NSDictionary* station in stations){
		StationInfo* info = [[StationInfo alloc]initWithDictionary:station];
		[converted addObject:info];
		[info release];
	}
	return [converted autorelease];
}

#pragma mark -
#pragma mark - Station Data

- (StationData*)getStationData:(NSString*)stationID{
	NSDictionary* result = [self request:CPSReSTMethodGET atURL:[NSString stringWithFormat:URL_STATION_DATA_FORMAT, stationID]
								   withGET:nil withPOST:nil asXML:YES accept:CPSReSTContentTypeApplicationXML];
	NSDictionary* stationData = nil;
	
	// parse result
	NSDictionary * content = [result objectForKey:RESP_CONTENT_KEY];
	if(content != nil && [content count]>0){
		stationData = [content objectForKey:RESP_STATION_DATA_KEY];
	}	
	return [WMReSTClient convertToStationData:stationData];
}

- (void)asyncGetStationData:(NSString*)stationID forSender:(id)sender{
	self.stationDataSender = sender;
	[self async:self request:CPSReSTMethodGET atURL:[NSString stringWithFormat:URL_STATION_DATA_FORMAT, stationID]
		withGET:nil withPOST:nil asXML:YES accept:CPSReSTContentTypeApplicationXML]; 
}

- (void)getStationDataResponse:(NSDictionary*)content{
	if(content != nil && [content count]>0){
		NSDictionary* stationData = [content objectForKey:RESP_STATION_DATA_KEY];
		if(stationDataSender != nil && [stationDataSender respondsToSelector:@selector(stationData:)]){
			[stationDataSender stationData:[WMReSTClient convertToStationData:stationData]];
		}
	}
	self.stationDataSender = nil;
}

+ (StationData*)convertToStationData:(NSDictionary*)stationData{
	return [[[StationData alloc]initWithDictionary:stationData]autorelease];
}

#pragma mark -
#pragma mark - Station Graph Data

- (StationGraphData*)getStationGraphData:(NSString*)stationID duration:(NSString*)duration{
	NSDictionary* stationGraphData = nil;

	NSDictionary* result = [self request:CPSReSTMethodGET
								   atURL:[NSString stringWithFormat:URL_STATION_GRAPH_FORMAT, stationID, duration]
								 withGET:nil withPOST:nil asXML:YES 
								  accept:CPSReSTContentTypeApplicationXML];

	// parse result
	NSDictionary * content = [result objectForKey:RESP_CONTENT_KEY];
	if(content != nil && [content count]>0){
		stationGraphData = [content objectForKey:@"chart"];
	}
	return [WMReSTClient convertToStationGraphData:stationGraphData];
}

- (void)asyncGetStationGraphData:(NSString*)stationID duration:(NSString*)duration forSender:(id)sender{
	self.stationGraphDataSender = sender;
	[self async:self request:CPSReSTMethodGET atURL:[NSString stringWithFormat:URL_STATION_GRAPH_FORMAT, stationID, duration]
		withGET:nil withPOST:nil asXML:YES accept:CPSReSTContentTypeApplicationXML]; 
}

- (void)getStationGraphDataResponse:(NSDictionary*)content{
    NSDictionary* data = nil;
	if(content != nil && [content count]>0){
		data = [content objectForKey:RESP_STATION_GRAPH_KEY];
	}
	
	if(stationGraphDataSender != nil && [stationGraphDataSender respondsToSelector:@selector(stationGraphData:)]){
		[stationGraphDataSender stationGraphData:[WMReSTClient convertToStationGraphData:data]];
	}
	self.stationGraphDataSender = nil;
}

+ (StationGraphData*)convertToStationGraphData:(NSDictionary*)data{
	return [[[StationGraphData alloc]initWithDictionary:data]autorelease];
}

#pragma mark -
#pragma mark Internal

- (void)asyncResponse:(NSDictionary*)result{
    NSInteger httpStatusCode = [[result objectForKey:RESP_STATUS_CODE_KEY] intValue];
	NSDictionary* content = [result objectForKey:RESP_CONTENT_KEY];
    
    if (httpStatusCode == 200) {
        if (content != nil && [content count] > 0) {
            if([content objectForKey:RESP_STATIONS_INFO_KEY] != nil) {
                [self getStationListResponse:content];
            } else if([content objectForKey:RESP_STATION_DATA_KEY] != nil) {
                [self getStationDataResponse:content];
            } else if([content objectForKey:RESP_STATION_GRAPH_KEY] != nil) {
                [self getStationGraphDataResponse:content];
            }
        } else {
            // Fake 204 "No content"
            [self serverUnknownError:204];
        }
    } else {
        // Server error
        if (content != nil && [content objectForKey:RESP_ERROR_KEY] != nil) {
            [self serverError:content];
        } else {
            [self serverUnknownError:httpStatusCode];
        }
    }
}

- (void)serverError:(NSDictionary *)content {
    // Parse server error
    NSDictionary *error = [content objectForKey:RESP_ERROR_KEY];
    
    NSString* title;
    int code = [[error objectForKey:@"code"] intValue];
    switch (code) {
        case -3:
            title = NSLocalizedStringFromTable(@"ERROR_SERVER_DATA", @"WindMobile", nil);
            break;
            
        case -2:
            title = NSLocalizedStringFromTable(@"ERROR_SERVER_DATABASE", @"WindMobile", nil);
            break;
            
        default:
            title = NSLocalizedStringFromTable(@"ERROR_SERVER_UNKNOWN", @"WindMobile", nil);
            break;
    }
    
    NSString* message = [error objectForKey:@"message"];
    if(stationListSender != nil && [stationListSender respondsToSelector:@selector(serverError:message:)]){
		[stationListSender serverError:title message:message];
	}
	if(stationDataSender != nil && [stationDataSender respondsToSelector:@selector(serverError:message:)]){
		[stationDataSender serverError:title message:message];
	}
	if(stationGraphDataSender != nil && [stationGraphDataSender respondsToSelector:@selector(serverError:message:)]){
		[stationGraphDataSender serverError:title message:message];
	}
}

- (void)serverUnknownError:(NSInteger)httpStatusCode {
    NSString* title = NSLocalizedStringFromTable(@"ERROR_SERVER_UNKNOWN", @"WindMobile", nil);
    
    NSString* message;
	if (httpStatusCode != -1) {
		message = [NSHTTPURLResponse localizedStringForStatusCode:httpStatusCode];
	} else {
		message = NSLocalizedStringFromTable(@"ERROR_SERVER_UNKNOWN", @"WindMobile", nil);
	}
    
    if(stationListSender != nil && [stationListSender respondsToSelector:@selector(serverError:message:)]){
		[stationListSender serverError:title message:message];
	}
	if(stationDataSender != nil && [stationDataSender respondsToSelector:@selector(serverError:message:)]){
		[stationDataSender serverError:title message:message];
	}
	if(stationGraphDataSender != nil && [stationGraphDataSender respondsToSelector:@selector(serverError:message:)]){
		[stationGraphDataSender serverError:title message:message];
	}
}

- (void)connectionError:(NSError *)error {
    NSString* title = NSLocalizedStringFromTable(@"ERROR_NETWORK", @"WindMobile", nil);
    
    NSString* message;
	if(error != nil){
		message = [error localizedDescription];
	} else {
		message = NSLocalizedStringFromTable(@"ERROR_NETWORK", @"WindMobile", nil);
	}
	
	if(stationListSender != nil && [stationListSender respondsToSelector:@selector(connectionError:message:)]){
		[stationListSender connectionError:title message:message];
	}
	if(stationDataSender != nil && [stationDataSender respondsToSelector:@selector(connectionError:message:)]){
		[stationDataSender connectionError:title message:message];
	}
	if(stationGraphDataSender != nil && [stationGraphDataSender respondsToSelector:@selector(connectionError:message:)]){
		[stationGraphDataSender connectionError:title message:message];
	}
}

+ (void)showError:(NSString*)title message:(NSString*)message{
	UIAlertView * alert = [[UIAlertView alloc] initWithTitle:title
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
	[stationInfos release];
	[stationInfo release];
	[content release];
	return response;
}

- (NSMutableDictionary*)mockStationData{
	NSMutableDictionary *response = [NSMutableDictionary dictionaryWithCapacity:2]; 
	NSDictionary* serie = [NSDictionary dictionaryWithObjectsAndKeys: @"windDirection", @"@name",
						   [NSArray arrayWithObjects:
							[NSDictionary dictionaryWithObjectsAndKeys: @"1298473200000", @"date", @"300.0", @"value", nil], 
							[NSDictionary dictionaryWithObjectsAndKeys: @"1298473800000", @"date", @"246.0", @"value", nil], 
							[NSDictionary dictionaryWithObjectsAndKeys: @"1298474400000", @"date", @"241.0", @"value", nil], 
							[NSDictionary dictionaryWithObjectsAndKeys: @"1298475000000", @"date", @"233.0", @"value", nil], 
							[NSDictionary dictionaryWithObjectsAndKeys: @"1298475600000", @"date", @"234.0", @"value", nil], 
							[NSDictionary dictionaryWithObjectsAndKeys: @"1298476200000", @"date", @"232.0", @"value",nil], 
							[NSDictionary dictionaryWithObjectsAndKeys: @"1298476800000", @"date", @"228.0", @"value",nil], 
							nil], @"points",
						   nil];
	
	NSDictionary* chart = [NSDictionary dictionaryWithObjectsAndKeys:
						   @"3600", @"duration",
						   serie, @"serie",
						   nil];
	
	NSDictionary* stationData = [NSDictionary dictionaryWithObjectsAndKeys:
								 @"2011-02-24T09:00:00+0100", @"@expirationDate",
								 @"2011-02-23T17:00:00+0100", @"@lastUpdate",
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
	NSDictionary *content = [NSDictionary dictionaryWithObjectsAndKeys:
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
	
	NSDictionary *content = [NSDictionary dictionaryWithObjectsAndKeys:
							 stationGraph, @"chart",
							 nil];
	[response setObject:content forKey:@"content"];
	return response;
}

@end
