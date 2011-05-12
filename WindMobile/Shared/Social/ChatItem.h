//
//  ChatItem.h
//  MicroChatter
//
//  Created by David on 5/5/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>


@interface ChatItem : NSObject {
@private
    NSString* message;
    NSString* pseudo;
    NSDate* date;
    Boolean selfMessage;
}

- (id)initWithPseudo:(NSString *)pseudo message:(NSString *)message date:(NSDate*) date;
- (NSString*)displayMessage;

@property (readwrite,retain) NSString* message;
@property (readwrite,retain) NSString* pseudo;
@property (readwrite,retain) NSDate* date;
@property (readwrite) Boolean selfMessage;

@end
