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
    /*
    CGFloat locations[2];
    CGColorSpaceRef colorSpeceRef = CGColorSpaceCreateDeviceRGB();
    NSMutableArray *colors = [NSMutableArray arrayWithCapacity:2];
    
    [colors addObject:(id)[UIColor colorWithRed:0.8 green:0.8 blue:0.8 alpha:1.0].CGColor];
    locations[0] = 0.0;
    
    [colors addObject:(id)[UIColor colorWithRed:0.5 green:0.5 blue:0.5 alpha:1.0].CGColor];
    locations[1] = 1.0;

    
    CGGradientRef gradientRef = CGGradientCreateWithColors(colorSpeceRef, (CFArrayRef)colors, locations);
    CGContextDrawLinearGradient(context, gradientRef, 
                                CGPointMake(fullRect.origin.x, fullRect.origin.y), 
                                CGPointMake(fullRect.origin.x, fullRect.origin.y+fullRect.size.height), 
                                kCGGradientDrawsAfterEndLocation);
    */
    
    CGContextSetFillColorWithColor(context, [UIColor scrollViewTexturedBackgroundColor].CGColor);
    CGContextFillRect(context, fullRect);

    // draw upper separation
    CGContextSetStrokeColorWithColor(context,[UIColor blackColor].CGColor);
    CGContextMoveToPoint(context, self.bounds.origin.x,self.bounds.origin.y);
    CGContextAddLineToPoint(context, self.bounds.origin.x+self.bounds.size.width-1,self.bounds.origin.y);
    CGContextStrokePath(context);
    
    CGContextSetStrokeColorWithColor(context,[UIColor whiteColor].CGColor);
    CGContextMoveToPoint(context, self.bounds.origin.x,self.bounds.origin.y+1);
    CGContextAddLineToPoint(context, self.bounds.origin.x+self.bounds.size.width-1,self.bounds.origin.y+1);
    CGContextStrokePath(context);

    //CGGradientRelease(gradientRef);
    //CGColorSpaceRelease(colorSpeceRef);
    
    
}


- (void)dealloc
{
    [inputTextView release];
    [sendButton release];
    [super dealloc];
}

@end
