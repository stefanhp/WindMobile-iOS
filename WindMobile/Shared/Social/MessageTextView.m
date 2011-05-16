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
    insets.left = 5;
    insets.right = 5;

	[super setContentInset:insets];
}


-(void)setFresh
{
    self.text = @"";
    [self setNeedsDisplay];
}

-(void)drawRoundedRect:(CGRect)rect
{
    CGFloat shadowSize = 3;
    CGFloat cornerRadius = 5;
    CGContextRef context = UIGraphicsGetCurrentContext();
    
    //for the shadow, save the state then draw the shadow
    CGContextSaveGState(context);
    //CGContextSetShadow(context, CGSizeMake(shadowSize,shadowSize), 5);
    
    
    
    //now draw the rounded rectangle
    CGContextSetStrokeColorWithColor(context, [[UIColor blackColor] CGColor]);
    CGContextSetRGBFillColor(context, 1.0, 1.0, 1.0, 0.9);
    
    //since I need room in my rect for the shadow, make the rounded rectangle a little smaller than frame
    CGRect rrect = CGRectMake(CGRectGetMinX(rect)+(2*shadowSize), CGRectGetMinY(rect)+(2*shadowSize), CGRectGetWidth(rect)-(3*shadowSize), CGRectGetHeight(rect)-(3*shadowSize));

    CGFloat radius = cornerRadius;
    // the rest is pretty much copied from Apples example
    CGFloat minx = CGRectGetMinX(rrect), midx = CGRectGetMidX(rrect), maxx = CGRectGetMaxX(rrect);
    CGFloat miny = CGRectGetMinY(rrect), midy = CGRectGetMidY(rrect), maxy = CGRectGetMaxY(rrect);
    
    // Start at 1
    CGContextMoveToPoint(context, minx, midy);
    
    // tick
    CGContextAddLineToPoint(context, minx, miny+20);
    CGContextAddLineToPoint(context, minx-3, miny+15);
    CGContextAddLineToPoint(context, minx, miny+10);
    
    // Add an arc through 2 to 3
    CGContextAddArcToPoint(context, minx, miny, midx, miny, radius);
    // Add an arc through 4 to 5
    CGContextAddArcToPoint(context, maxx, miny, maxx, midy, radius);
    // Add an arc through 6 to 7
    CGContextAddArcToPoint(context, maxx, maxy, midx, maxy, radius);
    // Add an arc through 8 to 9
    CGContextAddArcToPoint(context, minx, maxy, minx, midy, radius);
    // Close the path
    CGContextClosePath(context);
    CGPathRef pathRef = CGContextCopyPath(context);
    
    CGContextSetLineWidth(context, 3.0);
    
    CGFloat colors[] = {1.0,1.0,1.0, 1.0,
                        0.9,0.9,0.9, 1.0};
    if ( [self isFirstResponder] ) {
        CGContextSetStrokeColorWithColor(context,[UIColor colorWithRed:0.5 green:0.5 blue:1.0 alpha:1.0].CGColor);
    } else {
        CGContextSetStrokeColorWithColor(context, [UIColor colorWithRed:0.0 green:0.0 blue:0.0 alpha:0.8].CGColor);
    }
        
    
    // Fill & stroke the path
    CGContextDrawPath(context, kCGPathFillStroke);
    
    // pain the gradiant background
    CGContextAddPath(context,pathRef);
    CGContextClip(context);
    CGColorSpaceRef colorSpeceRef = CGColorSpaceCreateDeviceRGB();
    CGGradientRef gradientRef = CGGradientCreateWithColorComponents(colorSpeceRef, colors, NULL, 2);
    CGContextDrawLinearGradient(context, gradientRef, 
                                CGPointMake(rrect.origin.x, rrect.origin.y), 
                                CGPointMake(rrect.origin.x, rrect.origin.y+rrect.size.height), 
                                kCGGradientDrawsAfterEndLocation);
    
    
    //for the shadow
    CGContextRestoreGState(context);
    
    //-- Release all
    CGGradientRelease(gradientRef);
    CGColorSpaceRelease(colorSpeceRef);
}

-(void) drawRect:(CGRect)rect
{
    [super drawRect:rect];
    
    [self drawRoundedRect:rect];
    
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
    
    
    //CGContextSetLineWidth(context, 3.0);
    //CGContextStrokeRect(context, self.bounds);
    
}

@end
