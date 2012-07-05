//
//  SEFilterControl.m
//  SEFilterControl_Test
//
//  Created by Shady A. Elyaski on 6/13/12.
//  Copyright (c) 2012 mash, ltd. All rights reserved.
//
//    Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:
//
//    The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.
//
//    THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.

#import "SEFilterControl.h"
#import "SEFilterKnob.h"

NSString *const kTitlesTextKey = @"text";
NSString *const kTitlesSelectedColorKey = @"selectedColor";
NSString *const kTitlesSelectedFontKey = @"font";
static NSString *const kTitlesPropertyName = @"titles";
static NSString *const kTitleLabelsPropertyName = @"titleLabels";

@interface SEFilterControl()

@property (assign, nonatomic) CGPoint diffPoint;
@property (assign, nonatomic) CGFloat oneSlotSize;

@end

@implementation SEFilterControl

@synthesize tapGestureRecognizer = _tapGestureRecognizer;
@synthesize titles = _titles;
@synthesize selectedIndex = _selectedIndex;
@synthesize progressColor = _progressColor;
@synthesize handler = _handler;
@synthesize padding = _padding;
@synthesize selectedOffset = _selectedOffset;
@synthesize backgroundImage = _backgroundImage;
@synthesize backgroundView = _backgroundView;
@synthesize progressBarCenterY = _progressBarCenterY;
@synthesize progressBarHeight = _progressBarHeight;
@synthesize progressBarSelectionCircleLength = _progressBarSelectionCircleLength;
@synthesize titleCenterY = _titleCenterY;
@synthesize titleLabels = _titleLabels;
@synthesize diffPoint = _diffPoint;
@synthesize oneSlotSize = _oneSlotSize;
@synthesize titleFont = _titleFont;
@synthesize titleColor = _titleColor;
@synthesize titleAlpha = _titleAlpha;

#pragma mark - Helper methods

- (CGPoint)getCenterPointForIndex:(NSInteger)theIndex {
    CGFloat theNormalizedIndex = (CGFloat)theIndex/(CGFloat)([self countOfTitles] - 1);
    CGFloat theWidth = CGRectGetWidth(self.bounds) - self.padding.left - self.padding.right;
    
    return CGPointMake(self.padding.left + (theNormalizedIndex * theWidth), self.progressBarCenterY);
}

- (CGPoint)fixFinalPoint:(CGPoint)thePoint {
    CGFloat theMinHandleMinX = self.padding.left - (CGRectGetWidth(self.handler.frame) / 2.0f);
    if (thePoint.x < theMinHandleMinX) {
        thePoint.x = theMinHandleMinX;
        return thePoint;
    }
    CGFloat theMaxHandleMinX = CGRectGetWidth(self.bounds) - self.padding.right - (CGRectGetWidth(self.handler.frame) / 2.0f);
    if (thePoint.x > theMaxHandleMinX) {
        thePoint.x = theMaxHandleMinX;
        return thePoint;
    }
    return thePoint;
}

- (void)setHandlerColor:(UIColor *)theColor {
    self.handler.handlerColor = theColor;
}

- (void)layoutTitleLabelsForSelectedIndex:(NSInteger)theSelectedIndex {
    [self.titleLabels enumerateObjectsUsingBlock:^(id theObject, NSUInteger theIndex, BOOL *theStop) {
        UILabel *theTitleLabel = (UILabel *)theObject;
        CGSize theTitleSize = [theTitleLabel.text sizeWithFont:theTitleLabel.font];
        theTitleSize.width = self.oneSlotSize;
        CGPoint theCenterPoint = [self getCenterPointForIndex:theIndex];
        theCenterPoint.x -= (theTitleSize.width / 2.0f);
        theCenterPoint.y = self.titleCenterY - (theTitleSize.height / 2.0f);
        if (theIndex == theSelectedIndex) {
            theCenterPoint.y -= self.selectedOffset.height;
            
            NSDictionary *theDictionary = [self objectInTitlesAtIndex:theIndex];
            theTitleLabel.alpha = 1.0f;
            theTitleLabel.textColor = [theDictionary objectForKey:kTitlesSelectedColorKey];
            theTitleLabel.font = [theDictionary objectForKey:kTitlesSelectedFontKey];
        } else {
            theTitleLabel.alpha = self.titleAlpha;
            theTitleLabel.textColor = self.titleColor;
            theTitleLabel.font = self.titleFont;
        }
        theTitleLabel.frame = CGRectMake(theCenterPoint.x, theCenterPoint.y, theTitleSize.width, theTitleSize.height);
    }];
}

