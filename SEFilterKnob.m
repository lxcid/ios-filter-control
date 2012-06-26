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

@interface SEFilterKnob ()

@property (strong, nonatomic) CAShapeLayer *knobSublayer;

@end

@implementation SEFilterKnob

@synthesize handlerColor = _handlerColor;
@synthesize knobSublayer = _knobSublayer;

- (CAShapeLayer *)knobSublayer {
    if (_knobSublayer == nil) {
        UIBezierPath *theBezierPath = [UIBezierPath bezierPathWithOvalInRect:CGRectOffset(CGRectInset(self.bounds, 2.0f, 2.0f), 0.0f, -1.0f)];
        _knobSublayer = [CAShapeLayer layer];
        _knobSublayer.path = theBezierPath.CGPath;
        _knobSublayer.fillColor = [UIColor blackColor].CGColor;
        _knobSublayer.strokeColor = [UIColor whiteColor].CGColor;
        _knobSublayer.lineWidth = 2.0f;
        _knobSublayer.fillRule = kCAFillRuleNonZero;
        _knobSublayer.shadowPath = theBezierPath.CGPath;
        _knobSublayer.shadowOpacity = 1.0f;
        _knobSublayer.shadowColor = [UIColor blackColor].CGColor;
        _knobSublayer.shadowOffset = CGSizeMake(0.0f, 0.5f);
        _knobSublayer.shadowRadius = 1.5f;
        [self.layer addSublayer:_knobSublayer];
    }
    return _knobSublayer;
}

- (id)initWithFrame:(CGRect)theFrame {
    self = [super initWithFrame:theFrame];
    if (self) {
        // Initialization code
        [self addObserver:self forKeyPath:kHandlerColorPropertyName options:NSKeyValueObservingOptionNew context:NULL];
        self.handlerColor = [UIColor orangeColor];
    }
    return self;
}

- (void)dealloc {
    [self removeObserver:self forKeyPath:kHandlerColorPropertyName context:NULL];
}

- (void)layoutSubviews {
    [super layoutSubviews];
    
    UIBezierPath *theBezierPath = [UIBezierPath bezierPathWithOvalInRect:CGRectOffset(CGRectInset(self.bounds, 2.0f, 2.0f), 0.0f, -1.0f)];
    self.knobSublayer.path = theBezierPath.CGPath;
    self.knobSublayer.shadowPath = theBezierPath.CGPath;
    self.knobSublayer.fillColor = self.handlerColor.CGColor;
}

#pragma mark - Key-Value Observing methods

- (void)observeValueForKeyPath:(NSString *)theKeyPath ofObject:(id)theObject change:(NSDictionary *)theChange context:(void *)theContext {
    if ([theKeyPath isEqualToString:kHandlerColorPropertyName]) {
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
    }
}

@end
