//
//  ChatItemCell.h
//  MicroChatter
//
//  Created by David on 5/6/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>


@interface ChatItemCell : UIView {

@private 
    NSString *text;
    NSString *pseudo;
    NSDate *when;
    
    BOOL selfMessage;
    BOOL tempMessage;
    UIFont *textFont;
    UIFont *pseudoFont;
    UIFont *timeFont;

}

@property ( readwrite ) BOOL selfMessage;
@property ( readwrite ) BOOL tempMessage;
@property ( readwrite,retain ) UIFont* textFont;
@property ( readwrite,retain ) UIFont* pseudoFont;
@property ( readwrite,retain ) UIFont* timeFont;

-(void)drawRoundedRect:(CGRect)rect;
-(void) setText:(NSString*)m withPseudo:(NSString*) pseudo at:(NSDate *)date;
-(NSString *)text;
-(NSString *)pseudo;
-(NSDate *)when;

@end