- (void)animateTitleLabelsForSelectedIndex:(NSInteger)theSelectedIndex {
    [UIView
     animateWithDuration:0.3f
     animations:^{
         [self layoutTitleLabelsForSelectedIndex:theSelectedIndex];
     }];
}

- (void)changeHandlerColorToIndex:(NSInteger)theIndex {
    NSArray *theTitlesSelectedColor = [self valueForKeyPath:@"titles.@unionOfObjects.selectedColor"];
    self.handler.handlerColor = [theTitlesSelectedColor objectAtIndex:theIndex];
}

- (void)animateHandlerColorToIndex:(NSInteger)theIndex {
    [UIView
     animateWithDuration:0.3f
     animations:^{
         [self changeHandlerColorToIndex:theIndex];
     }];
}

- (void)layoutHandlerAtIndex:(NSInteger)theIndex {
    CGPoint thePoint = [self getCenterPointForIndex:theIndex];
    thePoint.x -= (CGRectGetWidth(self.handler.frame) / 2.0f);
    thePoint.y -= (CGRectGetHeight(self.handler.frame) / 2.0f);
    thePoint = [self fixFinalPoint:thePoint];
    self.handler.frame = CGRectMake(thePoint.x, thePoint.y, CGRectGetWidth(self.handler.frame), CGRectGetHeight(self.handler.frame));
    [self changeHandlerColorToIndex:theIndex];
}

- (void)animateHandlerToIndex:(NSInteger)theIndex {
    [UIView
     animateWithDuration:0.3f
     animations:^{
         [self layoutHandlerAtIndex:theIndex];
     }];
}

- (NSInteger)getSelectedTitleInPoint:(CGPoint)thePoint {
    return (NSInteger)round((thePoint.x - self.padding.left) / self.oneSlotSize);
}

#pragma mark - Property accessor methods

- (UIImage *)backgroundImage {
    if (_backgroundImage == nil) {
        CGSize theSize = self.bounds.size;
        UIGraphicsBeginImageContextWithOptions(theSize, NO, [[UIScreen mainScreen] scale]);
        {
            CGContextRef theContext = UIGraphicsGetCurrentContext();
            
            //Fill Main Path
            CGContextSaveGState(theContext);
            {
                CGContextSetFillColorWithColor(theContext, self.progressColor.CGColor);
                
                CGContextFillRect(theContext, CGRectMake(self.padding.left, self.progressBarCenterY - (self.progressBarHeight * 0.5f), theSize.width - self.padding.right - self.padding.left, self.progressBarHeight));
            }
            CGContextRestoreGState(theContext);
            
            //Draw White Bottom Shadow
            CGContextSaveGState(theContext);
            {
                CGContextBeginPath(theContext);
                CGContextMoveToPoint(theContext, self.padding.left, self.progressBarCenterY + (self.progressBarHeight * 0.5f));
                CGContextAddLineToPoint(theContext, theSize.width - self.padding.right, self.progressBarCenterY + (self.progressBarHeight * 0.5f));
                CGContextClosePath(theContext);
                
                CGContextSetStrokeColorWithColor(theContext, [UIColor whiteColor].CGColor);
                CGContextSetLineWidth(theContext, 0.5f);
                
                CGContextStrokePath(theContext);
            }
            CGContextRestoreGState(theContext);
            
            for (NSInteger theIndex = 0; theIndex < [self countOfTitles]; theIndex++) {
                CGPoint theCenterPoint = [self getCenterPointForIndex:theIndex];
                CGFloat theCirclesLength = self.progressBarSelectionCircleLength;
                
                // Draw Selection Circles
                CGContextSaveGState(theContext);
                {
                    CGContextSetFillColorWithColor(theContext, self.progressColor.CGColor);
                    CGContextFillEllipseInRect(theContext, CGRectMake(theCenterPoint.x - (theCirclesLength / 2.0f), theCenterPoint.y - (theCirclesLength / 2.0f), theCirclesLength, theCirclesLength));
                }
                CGContextRestoreGState(theContext);
                
                // Draw top Gradient
                CGFloat theGradientColors[12] =
                {
                    0.0f, 0.0f, 0.0f, 1.0f,
                    0.0f, 0.0f, 0.0f, 0.0f,
                    0.0f, 0.0f, 0.0f, 0.0f
                };
                CGColorSpaceRef theBaseSpace = CGColorSpaceCreateDeviceRGB();
                CGGradientRef theGradient = CGGradientCreateWithColorComponents(theBaseSpace, theGradientColors, NULL, 3);
                CGContextSaveGState(theContext);
                {
                    CGContextAddEllipseInRect(theContext, CGRectMake(theCenterPoint.x - (theCirclesLength / 2.0f), theCenterPoint.y - (theCirclesLength / 2.0f), theCirclesLength, theCirclesLength));
                    CGContextClip(theContext);
                    CGContextDrawLinearGradient (theContext, theGradient, CGPointZero, CGPointMake(0.0f, theSize.height), 0);
                }
                CGContextRestoreGState(theContext);
                
                //Draw White Bottom Shadow
                CGContextSaveGState(theContext);
                {
                    CGContextSetStrokeColorWithColor(theContext, [UIColor colorWithWhite:1.0f alpha:0.5f].CGColor);
                    CGContextSetLineWidth(theContext, 0.5f);
                    CGContextAddArc(theContext, theCenterPoint.x, theCenterPoint.y, (theCirclesLength / 2.0f), 24.0f * M_PI / 180.0f, 156.0f * M_PI / 180.0f, 0);
                    CGContextDrawPath(theContext, kCGPathStroke);
                }
                CGContextRestoreGState(theContext);
            }
        }
        _backgroundImage = UIGraphicsGetImageFromCurrentImageContext();
        UIGraphicsEndImageContext();
    }
    return _backgroundImage;
}

