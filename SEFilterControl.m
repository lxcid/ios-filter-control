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

#define LEFT_OFFSET 35.0f
#define RIGHT_OFFSET 35.0f
#define TITLE_SELECTED_DISTANCE 5.0f
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

@synthesize titles = _titles;
@synthesize selectedIndex = _selectedIndex;
@synthesize progressColor = _progressColor;
@synthesize handler = _handler;

-(CGPoint)getCenterPointForIndex:(NSInteger)theIndex {
    CGFloat theNormalizedIndex = (CGFloat)theIndex/(CGFloat)([self countOfTitles] - 1);
    CGFloat theWidth = CGRectGetWidth(self.bounds) - LEFT_OFFSET - RIGHT_OFFSET;
    CGFloat theHandleLength = 28.0f;
    
    return CGPointMake(LEFT_OFFSET + (theNormalizedIndex * theWidth), CGRectGetHeight(self.bounds) - (theHandleLength / 2.0f) - 10.0f);
}

-(CGPoint)fixFinalPoint:(CGPoint)thePoint {
    CGFloat theMinHandleMinX = LEFT_OFFSET - (CGRectGetWidth(self.handler.frame) / 2.0f);
    if (thePoint.x < theMinHandleMinX) {
        thePoint.x = theMinHandleMinX;
        return thePoint;
    }
    CGFloat theMaxHandleMinX = CGRectGetWidth(self.bounds) - RIGHT_OFFSET - (CGRectGetWidth(self.handler.frame) / 2.0f);
    if (thePoint.x > theMaxHandleMinX) {
        thePoint.x = theMaxHandleMinX;
        return thePoint;
    }
    return thePoint;
}

- (id)initWithFrame:(CGRect)theFrame titles:(NSArray *)theTitles {
    self = [super initWithFrame:theFrame];
    if (self) {
        self.backgroundColor = [UIColor clearColor];
        self.titles = [[NSArray alloc] initWithArray:theTitles];
        self.progressColor = [UIColor colorWithWhite:0.824f alpha:1.0f];
        
        UITapGestureRecognizer *theTapGestureRecognizer = [[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(itemSelected:)] autorelease];
        [self addGestureRecognizer:theTapGestureRecognizer];
        
        CGFloat theHandleLength = 28.0f;
        self.handler = [SEFilterKnob buttonWithType:UIButtonTypeCustom];
        [self.handler setFrame:CGRectMake(LEFT_OFFSET - (theHandleLength / 2.0f), CGRectGetHeight(self.bounds) - theHandleLength - 10.0f, theHandleLength, theHandleLength)];
        [self.handler setAdjustsImageWhenHighlighted:NO];
        [self.handler addTarget:self action:@selector(TouchDown:withEvent:) forControlEvents:UIControlEventTouchDown];
        [self.handler addTarget:self action:@selector(TouchUp:) forControlEvents:UIControlEventTouchUpInside | UIControlEventTouchUpOutside];
        [self.handler addTarget:self action:@selector(TouchMove:withEvent:) forControlEvents: UIControlEventTouchDragOutside | UIControlEventTouchDragInside];
        [self addSubview:self.handler];
        
        int i;
        NSString *title;
        UILabel *lbl;
        
        oneSlotSize = 1.f*(self.frame.size.width-LEFT_OFFSET-RIGHT_OFFSET-1)/([self countOfTitles]-1);
        NSArray *theTitlesText = [self valueForKeyPath:@"titles.@unionOfObjects.text"];
        for (i = 0; i < [self countOfTitles]; i++) {
            title = [theTitlesText objectAtIndex:i];
            lbl = [[UILabel alloc]initWithFrame:CGRectMake(0, 0, oneSlotSize, 25)];
            [lbl setText:title];
            [lbl setFont:TITLE_FONT];
            [lbl setTextColor:TITLE_COLOR];
            [lbl setLineBreakMode:UILineBreakModeMiddleTruncation];
            [lbl setAdjustsFontSizeToFitWidth:YES];
            [lbl setMinimumFontSize:8];
            [lbl setTextAlignment:UITextAlignmentCenter];
            [lbl setShadowOffset:CGSizeMake(0, 1)];
            [lbl setBackgroundColor:[UIColor clearColor]];
            [lbl setTag:i+50];
            
            if (i) {
                [lbl setAlpha:TITLE_FADE_ALPHA];
            }
            
            [lbl setCenter:[self getCenterPointForIndex:i]];
            
            
            [self addSubview:lbl];
            [lbl release];
        }
    }
    return self;
}

