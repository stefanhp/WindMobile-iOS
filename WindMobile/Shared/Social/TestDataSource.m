//
//  TestDataSource.m
//  MicroChatter
//
//  Created by David on 5/5/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "TestDataSource.h"
#import "ChatItem.h"
#import "StationItem.h"

#define SLEEP_TIME_TEST 5.0

@implementation TestDataSource

NSMutableArray* array = nil;

+ (void)initialize
{
    array = [[NSMutableArray alloc] init];
    for (int i = 0; i < 20; i++) {
        NSString *mess = [NSString stringWithFormat:@"Hello this is a simple message number : %f",i];
        [array addObject:[[[ChatItem alloc] initWithPseudo:@"anonymous" message:mess date:[NSDate date]] autorelease]];
    }
    [array addObject:[[[ChatItem alloc] initWithPseudo:@"cedric" message:@"Hello this is a simple message\nWith a longer information\nHere it is" date:[NSDate date]] autorelease]];
    [array addObject:[[[ChatItem alloc] initWithPseudo:@"yann" message:@"Hello this is a simple me" date:[NSDate dateWithTimeIntervalSinceNow:-3620]] autorelease]];
    [array addObject:[[[ChatItem alloc] initWithPseudo:@"david" message:@"Hello this is a simple mess" date:[NSDate dateWithTimeIntervalSinceNow:-180]] autorelease]];
    [array addObject:[[[ChatItem alloc] initWithPseudo:@"vinc" message:@"Hello this is a simple message" date:[NSDate dateWithTimeIntervalSinceNow:-356789]] autorelease]];
}

- (NSArray*) getChatItems:(NSString *)chatRoomId
{
    sleep(SLEEP_TIME_TEST);
    return array;
}

- (void)postMessage:(NSString *)message withIdentifier:(NSString *)identifier onChatRoom:(NSString *)chatRoomId 
{
    NSLog(@"Posting message %@ : %@",identifier,message);
    sleep(SLEEP_TIME_TEST);
    ChatItem *item = [[[ChatItem alloc] initWithPseudo:identifier message:message date:[NSDate date]] autorelease];
    item.selfMessage = YES;
    [array addObject:item];
    NSLog(@"Posted !");
}

-(NSArray *)getStationList 
{
     sleep(SLEEP_TIME_TEST);
    return [NSArray arrayWithObject:[StationItem itemWithId:@"test" displayName:@"Test station"]];
}

@end
