//
//  MessageTextView.m
//  MicroChatter
//
//  Created by David on 5/6/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "MessageTextView.h"


@implementation MessageTextView

-(void)setContentInset:(UIEdgeInsets)s
{
	UIEdgeInsets insets = s;
    
	if(s.bottom>8) insets.bottom = 0;
	insets.top = 0;
    
	[super setContentInset:insets];
}


-(void)setFresh
{
    self.text = @"";
    [self setNeedsDisplay];
}

-(void) drawRect:(CGRect)rect
{
    [super drawRect:rect];
    CGContextRef context = UIGraphicsGetCurrentContext();

    if ( ![self isFirstResponder] ) {
        NSString *message = NSLocalizedStringFromTable(@"CHAT_TOUCH_HERE", @"WindMobile", nil);
        // draw place holder
        CGSize maximumLabelSize = CGSizeMake(self.bounds.size.width - 40, 9999);
        CGSize size = [message sizeWithFont:self.font constrainedToSize:maximumLabelSize lineBreakMode:UILineBreakModeWordWrap];        
        CGRect drawRect = CGRectMake(self.bounds.origin.x+ ((self.bounds.size.width - size.width)/2),
                                     self.bounds.origin.y+ ((self.bounds.size.height - size.height)/2),
                                     size.width,
                                     size.height);
        CGContextRef context = UIGraphicsGetCurrentContext();
        CGContextSetFillColorWithColor(context,[UIColor lightGrayColor].CGColor);
        [message drawInRect:drawRect withFont:self.font];
        CGContextSetStrokeColorWithColor(context,[UIColor darkGrayColor].CGColor);
    } else {
        CGContextSetStrokeColorWithColor(context,[UIColor colorWithRed:0.5 green:0.5 blue:0.8 alpha:1.0].CGColor);
    }
    

    CGContextSetLineWidth(context, 3.0);
    CGContextStrokeRect(context, self.bounds);
    
}

@end