-(void)drawRect:(CGRect)rect{
    CGContextRef context = UIGraphicsGetCurrentContext();
    
    CGFloat theMinY = 25.0f;
    CGFloat theHeight = 3.0f;
    
    //Fill Main Path
    CGContextSaveGState(context);
    
    CGContextSetFillColorWithColor(context, self.progressColor.CGColor);
    
    CGContextFillRect(context, CGRectMake(LEFT_OFFSET, CGRectGetHeight(rect) - theMinY, CGRectGetWidth(rect) - RIGHT_OFFSET - LEFT_OFFSET, 3.0f));
    
    CGContextRestoreGState(context);
    
    
    //Draw Black Top Shadow
    CGContextSaveGState(context);
    
    CGContextBeginPath(context);
    CGContextMoveToPoint(context, LEFT_OFFSET, CGRectGetHeight(rect) - theMinY);
    CGContextAddLineToPoint(context, CGRectGetWidth(rect) - RIGHT_OFFSET, CGRectGetHeight(rect) - theMinY);
    CGContextClosePath(context);
    
    CGColorRef shadowColor = [UIColor colorWithRed:0.0f green:0.0f blue:0.0f alpha:0.9f].CGColor;
    CGContextSetShadowWithColor(context, CGSizeMake(0.0f, 1.0f), 2.0f, shadowColor);
    CGContextSetStrokeColorWithColor(context, [UIColor colorWithRed:0.0f green:0.0f blue:0.0f alpha:0.6f].CGColor);
    CGContextSetLineWidth(context, 0.5f);
    
    CGContextStrokePath(context);
    
    CGContextRestoreGState(context);
    
    //Draw White Bottom Shadow
    CGContextSaveGState(context);
    
    CGContextBeginPath(context);
    CGContextMoveToPoint(context, LEFT_OFFSET, CGRectGetHeight(rect) - theMinY + theHeight);
    CGContextAddLineToPoint(context, CGRectGetWidth(rect) - RIGHT_OFFSET, CGRectGetHeight(rect) - theMinY + theHeight);
    CGContextClosePath(context);
    
    CGContextSetStrokeColorWithColor(context, [UIColor colorWithRed:1.0f green:1.0f blue:1.0f alpha:1.0f].CGColor);
    CGContextSetLineWidth(context, 0.4f);
    
    CGContextStrokePath(context);
    
    CGContextRestoreGState(context);
    
    
    for (int i = 0; i < [self countOfTitles]; i++) {
        CGPoint centerPoint = [self getCenterPointForIndex:i];
        
        //Draw Selection Circles
        CGFloat theSelectionCirclesLength = 16.0f;
        CGContextSetFillColorWithColor(context, self.progressColor.CGColor);
        CGContextFillEllipseInRect(context, CGRectMake(centerPoint.x - (theSelectionCirclesLength / 2.0f), centerPoint.y - (theSelectionCirclesLength / 2.0f), theSelectionCirclesLength, theSelectionCirclesLength));
        
        //Draw top Gradient
        CGFloat colors[12] =   {0.0f, 0.0f, 0.0f, 1.0f,
                                0.0f, 0.0f, 0.0f, 0.0f,
                                0.0f, 0.0f, 0.0f, 0.0f};
        CGColorSpaceRef baseSpace = CGColorSpaceCreateDeviceRGB();
        CGGradientRef gradient = CGGradientCreateWithColorComponents(baseSpace, colors, NULL, 3);
        
        CGContextSaveGState(context);
        CGContextAddEllipseInRect(context, CGRectMake(centerPoint.x - (theSelectionCirclesLength / 2.0f), centerPoint.y - (theSelectionCirclesLength / 2.0f), theSelectionCirclesLength, theSelectionCirclesLength));
        CGContextClip(context);
        CGContextDrawLinearGradient (context, gradient, CGPointMake(0.0f, 0.0f), CGPointMake(0.0f, CGRectGetHeight(rect)), 0);
        CGContextRestoreGState(context);
        
        //Draw White Bottom Shadow
        
        CGContextSetStrokeColorWithColor(context, [UIColor colorWithRed:1 green:1
                                                                   blue:1 alpha:.4f].CGColor);
        CGContextSetLineWidth(context, 0.8f);
        CGContextAddArc(context, centerPoint.x, centerPoint.y, (theSelectionCirclesLength / 2.0f), 24.0f * M_PI / 180.0f, 156.0f * M_PI/180.0f, 0);
        CGContextDrawPath(context,kCGPathStroke);
        
        //Draw Black Top Shadow
        
        CGContextSetStrokeColorWithColor(context, [UIColor colorWithRed:0 green:0
                                                                   blue:0 alpha:.2f].CGColor);
        
        CGContextAddArc(context, centerPoint.x, centerPoint.y, (theSelectionCirclesLength / 2.0f), (i == ([self countOfTitles] - 1) ? 28.0f : -20.0f) * M_PI / 180.0f, ( (i == 0) ? -208.0f : -160.0f) * M_PI / 180.0f, 1);
        CGContextSetLineWidth(context, 1.f);
        CGContextDrawPath(context,kCGPathStroke);
        
    }
}

