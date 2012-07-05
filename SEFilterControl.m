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

#define TITLE_FADE_ALPHA 0.5f
#define TITLE_FONT [UIFont fontWithName:@"HelveticaNeue-Medium" size:12.0f]
#define TITLE_COLOR [UIColor colorWithWhite:0.2f alpha:1.0f]

NSString *const kTitlesTextKey = @"text";
NSString *const kTitlesSelectedColorKey = @"selectedColor";
NSString *const kTitlesSelectedFontKey = @"font";

@interface SEFilterControl() {
    CGPoint diffPoint;
    float oneSlotSize;
}

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

- (CGPoint)getCenterPointForIndex:(NSInteger)theIndex {
    CGFloat theNormalizedIndex = (CGFloat)theIndex/(CGFloat)([self countOfTitles] - 1);
    CGFloat theWidth = CGRectGetWidth(self.bounds) - self.padding.left - self.padding.right;
    
    return CGPointMake(self.padding.left + (theNormalizedIndex * theWidth), self.progressBarCenterY);
}

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
        [_handler addTarget:self action:@selector(TouchDown:withEvent:) forControlEvents:UIControlEventTouchDown];
        [_handler addTarget:self action:@selector(TouchUp:) forControlEvents:UIControlEventTouchUpInside | UIControlEventTouchUpOutside];
        [_handler addTarget:self action:@selector(TouchMove:withEvent:) forControlEvents: UIControlEventTouchDragOutside | UIControlEventTouchDragInside];
        [self addSubview:_handler];
    }
    return _handler;
}

-(CGPoint)fixFinalPoint:(CGPoint)thePoint {
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

- (id)initWithFrame:(CGRect)theFrame padding:(UIEdgeInsets)thePadding titles:(NSArray *)theTitles {
    self = [super initWithFrame:theFrame];
    if (self) {
        self.padding = thePadding;
        self.titles = [[NSArray alloc] initWithArray:theTitles];
        self.backgroundColor = [UIColor clearColor];
        self.progressColor = [UIColor colorWithWhite:0.824f alpha:1.0f];
        self.tapGestureRecognizer = [[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleTapGesture:)] autorelease];
        [self addGestureRecognizer:self.tapGestureRecognizer];
        
        self.progressBarCenterY = CGRectGetHeight(self.bounds) - 25.0f;
        self.progressBarHeight = 3.0f;
        self.progressBarSelectionCircleLength = self.handler.length - (6.0f * 2.0f);
        
        oneSlotSize = 1.f*(self.frame.size.width-self.padding.left-self.padding.right-1)/([self countOfTitles]-1);
        for (int i = 0; i < [self countOfTitles]; i++) {
            NSDictionary *theDictionary = [self objectInTitlesAtIndex:i];
            UILabel *lbl = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, oneSlotSize, 25.0f)];
            lbl.text = [theDictionary objectForKey:kTitlesTextKey];
            lbl.lineBreakMode = UILineBreakModeMiddleTruncation;
            lbl.textAlignment = UITextAlignmentCenter;
            lbl.backgroundColor = [UIColor clearColor];
            lbl.tag = i + 50;
            
            if (self.selectedIndex == i) {
                CGPoint theCenterPoint = [self getCenterPointForIndex:i];
                theCenterPoint.y -= 20.0f;
                theCenterPoint.y -= self.selectedOffset.height;
                lbl.center = theCenterPoint;
                lbl.alpha = 1.0f;
                lbl.textColor = [theDictionary objectForKey:kTitlesSelectedColorKey];
                lbl.font = [theDictionary objectForKey:kTitlesSelectedFontKey];
            } else {
                CGPoint theCenterPoint = [self getCenterPointForIndex:i];
                theCenterPoint.y -= 20.0f;
                lbl.center = theCenterPoint;
                lbl.alpha = TITLE_FADE_ALPHA;
                lbl.textColor = TITLE_COLOR;
                lbl.font = TITLE_FONT;
            }
            
            [self addSubview:lbl];
            [lbl release];
        }
    }
    return self;
}

- (void)layoutSubviews {
    [super layoutSubviews];
    
    self.backgroundView.frame = self.bounds;
    
    [self layoutHandlerAtIndex:self.selectedIndex];
}

- (void)setHandlerColor:(UIColor *)theColor {
    self.handler.handlerColor = theColor;
}

- (void) TouchDown: (UIButton *) btn withEvent: (UIEvent *) ev{
    CGPoint currPoint = [[[ev allTouches] anyObject] locationInView:self];
    diffPoint = CGPointMake(currPoint.x - btn.frame.origin.x, currPoint.y - btn.frame.origin.y);
    [self sendActionsForControlEvents:UIControlEventTouchDown];
}

