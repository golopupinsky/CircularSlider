//
//  CircularSlider.m
//  CircularSlider
//
//  Created by Sergey Yuzepovich on 16.11.14.
//  Copyright (c) 2014 Sergey Yuzepovich. All rights reserved.
//

#import "CircularSlider.h"

#define BACKGROUND_WIDTH  40
#define BORDER_WIDTH  10

#define ToRad(deg) 		( (M_PI * (deg)) / 180.0 )
#define ToDeg(rad)		( (180.0 * (rad)) / M_PI )
#define SQR(x)			( (x) * (x) )

@implementation CircularSlider
{
    float angle;
    float radius;
    bool isOnTop;
}


-(void) drawRect: (CGRect) rect
{
    radius = MIN(self.frame.size.width,self.frame.size.height) / 3;
    
    CGContextRef ctx = UIGraphicsGetCurrentContext();
    [self drawBackground:ctx];
    [self drawFill:ctx];
    [self drawHandle:ctx];
    [self drawForeground:ctx];
}

-(void)drawBackground:(CGContextRef)ctx
{
    CGContextAddArc(ctx, self.frame.size.width/2, self.frame.size.height/2, radius, 0, M_PI*2, 0);
    
    [[UIColor blackColor]setStroke];
    
    CGContextSetLineWidth(ctx, BACKGROUND_WIDTH);
    CGContextSetLineCap(ctx, kCGLineCapRound);
    
    CGContextStrokePath(ctx);
}

-(void)drawFill:(CGContextRef)ctx
{
    CGContextSaveGState(ctx);
    
    UIGraphicsBeginImageContext(self.bounds.size);
    CGContextRef imageCtx = UIGraphicsGetCurrentContext();
    
    CGContextAddArc(imageCtx, self.frame.size.width/2 , self.frame.size.height/2, radius, 0, ToRad(angle), 0);
    [[UIColor redColor]setStroke];
    CGContextSetLineWidth(imageCtx, BACKGROUND_WIDTH);
    CGContextSetShadowWithColor(imageCtx, CGSizeMake(0, 0), angle/20, [UIColor blackColor].CGColor);
    
    CGContextStrokePath(imageCtx);
    
    CGImageRef mask = CGBitmapContextCreateImage(UIGraphicsGetCurrentContext());
    UIGraphicsEndImageContext();
    
    CGContextClipToMask(ctx, self.bounds, mask);
    CGImageRelease(mask);
    
    CGFloat *components;
    [self getColorsForAngle:angle outColors:&components ];
    
    CGColorSpaceRef baseSpace = CGColorSpaceCreateDeviceRGB();
    CGGradientRef gradient = CGGradientCreateWithColorComponents(baseSpace, components, NULL, 2);
    CGColorSpaceRelease(baseSpace);
    baseSpace=nil;
    
    
    if(self.gradientType == linearGradient)
    {
        CGPoint startPoint = CGPointMake(CGRectGetMidX(self.bounds), CGRectGetMinY(self.bounds));
        CGPoint endPoint = CGPointMake(CGRectGetMidX(self.bounds), CGRectGetMaxY(self.bounds));
        CGContextDrawLinearGradient(ctx, gradient, startPoint, endPoint, 0);
    }
    if(self.gradientType == radialGradient)
    {
        CGPoint centerPoint = CGPointMake(self.frame.size.width/2, self.frame.size.height/2);
        CGContextDrawRadialGradient(ctx, gradient, centerPoint, radius /2, centerPoint, radius + BACKGROUND_WIDTH + BORDER_WIDTH, 0);
    }
    if(self.gradientType == angularGradient)
    {
        //TODO:code here
    }
    
    CGGradientRelease(gradient);gradient=nil;
    
    CGContextRestoreGState(ctx);
    
}

