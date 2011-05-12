//
//  ChatItem.m
//  MicroChatter
//
//  Created by David on 5/5/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "ChatItem.h"
#import <Foundation/Foundation.h>

@implementation ChatItem

@synthesize message;
@synthesize pseudo;
@synthesize date;
@synthesize selfMessage;

- (id)initWithPseudo:(NSString *)p message:(NSString *)m date:(NSDate*) d 
{
    self.date = d;
    self.message = m;
    self.pseudo = p;
    self.selfMessage = NO;
    return self;
}

- (NSString*)displayMessage
{
    return [NSString stringWithFormat:@"[%@] : %@",self.pseudo,self.message];
}

-(void)dealloc
{
    [date release];
    [message release];
    [pseudo release];
    [super dealloc];
}

@end