-(void) animateTitlesToIndex:(int) index{
    int i;
    UILabel *lbl;
    for (i = 0; i < [self countOfTitles]; i++) {
        lbl = (UILabel *)[self viewWithTag:i+50];
        [UIView beginAnimations:nil context:nil];
        [UIView setAnimationBeginsFromCurrentState:YES];
        if (i == index) {
            NSDictionary *theDictionary = [self objectInTitlesAtIndex:i];
            CGPoint theCenterPoint = [self getCenterPointForIndex:i];
            theCenterPoint.y -= 20.0f;
            theCenterPoint.y -= self.selectedOffset.height;
            lbl.center = theCenterPoint;
            [lbl setAlpha:1];
            lbl.textColor = [theDictionary objectForKey:kTitlesSelectedColorKey];
            lbl.font = [theDictionary objectForKey:kTitlesSelectedFontKey];
        }else{
            CGPoint theCenterPoint = [self getCenterPointForIndex:i];
            theCenterPoint.y -= 20.0f;
            lbl.center = theCenterPoint;
            [lbl setAlpha:TITLE_FADE_ALPHA];
            lbl.textColor = TITLE_COLOR;
            lbl.font = TITLE_FONT;
        }
        [UIView commitAnimations];
    }
}

- (void)layoutHandlerAtIndex:(NSInteger)theIndex {
    CGPoint thePoint = [self getCenterPointForIndex:theIndex];
    thePoint.x -= (CGRectGetWidth(self.handler.frame) / 2.0f);
    thePoint.y -= (CGRectGetHeight(self.handler.frame) / 2.0f);
    thePoint = [self fixFinalPoint:thePoint];
    NSArray *theTitlesSelectedColor = [self valueForKeyPath:@"titles.@unionOfObjects.selectedColor"];
    self.handler.frame = CGRectMake(thePoint.x, thePoint.y, CGRectGetWidth(self.handler.frame), CGRectGetHeight(self.handler.frame));
    self.handler.handlerColor = [theTitlesSelectedColor objectAtIndex:theIndex];
}

- (void)animateHandlerToIndex:(NSInteger)theIndex {
    [UIView
     animateWithDuration:0.3f
     animations:^{
         [self layoutHandlerAtIndex:theIndex];
     }];
}

- (void)setSelectedIndex:(int)theIndex {
    _selectedIndex = theIndex;
    [self animateTitlesToIndex:theIndex];
    [self animateHandlerToIndex:theIndex];
    [self sendActionsForControlEvents:UIControlEventValueChanged];
}

- (int)getSelectedTitleInPoint:(CGPoint)pnt {
    return round((pnt.x-self.padding.left)/oneSlotSize);
}

- (void)TouchUp:(UIButton *)btn {
    _selectedIndex = [self getSelectedTitleInPoint:btn.center];
    [self animateHandlerToIndex:_selectedIndex];
    [self sendActionsForControlEvents:UIControlEventTouchUpInside];
    [self sendActionsForControlEvents:UIControlEventValueChanged];
}

- (void) TouchMove: (UIButton *) btn withEvent: (UIEvent *) ev {
    CGPoint currPoint = [[[ev allTouches] anyObject] locationInView:self];
    
    CGPoint toPoint = CGPointMake(currPoint.x-diffPoint.x, self.handler.frame.origin.y);
    
    toPoint = [self fixFinalPoint:toPoint];
    
    [self.handler setFrame:CGRectMake(toPoint.x, toPoint.y, self.handler.frame.size.width, self.handler.frame.size.height)];
    
    int selected = [self getSelectedTitleInPoint:btn.center];
    
    [self animateTitlesToIndex:selected];
    
    [self sendActionsForControlEvents:UIControlEventTouchDragInside];
}

-(void)dealloc{
    [self.handler removeTarget:self action:@selector(TouchDown:withEvent:) forControlEvents:UIControlEventTouchDown];
    [self.handler removeTarget:self action:@selector(TouchUp:) forControlEvents:UIControlEventTouchUpInside | UIControlEventTouchUpOutside];
    [self.handler removeTarget:self action:@selector(TouchMove:withEvent: ) forControlEvents: UIControlEventTouchDragOutside | UIControlEventTouchDragInside];
    self.handler = nil;
    self.titles = nil;
    self.progressColor = nil;
    
    [super dealloc];
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

#pragma mark - Target-Action methods

- (void)handleTapGesture:(UITapGestureRecognizer *)theTapGestureRecognizer {
    switch (theTapGestureRecognizer.state) {
        case UIGestureRecognizerStateBegan: {
            [self sendActionsForControlEvents:UIControlEventTouchDown];
        } break;
        case UIGestureRecognizerStateEnded: {
            CGPoint theLocation = [theTapGestureRecognizer locationInView:self];
            NSInteger theSelectedIndex = [self getSelectedTitleInPoint:theLocation];
            if (self.selectedIndex != theSelectedIndex) {
                self.selectedIndex = theSelectedIndex;
                [self sendActionsForControlEvents:UIControlEventValueChanged];
            }
            [self sendActionsForControlEvents:UIControlEventTouchUpInside];
        } break;
        default: {
        } break;
    }
}

@end