- (void)setHandlerColor:(UIColor *)theColor {
    self.handler.handlerColor = theColor;
}

- (void) TouchDown: (UIButton *) btn withEvent: (UIEvent *) ev{
    CGPoint currPoint = [[[ev allTouches] anyObject] locationInView:self];
    diffPoint = CGPointMake(currPoint.x - btn.frame.origin.x, currPoint.y - btn.frame.origin.y);
    [self sendActionsForControlEvents:UIControlEventTouchDown];
}

- (void)setTitlesColor:(UIColor *)theColor {
    for (NSInteger theIndex = 0; theIndex < [self countOfTitles]; theIndex++) {
        UILabel *theLabel = (UILabel *)[self viewWithTag:theIndex + 50];
        [theLabel setTextColor:theColor];
    }
}

- (void)setTitlesFont:(UIFont *)theFont {
    for (NSInteger theIndex = 0; theIndex < [self countOfTitles]; theIndex++) {
        UILabel *theLabel = (UILabel *)[self viewWithTag:theIndex + 50];
        [theLabel setFont:theFont];
    }
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
            [lbl setCenter:CGPointMake(lbl.center.x, self.frame.size.height-55-TITLE_SELECTED_DISTANCE)];
            [lbl setAlpha:1];
            lbl.textColor = [theDictionary objectForKey:kTitlesSelectedColorKey];
            lbl.font = [theDictionary objectForKey:kTitlesSelectedFontKey];
        }else{
            [lbl setCenter:CGPointMake(lbl.center.x, self.frame.size.height-55)];
            [lbl setAlpha:TITLE_FADE_ALPHA];
            lbl.textColor = TITLE_COLOR;
            lbl.font = TITLE_FONT;
        }
        [UIView commitAnimations];
    }
}

-(void) animateHandlerToIndex:(int) index{
    CGPoint toPoint = [self getCenterPointForIndex:index];
    toPoint = CGPointMake(toPoint.x-(self.handler.frame.size.width/2.f), self.handler.frame.origin.y);
    toPoint = [self fixFinalPoint:toPoint];
    NSArray *theTitlesSelectedColor = [self valueForKeyPath:@"titles.@unionOfObjects.selectedColor"];
    [UIView beginAnimations:nil context:nil];
    [self.handler setFrame:CGRectMake(toPoint.x, toPoint.y, self.handler.frame.size.width, self.handler.frame.size.height)];
    self.handler.handlerColor = [theTitlesSelectedColor objectAtIndex:index];
    [UIView commitAnimations];
}

- (void)setSelectedIndex:(int)theIndex {
    _selectedIndex = theIndex;
    [self animateTitlesToIndex:theIndex];
    [self animateHandlerToIndex:theIndex];
    [self sendActionsForControlEvents:UIControlEventValueChanged];
}

- (int)getSelectedTitleInPoint:(CGPoint)pnt {
    return round((pnt.x-LEFT_OFFSET)/oneSlotSize);
}

- (void)itemSelected:(UITapGestureRecognizer *)theTapGestureRecognizer {
    _selectedIndex = [self getSelectedTitleInPoint:[theTapGestureRecognizer locationInView:self]];
    [self setSelectedIndex:_selectedIndex];
    
    [self sendActionsForControlEvents:UIControlEventTouchUpInside];
    [self sendActionsForControlEvents:UIControlEventValueChanged];
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

@end