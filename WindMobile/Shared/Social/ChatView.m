//
//  ChatView.m
//  MicroChatter
//
//  Created by David on 5/5/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "ChatView.h"
#import "ChatItem.h"
#import "ChatItemCell.h"

#import <UIKit/UIKit.h>
#import <Foundation/Foundation.h>


#define ITEM_OFFSET_X  10
#define ITEM_OFFSET_Y  10

@implementation ChatView


NSArray* cells = nil;


@synthesize textFont;
@synthesize pseudoFont;
@synthesize timeFont;
@synthesize loading;

- (void)setupView 
{
    self.textFont = [[UIFont fontWithName:@"Helvetica" size:14] retain];
    self.pseudoFont = [[UIFont fontWithName:@"Helvetica-Bold" size:14] retain];
    self.timeFont = [[UIFont fontWithName:@"Helvetica-Oblique" size:14] retain];

    [self setBackgroundColor:[UIColor whiteColor]];
}

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if ( self ) {
        [self setupView];
    }
    return self;
}


-(id)initWithCoder:(NSCoder *)aDecoder
{
    self = [super initWithCoder:aDecoder];
    if ( self ) {
        [self setupView];
    }
    return self;
}


-(void)setChatItems:(NSArray *)items
{
    loading = NO;
    NSMutableArray *tmpCells = [[NSMutableArray alloc] init];
    
    CGFloat width = [[self superview] bounds].size.width;
    
    ChatItem *item;
    CGFloat yPos = 0;
    CGFloat textWidth = width-(( ITEM_OFFSET_X));
    CGSize maximumLabelSize = CGSizeMake(textWidth-ITEM_OFFSET_X-4,9999);
    
    for ( item in items ) {
        NSString* message = [NSString stringWithFormat:@"\n%@",item.message];
        CGSize size = [message sizeWithFont:textFont constrainedToSize:maximumLabelSize lineBreakMode:UILineBreakModeWordWrap];        
        CGFloat height = size.height+( 2* ITEM_OFFSET_Y);
        CGRect frame = CGRectMake(0, yPos, textWidth, height);
        ChatItemCell *cell = [[ChatItemCell alloc] initWithFrame:frame];
        cell.pseudoFont = pseudoFont;
        cell.textFont = textFont;
        cell.timeFont = timeFont;
        cell.selfMessage = item.selfMessage;
        [cell setText:item.message withPseudo:item.pseudo at:item.date];
        [tmpCells addObject:[cell autorelease]];
        yPos += height;
        
    }
    if ( yPos == 0 ) {
        // let's some space to write the "no message" info
        yPos += 50.0;
    }
    
    yPos += 8 ; // to display shadow
    
    // set the content size so it can be scrollable
    // animate
    [self setFrame:CGRectMake(0, 0, width, yPos)];
    
    [cells autorelease];
    cells = tmpCells;    
    [(UIScrollView*)[self superview] setContentSize:CGSizeMake(width, yPos)];
    [self setNeedsDisplay];
    [(UIScrollView*)[self superview] scrollRectToVisible:CGRectMake(0,yPos-1,1, 1) animated:YES];
}


- (void)dealloc
{
    [cells release];
    [textFont release];
    [pseudoFont release];

    [super dealloc];
}



- (void)drawRect:(CGRect)rect
{
    ChatItemCell *cell;
    if ( [cells count] == 0 ) {
        //----- Draw the no message info
        NSString *message;
        if ( loading ) {
            message = NSLocalizedStringFromTable(@"CHAT_MESSAGES_LOADING", @"WindMobile", nil);
        } else {
            message = NSLocalizedStringFromTable(@"CHAT_MESSAGES_EMPTY", @"WindMobile", nil);
        }
        
        // draw place holder
        CGSize maximumLabelSize = CGSizeMake(self.bounds.size.width, 9999);
        CGSize size = [message sizeWithFont:self.pseudoFont constrainedToSize:maximumLabelSize lineBreakMode:UILineBreakModeWordWrap];        
        CGRect drawRect = CGRectMake(self.bounds.origin.x+ ((self.bounds.size.width - size.width)/2),
                                     self.bounds.origin.y+ ((self.bounds.size.height - size.height)/2),
                                     size.width,
                                     size.height);
        CGContextRef context = UIGraphicsGetCurrentContext();
        CGContextSetFillColorWithColor(context,[UIColor lightGrayColor].CGColor);
        [message drawInRect:drawRect withFont:self.pseudoFont];
        CGContextSetStrokeColorWithColor(context,[UIColor darkGrayColor].CGColor);

        
    } else {
        for ( cell in cells ) {
            if ( CGRectIntersectsRect(rect, [cell frame]) ){
                [cell drawRect:rect];
            }
        }
    }
}

-(void)addTemporaryMessage:(NSString *)newMessage 
{
    // add a new cell at the end with temporary look
    CGFloat width = [[self superview] bounds].size.width;
    
    CGFloat yPos = [self bounds].size.height - 12.0;
    
    CGFloat textWidth = width-( ITEM_OFFSET_X);
    CGSize maximumLabelSize = CGSizeMake(textWidth,9999);
 
    NSString* message = [NSString stringWithFormat:@"\n%@",newMessage];
    CGSize size = [message sizeWithFont:textFont constrainedToSize:maximumLabelSize lineBreakMode:UILineBreakModeWordWrap];        
    CGFloat height = size.height+( 2* ITEM_OFFSET_Y);
    CGRect frame = CGRectMake(6, yPos, textWidth, height);
    ChatItemCell *cell = [[ChatItemCell alloc] initWithFrame:frame];
    cell.pseudoFont = pseudoFont;
    cell.textFont = textFont;
    cell.timeFont = timeFont;
    cell.tempMessage = YES;

    [cell setText:newMessage withPseudo:@"" at:nil];
    [(NSMutableArray*)cells addObject:[cell autorelease]];
    yPos += height;
    yPos += 12.0;
    
    // set the content size so it can be scrollable
    // animate
    [self setFrame:CGRectMake(0, 0, width, yPos)];
        
    [(UIScrollView*)[self superview] setContentSize:CGSizeMake(width, yPos)];
    // do not sroll here
    //[(UIScrollView*)[self superview] scrollRectToVisible:CGRectMake(0,yPos-1,1, 1) animated:NO];
    [self setNeedsDisplay];

}

@end
