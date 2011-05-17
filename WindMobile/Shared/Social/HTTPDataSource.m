//
//  HTTPDataSource.m
//  MiniChatter
//
//  Created by David on 5/9/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "HTTPDataSource.h"
#import "ASIHTTPRequest.h"
#import "JSON.h"
#import "ChatItem.h"
#import "StationItem.h"
#import "WMReSTClient.h"

//http://windmobile.vol-libre-suchet.ch:1588/windmobile/chatrooms/test/lastmessages/30

#define URL_CHAT_MESSAGES_GET @"http://%@:%d/windmobile/chatrooms/%@/lastmessages/30"

//http://windmobile.vol-libre-suchet.ch:1588/windmobile/chatrooms/test/postmessage
#define URL_CHAT_MESSAGE_POST @"http://%@:%d/windmobile/chatrooms/%@/postmessage"

//http://windmobile.vol-libre-suchet.ch:1588/windmobile/stationinfos?allStation=true
#define URL_STATION_GET @"http://%@:%d/windmobile/stationinfos?allStation=%@"
#define TIME_OUT_IN_SECONDS = 20

@implementation HTTPDataSource

- (id)init {
    self = [super init];
    if (self) {
        
    }
    return self;
}


- (NSArray*) getChatItems:(NSString *)chatRoomId
{
    static NSString *MessageKey = @"message";
    NSString *encodedString =  (NSString *)CFURLCreateStringByAddingPercentEscapes(NULL,
                                                                                   (CFStringRef)chatRoomId,
                                                                                   NULL,
                                                                                   (CFStringRef)@"!*'\"();:@&=+$,/?%#[]% ",
                                                                                   CFStringConvertNSStringEncodingToEncoding(NSUTF8StringEncoding));
    NSString *urlString = [NSString stringWithFormat:URL_CHAT_MESSAGES_GET,REST_SERVER,REST_PORT,encodedString];
    NSURL *url = [NSURL URLWithString:urlString];
    
   // NSLog(@"Request on URL : %@",url);
    ASIHTTPRequest *request = [ASIHTTPRequest requestWithURL:url];
    [request setUseCookiePersistence:true];
    [request addRequestHeader:@"Accept" value:@"application/json"];
    [request buildRequestHeaders];
    [request setTimeOutSeconds:5];
    [request startSynchronous];
    NSString *result = [request responseString];
   // NSLog(@"Result : %@",result);
    SBJsonParser *parser = [[SBJsonParser alloc] init];
    id resutlAsObject = [parser objectWithString:result];
    [parser release];
   // NSLog(@"Result : %@",resutlAsObject);
    NSArray *listOfMessage = [(NSDictionary*)resutlAsObject objectForKey:MessageKey];
    if ( !listOfMessage ) {
        return nil;
    }
    if ( [listOfMessage isKindOfClass:[NSDictionary class]] ) {
        //why do we receive a single object only ??? Is it JAX-RS problem ???
        listOfMessage = [NSArray arrayWithObject:listOfMessage];
    }
    if ( ![listOfMessage isKindOfClass:[NSArray class]] ) {
        NSException* myException = [NSException
                                    exceptionWithName:@"ServerErrorException"
                                    reason:@"Invalid server response"
                                    userInfo:nil];
        @throw myException;
    }
    return [self parseItemsResult:listOfMessage];
}

- (NSArray *)parseItemsResult:(NSArray *)jsonObjects
{
    static NSString *DateKey = @"date";
    static NSString *PseudoKey = @"pseudo";
    static NSString *TextKey = @"text";

    NSMutableArray *result = [NSMutableArray array];
    NSDictionary *objectAsDict;
    for ( objectAsDict in jsonObjects) {
        NSString *dateAsStr = [objectAsDict objectForKey:DateKey];
        NSString *pseudoAsStr = [objectAsDict objectForKey:PseudoKey];
        NSString *textAsStr = [objectAsDict objectForKey:TextKey];
        NSDate *when = [self formatDate:dateAsStr];
        [result insertObject:[[[ChatItem alloc] initWithPseudo:pseudoAsStr message:textAsStr date:when] autorelease] atIndex:0];
    }
    return result;
}

- (NSDate *)formatDate:(NSString *)rfc3339DateTimeString
{
    NSDateFormatter *   rfc3339DateFormatter;
    NSLocale *          enUSPOSIXLocale;
    NSDate *            result;
    
    // Convert the RFC 3339 date time string to an NSDate.
    
    rfc3339DateFormatter = [[[NSDateFormatter alloc] init] autorelease];
    
    enUSPOSIXLocale = [[[NSLocale alloc] initWithLocaleIdentifier:@"en_US_POSIX"] autorelease];
    
    [rfc3339DateFormatter setLocale:enUSPOSIXLocale];
    [rfc3339DateFormatter setDateFormat:@"yyyy'-'MM'-'dd'T'HH':'mm':'ssZ"];
    [rfc3339DateFormatter setTimeZone:[NSTimeZone timeZoneForSecondsFromGMT:0]];
    
    result =  [rfc3339DateFormatter dateFromString:rfc3339DateTimeString];
    
    return result;
}