-(void)drawForeground:(CGContextRef)ctx
{
    CGContextAddArc(ctx, CGRectGetWidth( self.frame )/2, CGRectGetHeight( self.frame )/2, radius + (BACKGROUND_WIDTH + BORDER_WIDTH-1)/2, 0, M_PI*2, 0);
    [[UIColor blackColor]setStroke];
    
    CGContextSetLineWidth(ctx, BORDER_WIDTH);
    CGContextSetLineCap(ctx, kCGLineCapButt);
    
    CGContextDrawPath(ctx, kCGPathStroke);
    
    CGContextAddArc(ctx, CGRectGetWidth( self.frame )/2, CGRectGetHeight( self.frame )/2, radius - (BACKGROUND_WIDTH + BORDER_WIDTH-1)/2, 0, M_PI*2, 0);
    CGContextDrawPath(ctx, kCGPathStroke);
}

-(void) drawHandle:(CGContextRef)ctx{
    
    CGContextSaveGState(ctx);
    CGContextSetShadowWithColor(ctx, CGSizeMake(0, 0), 3, [UIColor blackColor].CGColor);
    CGPoint handleCenter = [self pointFromAngle: angle];
    [[UIColor colorWithWhite:1.0 alpha:0.8]set];
    CGContextFillEllipseInRect(ctx, CGRectMake(handleCenter.x, handleCenter.y, BACKGROUND_WIDTH, BACKGROUND_WIDTH));
    CGContextRestoreGState(ctx);
}


-(void)getColorsForAngle:(float)a outColors:(CGFloat**)colors
{
    float rx1,gx1,bx1;
    float rx2,gx2,bx2;
    
    rx1 = a / 360;
    gx1 = 1 - a / 360;
    bx1 = 1 - a / 360;
    
    rx2 = a / 180;
    gx2 = 1 - a / 180;
    bx2 = a < 180 ? ( 1 - a / 180) : a / 180 - 1;
    
    CGFloat components[8] = {rx1*1.0, gx1*1.0, bx1*1.0, 1.0,      rx2*1.0, gx2*1.0, bx2*1.0, 1.0 };
    *colors = malloc(sizeof(CGFloat)* 8);
    for (int i=0; i<8; i++) {
        (*colors)[i]=components[i];
    }
//    *colors = components;
}

-(CGPoint)pointFromAngle:(int)angleInt
{
    CGPoint centerPoint = CGPointMake(self.frame.size.width/2 - BACKGROUND_WIDTH/2, self.frame.size.height/2 - BACKGROUND_WIDTH/2);
    CGPoint result;
    result.y = round(centerPoint.y + radius * sin(ToRad(-angleInt))) ;
    result.x = round(centerPoint.x + radius * cos(ToRad(-angleInt)));
    return result;
}

-(void)movehandle:(CGPoint)lastPoint
{
    CGPoint centerPoint = CGPointMake(self.frame.size.width/2, self.frame.size.height/2);
    
    float currentAngle = AngleFromNorth(centerPoint, lastPoint, NO);
    int angleInt = floor(currentAngle);
    
    float newAngle = 360 - angleInt;
    
    if(abs(angle-newAngle) < 90)
    {
        angle = newAngle;
    }
    
    [self setNeedsDisplay];
}


static inline float AngleFromNorth(CGPoint p1, CGPoint p2, BOOL flipped) {
    CGPoint v = CGPointMake(p2.x-p1.x,p2.y-p1.y);
    float vmag = sqrt(SQR(v.x) + SQR(v.y)), result = 0;
    v.x /= vmag;
    v.y /= vmag;
    double radians = atan2(v.y,v.x);
    result = ToDeg(radians);
    return (result >=0  ? result : result + 360.0);
}

-(BOOL)beginTrackingWithTouch:(UITouch *)touch withEvent:(UIEvent *)event{
    [super beginTrackingWithTouch:touch withEvent:event];
    
    return YES;
}

-(BOOL)continueTrackingWithTouch:(UITouch *)touch withEvent:(UIEvent *)event{
    [super continueTrackingWithTouch:touch withEvent:event];
    
    CGPoint lastPoint = [touch locationInView:self];
    
    [self movehandle:lastPoint];
    
    [self sendActionsForControlEvents:UIControlEventValueChanged];
    
    return YES;
}

-(void)endTrackingWithTouch:(UITouch *)touch withEvent:(UIEvent *)event{
    [super endTrackingWithTouch:touch withEvent:event];
    
}
@end
