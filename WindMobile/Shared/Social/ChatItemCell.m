//
//  ChatItemCell.m
//  MicroChatter
//
//  Created by David on 5/6/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "ChatItemCell.h"

#define ITEM_OFFSET_X  10
#define ITEM_OFFSET_Y  10

@implementation ChatItemCell

@synthesize selfMessage;
@synthesize textFont;
@synthesize pseudoFont;
@synthesize timeFont;
@synthesize tempMessage;

/*
 * Format the duration to display soemthing usefull for user
 * 
 */
- (NSString *)whenString 
{
    if ( !when ) {
        return NSLocalizedStringFromTable(@"CHAT_SENDING_MESSAGE", @"WindMobile", nil);
    }
    NSTimeInterval interval = -[when timeIntervalSinceNow];
    if ( interval < 60 ) {
        return NSLocalizedStringFromTable(@"CHAT_TIME_NOW", @"WindMobile", nil);
    }
    if ( interval < 60*60) {
        int rest = (int)(interval/60.0);
        if ( rest > 1 ) {
            return [NSString stringWithFormat:NSLocalizedStringFromTable(@"CHAT_TIME_MINUTEs", @"WindMobile", nil),rest];
        } else {
            return [NSString stringWithFormat:NSLocalizedStringFromTable(@"CHAT_TIME_MINUTE", @"WindMobile", nil),rest];
        }
    }
    if ( interval < 60*60*24) {
        int rest = (int)(interval/(60*60));
        if ( rest > 1 ) {
            return [NSString stringWithFormat:NSLocalizedStringFromTable(@"CHAT_TIME_HOURs", @"WindMobile", nil),rest];
        } else {
            return [NSString stringWithFormat:NSLocalizedStringFromTable(@"CHAT_TIME_HOUR", @"WindMobile", nil),rest];
        }
    }
    if ( interval < 60*60*24*365) {
        int rest = (int)(interval/(60*60*24));
        if ( rest > 1 ) {
            return [NSString stringWithFormat:NSLocalizedStringFromTable(@"CHAT_TIME_DAYs", @"WindMobile", nil),rest];
        } else {
            return [NSString stringWithFormat:NSLocalizedStringFromTable(@"CHAT_TIME_DAY", @"WindMobile", nil),rest];
        }
    }
    return [when description];
}

- (void)drawRect:(CGRect)rect
{        
    CGContextRef context = UIGraphicsGetCurrentContext();
        
    CGRect fullRect =[self frame];
    CGRect textRect = CGRectMake(fullRect.origin.x + ITEM_OFFSET_X + 2, 
                                       fullRect.origin.y+ ITEM_OFFSET_Y + [pseudoFont lineHeight],
                                       fullRect.size.width - ( 2* ITEM_OFFSET_X), 
                                       fullRect.size.height - ( 2* ITEM_OFFSET_X) );
    
    CGPoint pseudoPoint = CGPointMake(fullRect.origin.x + ITEM_OFFSET_X+2, 
                                     fullRect.origin.y+ ITEM_OFFSET_Y);
    NSString *whenStr = [self whenString];
    CGSize whenSize = [whenStr sizeWithFont:timeFont];
    
    CGPoint whenPoint = CGPointMake(fullRect.origin.x + fullRect.size.width-ITEM_OFFSET_X-whenSize.width, 
                                      fullRect.origin.y+ ITEM_OFFSET_Y);
    
    [self drawRoundedRect:fullRect];
    
    CGContextSetFillColorWithColor(context, [UIColor darkGrayColor].CGColor);
    [whenStr drawAtPoint:whenPoint withFont:timeFont];
    
    CGContextSetFillColorWithColor(context, [UIColor blackColor].CGColor);
    [pseudo drawAtPoint:pseudoPoint withFont:pseudoFont];
    
    CGContextSetFillColorWithColor(context, [UIColor blackColor].CGColor);
    [text drawInRect:textRect withFont:textFont];
    
}


-(void)drawRoundedRect:(CGRect)rect
{
    CGFloat shadowSize = 4;
    CGFloat cornerRadius = 4;
    CGContextRef context = UIGraphicsGetCurrentContext();
    
    //for the shadow, save the state then draw the shadow
    CGContextSaveGState(context);
    CGContextSetShadow(context, CGSizeMake(shadowSize,shadowSize), 5);
    
    
    
    //now draw the rounded rectangle
    CGContextSetStrokeColorWithColor(context, [[UIColor blackColor] CGColor]);
    CGContextSetRGBFillColor(context, 0.0, 0.0, 1.0, 1.0);
    
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
    CGContextAddLineToPoint(context, minx-5, miny+15);
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
    
    CGContextSetLineWidth(context, 2.0);
    
    CGFloat* colors;
    if ( selfMessage ) {
        CGFloat t_colors[] = {0.8,1.0,0.8, 1.0,
            0.5,0.85,0.5, 1.0};
        colors = t_colors;
        CGContextSetStrokeColorWithColor(context, [UIColor colorWithRed:0.0 green:0.5 blue:0.0 alpha:1.0].CGColor);

    } else if ( tempMessage ) {
        CGFloat t_colors[] = {0.9,0.9,0.9, 1.0,
            0.7,0.7,0.7, 1.0};
        colors = t_colors;
        CGContextSetStrokeColorWithColor(context, [UIColor colorWithRed:0.5 green:0.5 blue:0.5 alpha:1.0].CGColor);
        
    } else {
        CGFloat t_colors[] = {0.7,0.8,0.9, 1.0,
            0.5,0.6,0.85, 1.0};
        colors = t_colors;
        CGContextSetStrokeColorWithColor(context, [UIColor colorWithRed:0.0 green:0.1 blue:0.5 alpha:1.0].CGColor);

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

-(void) setText:(NSString*)t withPseudo:(NSString*)p at:(NSDate *)w
{
    [pseudo autorelease];
    [text autorelease];
    [when autorelease];
    
    pseudo = [p retain];
    text = [t retain];
    when = [w retain];
      
}

-(NSString*)text
{
    return text;
}

-(NSString*)pseudo
{
    return pseudo;
}

-(NSDate*)when
{
    return when;
}

-(void)dealloc
{
    [text release];
    [pseudo release];
    [when release];
    [pseudoFont release];
    [textFont release];
    [timeFont release];
    [super dealloc];
}

@end