- (UIView *)backgroundView {
    if (_backgroundView == nil) {
        _backgroundView = [[UIImageView alloc] initWithImage:self.backgroundImage];
        [self insertSubview:_backgroundView atIndex:0];
    }
    return _backgroundView;
}

- (SEFilterKnob *)handler {
    if (_handler == nil) {
        _handler = [SEFilterKnob buttonWithType:UIButtonTypeCustom];
        _handler.adjustsImageWhenHighlighted = NO;
        [_handler addTarget:self action:@selector(touchDown:withEvent:) forControlEvents:UIControlEventTouchDown];
        [_handler addTarget:self action:@selector(touchUp:) forControlEvents:UIControlEventTouchUpInside | UIControlEventTouchUpOutside];
        [_handler addTarget:self action:@selector(touchMove:withEvent:) forControlEvents: UIControlEventTouchDragOutside | UIControlEventTouchDragInside];
        [self addSubview:_handler];
    }
    return _handler;
}

- (void)setSelectedIndex:(NSInteger)theSelectedIndex {
    _selectedIndex = theSelectedIndex;
    [self animateTitleLabelsForSelectedIndex:_selectedIndex];
    [self animateHandlerToIndex:_selectedIndex];
    [self sendActionsForControlEvents:UIControlEventValueChanged];
}

- (void)setSelectedIndex:(NSInteger)theSelectedIndex animated:(BOOL)theAnimated {
    _selectedIndex = theSelectedIndex;
    [UIView
     animateWithDuration:(theAnimated) ? 0.3f : 0.0f
     animations:^{
         [self layoutTitleLabelsForSelectedIndex:_selectedIndex];
         [self layoutHandlerAtIndex:_selectedIndex];
         [self sendActionsForControlEvents:UIControlEventValueChanged];
     }];
}

#pragma mark -

- (id)initWithFrame:(CGRect)theFrame {
    self = [super initWithFrame:theFrame];
    if (self) {
        [self addObserver:self forKeyPath:kTitlesPropertyName options:NSKeyValueObservingOptionNew context:NULL];
        [self addObserver:self forKeyPath:kTitleLabelsPropertyName options:NSKeyValueObservingOptionOld | NSKeyValueObservingOptionNew context:NULL];
        
        self.progressBarCenterY = CGRectGetHeight(self.bounds) - 25.0f;
        self.progressBarHeight = 3.0f;
        self.progressBarSelectionCircleLength = self.handler.length - (6.0f * 2.0f);
        self.titleCenterY = self.progressBarCenterY - 20.0f;
        
        self.titleAlpha = 0.5f;
        self.titleFont = [UIFont fontWithName:@"HelveticaNeue-Medium" size:12.0f];
        self.titleColor = [UIColor colorWithWhite:0.2f alpha:1.0f];
    }
    return self;
}

