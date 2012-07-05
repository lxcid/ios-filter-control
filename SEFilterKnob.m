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
#import <QuartzCore/QuartzCore.h>

static NSString *const kHandlerColorPropertyName = @"handlerColor";
static NSString *const kKnobSublayerPropertyName = @"knobSublayer";
static NSString *const kHandlerBackgroundImagePropertyName = @"handlerBackgroundImage";

@interface SEFilterKnob ()

@property (strong, nonatomic) CALayer *knobSublayer;

@end

@implementation SEFilterKnob

@synthesize handlerColor = _handlerColor;
@synthesize knobSublayer = _knobSublayer;
@synthesize length = _length;
@synthesize handlerBackgroundImage = _handlerBackgroundImage;

- (CGFloat)length {
    if (self.handlerBackgroundImage) {
        return MAX(self.handlerBackgroundImage.size.width, self.handlerBackgroundImage.size.height);
    } else {
        return _length;
    }
}

- (id)initWithFrame:(CGRect)theFrame {
    self = [super initWithFrame:theFrame];
    if (self) {
        // Initialization code
        [self addObserver:self forKeyPath:kHandlerColorPropertyName options:NSKeyValueObservingOptionNew context:NULL];
        [self addObserver:self forKeyPath:kKnobSublayerPropertyName options:NSKeyValueObservingOptionOld | NSKeyValueObservingOptionNew context:NULL];
        [self addObserver:self forKeyPath:kHandlerBackgroundImagePropertyName options:NSKeyValueObservingOptionNew context:NULL];
    }
    return self;
}

- (void)dealloc {
    [self removeObserver:self forKeyPath:kHandlerColorPropertyName context:NULL];
    [self removeObserver:self forKeyPath:kKnobSublayerPropertyName context:NULL];
    [self removeObserver:self forKeyPath:kHandlerBackgroundImagePropertyName context:NULL];
}

- (void)layoutSubviews {
    [super layoutSubviews];
    
    if (self.handlerBackgroundImage) {
        if ((self.knobSublayer == nil) || [self.knobSublayer isKindOfClass:[CAShapeLayer class]]) {
            self.knobSublayer = [CALayer layer];
            self.knobSublayer.frame = CGRectMake((CGRectGetWidth(self.bounds) - self.handlerBackgroundImage.size.width) / 2.0f, (CGRectGetHeight(self.bounds) - self.handlerBackgroundImage.size.height) / 2.0f, self.handlerBackgroundImage.size.width, self.handlerBackgroundImage.size.height);
            self.knobSublayer.contents = (id)self.handlerBackgroundImage.CGImage;
        } else {
            self.knobSublayer.frame = CGRectMake((CGRectGetWidth(self.bounds) - self.handlerBackgroundImage.size.width) / 2.0f, (CGRectGetHeight(self.bounds) - self.handlerBackgroundImage.size.height) / 2.0f, self.handlerBackgroundImage.size.width, self.handlerBackgroundImage.size.height);
            self.knobSublayer.contents = (id)self.handlerBackgroundImage.CGImage;
        }
    } else {
        if ((self.knobSublayer == nil) || ![self.knobSublayer isKindOfClass:[CAShapeLayer class]]) {
            UIBezierPath *theBezierPath = [UIBezierPath bezierPathWithOvalInRect:CGRectOffset(CGRectInset(self.bounds, 2.0f, 2.0f), 0.0f, -1.0f)];
            CAShapeLayer *theShapeLayer = [CAShapeLayer layer];
            theShapeLayer.path = theBezierPath.CGPath;
            theShapeLayer.fillColor = [UIColor blackColor].CGColor;
            theShapeLayer.strokeColor = [UIColor whiteColor].CGColor;
            theShapeLayer.lineWidth = 2.0f;
            theShapeLayer.fillRule = kCAFillRuleNonZero;
            theShapeLayer.shadowPath = theBezierPath.CGPath;
            theShapeLayer.shadowOpacity = 1.0f;
            theShapeLayer.shadowColor = [UIColor blackColor].CGColor;
            theShapeLayer.shadowOffset = CGSizeMake(0.0f, 0.5f);
            theShapeLayer.shadowRadius = 1.5f;
            self.knobSublayer = theShapeLayer;
        } else {
            CAShapeLayer *theShapeLayer = (CAShapeLayer *)self.knobSublayer;
            UIBezierPath *theBezierPath = [UIBezierPath bezierPathWithOvalInRect:CGRectOffset(CGRectInset(self.bounds, 2.0f, 2.0f), 0.0f, -1.0f)];
            theShapeLayer.path = theBezierPath.CGPath;
            theShapeLayer.shadowPath = theBezierPath.CGPath;
            theShapeLayer.fillColor = self.handlerColor.CGColor;
        }
    }
}

#pragma mark - Key-Value Observing methods

- (void)observeValueForKeyPath:(NSString *)theKeyPath ofObject:(id)theObject change:(NSDictionary *)theChange context:(void *)theContext {
    if ([theKeyPath isEqualToString:kHandlerColorPropertyName] || [theKeyPath isEqualToString:kHandlerBackgroundImagePropertyName]) {
        NSKeyValueChange theKeyValueChange = ((NSNumber *)[theChange objectForKey:NSKeyValueChangeKindKey]).unsignedIntegerValue;
        switch (theKeyValueChange) {
            case NSKeyValueChangeSetting: {
                [self setNeedsLayout];
            } break;
            default: {
                @throw [NSException exceptionWithName:NSInternalInconsistencyException
                                               reason:@"Invalid execution path."
                                             userInfo:nil];
            } break;
        }
    } else if ([theKeyPath isEqualToString:kKnobSublayerPropertyName]) {
        NSKeyValueChange theKeyValueChange = ((NSNumber *)[theChange objectForKey:NSKeyValueChangeKindKey]).unsignedIntegerValue;
        switch (theKeyValueChange) {
            case NSKeyValueChangeSetting: {
                CALayer *theOldLayer = [theChange objectForKey:NSKeyValueChangeOldKey];
                if ([theOldLayer isEqual:[NSNull null]]) {
                    theOldLayer = nil;
                }
                [theOldLayer removeFromSuperlayer];
                
                CALayer *theNewLayer = [theChange objectForKey:NSKeyValueChangeNewKey];
                if ([theNewLayer isEqual:[NSNull null]]) {
                    theNewLayer = nil;
                }
                [self.layer addSublayer:theNewLayer];
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