- (void)postMessage:(NSString *)message withIdentifier:(NSString *)identifier onChatRoom:(NSString *)chatRoomId 
{
    NSString *encodedString =  (NSString *)CFURLCreateStringByAddingPercentEscapes(NULL,
                                                                               (CFStringRef)chatRoomId,
                                                                               NULL,
                                                                               (CFStringRef)@"!*'\"();:@&=+$,/?%#[]% ",
                                                                               CFStringConvertNSStringEncodingToEncoding(NSUTF8StringEncoding));
    
    NSString *urlString = [NSString stringWithFormat:URL_CHAT_MESSAGE_POST,REST_SERVER,REST_PORT,encodedString];
    NSURL *url = [NSURL URLWithString:urlString];
   // NSLog(@"Request on URL : %@",url);
    ASIHTTPRequest *request = [ASIHTTPRequest requestWithURL:url];
    [request setRequestMethod:@"POST"];
    [request setUsername:[[NSUserDefaults standardUserDefaults] stringForKey:SOCIAL_USERNAME]];
    [request setPassword:[[NSUserDefaults standardUserDefaults] stringForKey:SOCIAL_PASSWORD]];
    [request setAuthenticationScheme:(NSString *)kCFHTTPAuthenticationSchemeBasic];
    [request setUseSessionPersistence:YES];
	[request setUseKeychainPersistence:NO];
    [request setShouldPresentCredentialsBeforeChallenge:YES];
    [request addRequestHeader:@"Content-Type" value:@"text/plain"];
	[request setTimeOutSeconds:[[NSUserDefaults standardUserDefaults]doubleForKey:TIMEOUT_KEY]];
	[request setPostBody:[NSMutableData dataWithData:[message dataUsingEncoding:NSUTF8StringEncoding]]];
    [request buildRequestHeaders];

    [request startSynchronous];
    int code = [request responseStatusCode];
    if ( code >=300 || code < 200 ) {
        NSString *reason = [NSString stringWithFormat:@"%d",code];
        if ( code == 0 ) {
            reason =  NSLocalizedStringFromTable(@"CHAT_TIMEOUT", @"WindMobile", nil);
        }
        NSException* myException = [NSException
                                    exceptionWithName:@"ServerErrorException"
                                    reason:reason
                                    userInfo:nil];
        @throw myException;
    }
}

- (NSArray *)parseStationsResult:(NSArray *)jsonObjects
{
    static NSString *IdKey = @"@id";
    static NSString *NameKey = @"@name";
    static NSString *MaintenanceKey = @"@maintenanceStatus";
    static NSString *AltitudeKey = @"@altitude";

    NSMutableArray *result = [NSMutableArray array];
    NSDictionary *objectAsDict;
    for ( objectAsDict in jsonObjects) {
        NSString *idStr = [objectAsDict objectForKey:IdKey];
        NSString *nameStr = [objectAsDict objectForKey:NameKey];
        NSString *altitudeStr = [objectAsDict objectForKey:AltitudeKey];
        NSString *statusStr = [objectAsDict objectForKey:MaintenanceKey];
        StationItem *item = [StationItem itemWithId:idStr displayName:nameStr altitude:altitudeStr maintenanceStatus:statusStr];
        [result addObject:item];
    }
    return result;
}

-(NSArray *)getStationList
{
    static NSString *StationInfoKey = @"stationInfo";
    
    NSString *urlString = [NSString stringWithFormat:URL_STATION_GET,REST_SERVER,REST_PORT,@"yes"];
    urlString = [urlString stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
    NSURL *url = [NSURL URLWithString:urlString];
   // NSLog(@"Request on URL : %@",url);
    ASIHTTPRequest *request = [ASIHTTPRequest requestWithURL:url];
    [request setUseCookiePersistence:true];
    [request addRequestHeader:@"Accept" value:@"application/json"];
    [request buildRequestHeaders];
    [request setTimeOutSeconds:[[NSUserDefaults standardUserDefaults]doubleForKey:TIMEOUT_KEY]];
    [request startSynchronous];
    NSString *result = [request responseString];
   // NSLog(@"Result : %@",result);
    SBJsonParser *parser = [[SBJsonParser alloc] init];
    id resutlAsObject = [parser objectWithString:result];
    [parser release];
   //  NSLog(@"JSON Result : %@",resutlAsObject);
    
    NSArray *listOfStation = [(NSDictionary*)resutlAsObject objectForKey:StationInfoKey];
    if ( !listOfStation ) {
        return nil;
    }
    if ( [listOfStation isKindOfClass:[NSDictionary class]] ) {
        //why do we receive a single object only ??? Is it JAX-RS problem ???
        listOfStation = [NSArray arrayWithObject:listOfStation];
    }
    if ( ![listOfStation isKindOfClass:[NSArray class]] ) {
        NSException* myException = [NSException
                                    exceptionWithName:@"ServerErrorException"
                                    reason:@"Invalid server response"
                                    userInfo:nil];
        @throw myException;
    }
    return [self parseStationsResult:listOfStation];
}


-(void)dealloc 
{
    [super dealloc];
}

@end