- (id)initWithFrame:(CGRect)theFrame padding:(UIEdgeInsets)thePadding titles:(NSArray *)theTitles {
    self = [self initWithFrame:theFrame];
    if (self) {
        self.padding = thePadding;
        self.titles = [[NSArray alloc] initWithArray:theTitles];
        self.backgroundColor = [UIColor clearColor];
        self.progressColor = [UIColor colorWithWhite:0.824f alpha:1.0f];
        self.tapGestureRecognizer = [[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleTapGesture:)] autorelease];
        [self addGestureRecognizer:self.tapGestureRecognizer];
        
        self.oneSlotSize = (CGRectGetWidth(self.bounds) - self.padding.left - self.padding.right) / ([self countOfTitles] - 1);
    }
    return self;
}

- (void)dealloc {
    [self.handler removeTarget:self action:@selector(touchDown:withEvent:) forControlEvents:UIControlEventTouchDown];
    [self.handler removeTarget:self action:@selector(touchUp:) forControlEvents:UIControlEventTouchUpInside | UIControlEventTouchUpOutside];
    [self.handler removeTarget:self action:@selector(touchMove:withEvent: ) forControlEvents: UIControlEventTouchDragOutside | UIControlEventTouchDragInside];
    
    [self removeObserver:self forKeyPath:kTitlesPropertyName context:NULL];
    [self removeObserver:self forKeyPath:kTitleLabelsPropertyName context:NULL];
}

- (void)layoutSubviews {
    [super layoutSubviews];
    
    self.backgroundView.frame = self.bounds;
    
    [self layoutTitleLabelsForSelectedIndex:self.selectedIndex];
    
    [self layoutHandlerAtIndex:self.selectedIndex];
}

#pragma mark - titles Key-Value Coding methods

- (NSUInteger)countOfTitles {
    return self.titles.count;
}

- (NSDictionary *)objectInTitlesAtIndex:(NSUInteger)theIndex {
    return [self.titles objectAtIndex:theIndex];
}

- (NSArray *)titlesAtIndexes:(NSIndexSet *)theIndexes {
    return [self.titles objectsAtIndexes:theIndexes];
}

- (void)getTitles:(NSDictionary * __unsafe_unretained *)theBuffer range:(NSRange)inRange {
    [self.titles getObjects:theBuffer range:inRange];
}

#pragma mark - titleLabels Key-Value Coding methods

- (NSUInteger)countOfTitleLabels {
    return self.titleLabels.count;
}

- (NSDictionary *)objectInTitleLabelsAtIndex:(NSUInteger)theIndex {
    return [self.titleLabels objectAtIndex:theIndex];
}

- (NSArray *)titleLabelsAtIndexes:(NSIndexSet *)theIndexes {
    return [self.titleLabels objectsAtIndexes:theIndexes];
}

- (void)getTitleLabels:(NSDictionary * __unsafe_unretained *)theBuffer range:(NSRange)inRange {
    [self.titleLabels getObjects:theBuffer range:inRange];
}

#pragma mark - Target-Action methods

- (void)handleTapGesture:(UITapGestureRecognizer *)theTapGestureRecognizer {
    switch (theTapGestureRecognizer.state) {
        case UIGestureRecognizerStateBegan: {
            [self sendActionsForControlEvents:UIControlEventTouchDown];
        } break;
        case UIGestureRecognizerStateEnded: {
            CGPoint theLocation = [theTapGestureRecognizer locationInView:self];
            NSInteger theSelectedIndex = [self getSelectedTitleInPoint:theLocation];
            self.selectedIndex = theSelectedIndex;
            [self sendActionsForControlEvents:UIControlEventTouchUpInside];
        } break;
        default: {
        } break;
    }
}

- (void)touchDown:(UIButton *)btn withEvent: (UIEvent *)ev {
    CGPoint currPoint = [[[ev allTouches] anyObject] locationInView:self];
    self.diffPoint = CGPointMake(currPoint.x - btn.frame.origin.x, currPoint.y - btn.frame.origin.y);
    [self sendActionsForControlEvents:UIControlEventTouchDown];
}

