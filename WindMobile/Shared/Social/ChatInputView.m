//
//  GradientView.m
//  MicroChatter
//
//  Created by David on 5/6/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "ChatInputView.h"


@implementation ChatInputView


- (void)setupView
{
}

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        [self setupView];
    }
    return self;
}

- (id)initWithCoder:(NSCoder *)aDecoder
{
    self = [super initWithCoder:aDecoder];
    if ( self ) {
        [self setupView];
    }
    return self;
}

- (void)drawRect:(CGRect)rect
{
    CGContextRef context = UIGraphicsGetCurrentContext();
    
    CGRect fullRect = [self bounds];
    // pain the gradiant background

    CGContextSetFillColorWithColor(context, [UIColor scrollViewTexturedBackgroundColor].CGColor);
    CGContextFillRect(context, fullRect);

    // draw upper separation
    CGContextSetStrokeColorWithColor(context,[UIColor blackColor].CGColor);
    CGContextMoveToPoint(context, self.bounds.origin.x,self.bounds.origin.y);
    CGContextAddLineToPoint(context, self.bounds.origin.x+self.bounds.size.width-1,self.bounds.origin.y);
    CGContextStrokePath(context);
    
    // draw upper separation ( extruded )
    CGContextSetStrokeColorWithColor(context,[UIColor whiteColor].CGColor);
    CGContextMoveToPoint(context, self.bounds.origin.x,self.bounds.origin.y+1);
    CGContextAddLineToPoint(context, self.bounds.origin.x+self.bounds.size.width-1,self.bounds.origin.y+1);
    CGContextStrokePath(context);

    
}


- (void)dealloc
{
    [inputTextView release];
    [sendButton release];
    [super dealloc];
}

@end
