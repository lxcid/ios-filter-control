//
//  SEFilterKnob.m
//  SEFilterControl_Test
//
//  Created by Shady A. Elyaski on 6/15/12.
//  Copyright (c) 2012 mash, ltd. All rights reserved.
//
//    Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:
//
//    The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.
//
//    THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.

#import "SEFilterKnob.h"

static NSString *const kHandlerColorPropertyName = @"handlerColor";

@implementation SEFilterKnob

@synthesize handlerColor = _handlerColor;
@synthesize drawingShadow = _drawingShadow;

- (id)initWithFrame:(CGRect)theFrame {
    self = [super initWithFrame:theFrame];
    if (self) {
        // Initialization code
        [self addObserver:self forKeyPath:kHandlerColorPropertyName options:NSKeyValueObservingOptionNew context:NULL];
        self.handlerColor = [UIColor colorWithRed:230.0f / 255.f green:230.0f / 255.f blue:230.0f / 255.f alpha:1.0f];
    }
    return self;
}

- (void)dealloc {
    [self removeObserver:self forKeyPath:kHandlerColorPropertyName context:NULL];
}

// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)theRect {
    CGContextRef theContext = UIGraphicsGetCurrentContext();
    
    //Draw Main Cirlce
    CGContextSaveGState(theContext);
    
    if (self.isDrawingShadow) {
        UIColor *theShadowColor = [UIColor colorWithRed:0.0f green:0.0f blue:0.0f alpha:.4f];
        CGContextSetShadowWithColor(theContext, CGSizeMake(0.0f, 7.0f), 10.0f, theShadowColor.CGColor);
    }
    CGContextSetStrokeColorWithColor(theContext, self.handlerColor.CGColor);
    CGContextSetLineWidth(theContext, 11.0f);
    CGContextStrokeEllipseInRect(theContext, CGRectMake(6.5f, 6.0f, 22.0f, 22.0f));
    
    CGContextRestoreGState(theContext);
    
    //Draw Outer Outline
    CGContextSaveGState(theContext);
    
    CGContextSetStrokeColorWithColor(theContext, [UIColor colorWithWhite:0.5f alpha:0.6f].CGColor);
    CGContextSetLineWidth(theContext, 1.0f);
    CGContextStrokeEllipseInRect(theContext, CGRectMake(CGRectGetMinX(theRect) + 1.5f, CGRectGetMinY(theRect) + 1.2f, 32.0f, 32.0f));
    
    CGContextRestoreGState(theContext);
    
    //Draw Inner Outline
    CGContextSaveGState(theContext);
    
    CGContextSetStrokeColorWithColor(theContext, [UIColor colorWithWhite:0.5f alpha:0.6f].CGColor);
    CGContextSetLineWidth(theContext, 1.0f);
    CGContextStrokeEllipseInRect(theContext, CGRectMake(CGRectGetMinX(theRect) + 12.5f, CGRectGetMinY(theRect) + 12.0f, 10.0f, 10.0f));
    
    CGContextRestoreGState(theContext);
    
    // Draw Highlight/Gradient
    CGContextSaveGState(theContext);
    
    CGFloat theColors[] = { 0.0f, 0.0f, 0.0f, 0.0f, 0.0f, 0.0f, 0.0f, 0.6f };
    CGColorSpaceRef theBaseSpace = CGColorSpaceCreateDeviceRGB();
    CGGradientRef theGradient = CGGradientCreateWithColorComponents(theBaseSpace, theColors, NULL, 2);
    CGContextAddEllipseInRect(theContext, CGRectMake(CGRectGetMinX(theRect) + 1.5f, CGRectGetMinY(theRect) + 1.0f, 32.0f, 32.0f));
    CGContextClip(theContext);
    CGContextDrawLinearGradient (theContext, theGradient, CGPointZero, CGPointMake(0.0f, CGRectGetHeight(theRect)), 0.0f);
    
    CGContextRestoreGState(theContext);
}

#pragma mark - Key-Value Observing methods

- (void)observeValueForKeyPath:(NSString *)theKeyPath ofObject:(id)theObject change:(NSDictionary *)theChange context:(void *)theContext {
    if ([theKeyPath isEqualToString:kHandlerColorPropertyName]) {
        NSKeyValueChange theKeyValueChange = ((NSNumber *)[theChange objectForKey:NSKeyValueChangeKindKey]).unsignedIntegerValue;
        switch (theKeyValueChange) {
            case NSKeyValueChangeSetting: {
                [self setNeedsDisplay];
            } break;
            default: {
                @throw [NSException exceptionWithName:NSInternalInconsistencyException
                                               reason:@"Invalid execution path."
                                             userInfo:nil];
            } break;
        }
    }
}

@end