- (void)touchMove:(UIButton *)btn withEvent:(UIEvent *)ev {
    CGPoint currPoint = [[[ev allTouches] anyObject] locationInView:self];
    
    CGPoint toPoint = CGPointMake(currPoint.x - self.diffPoint.x, self.handler.frame.origin.y);
    
    toPoint = [self fixFinalPoint:toPoint];
    
    [self.handler setFrame:CGRectMake(toPoint.x, toPoint.y, self.handler.frame.size.width, self.handler.frame.size.height)];
    
    int selected = [self getSelectedTitleInPoint:btn.center];
    
    [self animateTitleLabelsForSelectedIndex:selected];
    [self animateHandlerColorToIndex:selected];
    
    [self sendActionsForControlEvents:UIControlEventTouchDragInside];
}

- (void)touchUp:(UIButton *)btn {
    self.selectedIndex = [self getSelectedTitleInPoint:btn.center];
    [self animateHandlerToIndex:_selectedIndex];
    [self sendActionsForControlEvents:UIControlEventTouchUpInside];
}

#pragma mark - Key-Value Observing methods

- (void)observeValueForKeyPath:(NSString *)theKeyPath ofObject:(id)theObject change:(NSDictionary *)theChange context:(void *)theContext {
    if ([theKeyPath isEqualToString:kTitlesPropertyName]) {
        NSKeyValueChange theKeyValueChange = ((NSNumber *)[theChange objectForKey:NSKeyValueChangeKindKey]).unsignedIntegerValue;
        switch (theKeyValueChange) {
            case NSKeyValueChangeSetting: {
                if (self.titles) {
                    NSMutableArray *theTitleLabels = [[NSMutableArray alloc] init];
                    [self.titles enumerateObjectsUsingBlock:^(id theObject, NSUInteger theIndex, BOOL *theStop) {
                        NSDictionary *theDictionary = (NSDictionary *)theObject;
                        
                        UILabel *theTitleLabel = [[UILabel alloc] initWithFrame:CGRectZero];
                        theTitleLabel.text = [theDictionary objectForKey:kTitlesTextKey];
                        theTitleLabel.lineBreakMode = UILineBreakModeMiddleTruncation;
                        theTitleLabel.textAlignment = UITextAlignmentCenter;
                        theTitleLabel.backgroundColor = [UIColor clearColor];
                        
                        theTitleLabel.tag = theIndex + 50;
                        
                        CGPoint theCenterPoint = [self getCenterPointForIndex:theIndex];
                        theCenterPoint.y -= [theTitleLabel.text sizeWithFont:theTitleLabel.font].height;
                        if (self.selectedIndex == theIndex) {
                            theCenterPoint.y -= self.selectedOffset.height;
                            theTitleLabel.center = theCenterPoint;
                            theTitleLabel.alpha = 1.0f;
                            theTitleLabel.textColor = [theDictionary objectForKey:kTitlesSelectedColorKey];
                            theTitleLabel.font = [theDictionary objectForKey:kTitlesSelectedFontKey];
                        } else {
                            theTitleLabel.center = theCenterPoint;
                            theTitleLabel.alpha = self.titleAlpha;
                            theTitleLabel.textColor = self.titleColor;
                            theTitleLabel.font = self.titleFont;
                        }
                        [theTitleLabels addObject:theTitleLabel];
                    }];
                    self.titleLabels = [theTitleLabels copy];
                } else {
                    self.titleLabels = nil;
                }
            } break;
            default: {
                @throw [NSException exceptionWithName:NSInternalInconsistencyException
                                               reason:@"Invalid execution path."
                                             userInfo:nil];
            } break;
        }
    } else if ([theKeyPath isEqualToString:kTitleLabelsPropertyName]) {
        NSKeyValueChange theKeyValueChange = ((NSNumber *)[theChange objectForKey:NSKeyValueChangeKindKey]).unsignedIntegerValue;
        switch (theKeyValueChange) {
            case NSKeyValueChangeSetting: {
                NSArray *theOldArray = [theChange objectForKey:NSKeyValueChangeOldKey];
                if ([theOldArray isEqual:[NSNull null]]) {
                    theOldArray = nil;
                }
                for (UILabel *theTitleLabel in theOldArray) {
                    [theTitleLabel removeFromSuperview];
                }
                
                NSArray *theNewArray = [theChange objectForKey:NSKeyValueChangeNewKey];
                if ([theNewArray isEqual:[NSNull null]]) {
                    theNewArray = nil;
                }
                for (UILabel *theTitleLabel in theNewArray) {
                    [self addSubview:theTitleLabel];
                }
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